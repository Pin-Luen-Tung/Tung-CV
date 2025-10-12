module ASYN_FIFO #(
    parameter Databits = 37,
    parameter Addrbits = 2
)
(
    input wclk,
    input wrst,
    input wpush,
    input [Databits - 1:0] wdata,
    output wfull,

    input rclk,
    input rrst,
    input rpop,
    output [Databits - 1:0] rdata,
    output rempty
);
localparam Depth = 1 << (Addrbits - 1);
//fifo memory
logic [Databits-1:0] mem [0:Depth-1];

//rptr
logic [Addrbits-1:0] rptr_binary;
logic [Addrbits-1:0] rptr_gray;

//rptr_cross_clock
logic [Addrbits-1:0] rptr_cross_clock_gray;
logic [Addrbits-1:0] rptr_cross_clock_binary;

//wptr 
logic [Addrbits-1:0] wptr_binary;
logic [Addrbits-1:0] wptr_gray;

//wptr_cross_clock
logic [Addrbits-1:0] wptr_cross_clock_gray;
logic [Addrbits-1:0] wptr_cross_clock_binary;

//double flip flop for ptr
logic [Addrbits-1:0] rptr_flipflop1;
logic [Addrbits-1:0] rptr_flipflop2;

logic [Addrbits-1:0] wptr_flipflop1;
logic [Addrbits-1:0] wptr_flipflop2;
//
logic wen;


////////////////////////////////////////////////////////////////////////////
//
//   
//         Binary to gray (highest bit hold , other B[i] = B[i] xor B[i+1])
//
//
////////////////////////////////////////////////////////////////////////////

assign rptr_gray = (rptr_binary>>1)^rptr_binary;
assign wptr_gray = (wptr_binary>>1)^wptr_binary;

//because glitch by combinational circuit so that you need use reg to promise that no metasabilty
logic [Addrbits-1:0] rptr_gray_r;
logic [Addrbits-1:0] wptr_gray_r;


always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) begin
        rptr_gray_r <= {Addrbits{1'b0}};
    end
    else begin
        rptr_gray_r <= rptr_gray;
    end
end

always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) begin
        wptr_gray_r <= {Addrbits{1'b0}};
    end
    else begin
        wptr_gray_r <= wptr_gray;
    end
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   
//         gray to binary (highest bit hold , other B[i] = G[i] xor B[i+1] or B[i]=G[i] xor G[i-1] xor G[i-1] xor
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign rptr_cross_clock_gray = rptr_flipflop2;
assign wptr_cross_clock_gray = wptr_flipflop2;

always_comb begin 
    rptr_cross_clock_binary[Addrbits - 1] = rptr_cross_clock_gray[Addrbits - 1];
    for (int i=0;i<(Addrbits-1);i=i+1) begin
        rptr_cross_clock_binary[i] = ^(rptr_cross_clock_gray>>i);
    end
end


always_comb begin 
    wptr_cross_clock_binary[Addrbits - 1] = wptr_cross_clock_gray[Addrbits - 1];
    for (int i=0;i<(Addrbits-1);i=i+1) begin
        wptr_cross_clock_binary[i] = ^(wptr_cross_clock_gray>>i);
    end
end

///////////////////////////////////////////////////////////////////////
//
//
//
//          double flip-flop
//
//
/////////////////////////////////////////////////////////////////////////

always_ff @(posedge rclk or posedge rrst) begin
    if(rrst) begin
        wptr_flipflop1 <= {Addrbits{1'b0}};
        wptr_flipflop2 <= {Addrbits{1'b0}};
    end
    else begin
        wptr_flipflop1 <= wptr_gray_r;
        wptr_flipflop2 <= wptr_flipflop1;
    end
end


always_ff @(posedge wclk or posedge wrst) begin
    if(wrst) begin
        rptr_flipflop1 <= {Addrbits{1'b0}};
        rptr_flipflop2 <= {Addrbits{1'b0}};
    end
    else begin
        rptr_flipflop1 <= rptr_gray_r;
        rptr_flipflop2 <= rptr_flipflop1;
    end
end


///////////////////////////////////////////////////////////////////////
//
//
//
//          wptr
//
//
/////////////////////////////////////////////////////////////////////////

always_ff @(posedge wclk or posedge wrst) begin
        if (wrst) begin
            for (int i=0 ; i<(1<<(Addrbits-1)); i++) mem[i] <= {Databits{1'b0}};
            wptr_binary <= {Addrbits{1'b0}};
        end
        else if (wen) begin
            mem[wptr_binary[Addrbits-2:0]] <= wdata;
            wptr_binary <= wptr_binary + {{Addrbits-1{1'b0}},1'b1}; 
        end
end

///////////////////////////////////////////////////////////////////////
//
//
//
//          rptr
//
//
/////////////////////////////////////////////////////////////////////////

always_ff @(posedge rclk or posedge rrst) begin
        if (rrst) begin
            rptr_binary <= {Addrbits{1'b0}};
        end
        else if (rpop && !rempty) begin
            rptr_binary  <= rptr_binary + {{Addrbits-1{1'b0}},1'b1}; 
        end
end


assign wfull  = ((wptr_binary[Addrbits-1] != rptr_cross_clock_binary[Addrbits-1]) && (wptr_binary[Addrbits-Addrbits:0] == rptr_cross_clock_binary[Addrbits-Addrbits:0]));
assign rempty = (rptr_binary == wptr_cross_clock_binary);
assign wen    = (wpush & ~wfull);
assign rdata = (!rempty) ? mem[rptr_binary[Addrbits-2:0]] : {Databits{1'b0}};    





endmodule