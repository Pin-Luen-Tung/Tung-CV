
module  FFT(
    input           clk      , 
    input           rst      , 
    input  [15:0]   fir_d    , 
    input           fir_valid,
    output          fft_valid, 
    output          done     ,
    output [15:0]   fft_d1   , 
    output [15:0]   fft_d2   ,
    output [15:0]   fft_d3   , 
    output [15:0]   fft_d4   , 
    output [15:0]   fft_d5   , 
    output [15:0]   fft_d6   , 
    output [15:0]   fft_d7   , 
    output [15:0]   fft_d8   ,
    output [15:0]   fft_d9   , 
    output [15:0]   fft_d10  , 
    output [15:0]   fft_d11  , 
    output [15:0]   fft_d12  , 
    output [15:0]   fft_d13  , 
    output [15:0]   fft_d14  , 
    output [15:0]   fft_d15  , 
    output [15:0]   fft_d0
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////
wire            su1_do_en;
wire  [23:0]    su1_do_re;
wire  [23:0]    su1_do_im;
wire            do_en;
wire  [23:0]    do_re;
wire  [23:0]    do_im;

reg [15:0] output_buffer_re [0:15];
reg [15:0] output_buffer_im [0:15];


reg [15:0] output_temp_re_1;
reg [15:0] output_temp_im_1;
reg [15:0] output_temp_re_2;
reg [15:0] output_temp_im_2;

reg [3:0] output_counter;
reg [4:0] done_counter;
reg [1:0] tx_counter; 
reg flag;
reg done_r;
reg rst_r;

always @(posedge clk) begin
    rst_r <= rst;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        flag <= 1'd0;
    end
    else begin
        flag <= (tx_counter==2'd2);
    end
end

Stage1 #(
    .N(16),
    .M(16),
    .INT_WIDTH_in(8),
    .FRA_WIDTH_in(8),
    .INT_WIDTH_out(8),
    .FRA_WIDTH_out(16)
) 
SU1 (
    .clk  (clk      ),  
    .rst  (rst      ),  
    .di_en  (fir_valid || (done_counter>5'd0)  ),  
    .di_re  (fir_d      ),  
    .di_im  (16'd0      ),  
    .do_en  (su1_do_en  ),  
    .do_re  (su1_do_re  ),  
    .do_im  (su1_do_im  )  
);

Stage2 #(
    .N(16),
    .M(4),
    .INT_WIDTH_in(8),
    .FRA_WIDTH_in(16),
    .INT_WIDTH_out(8),
    .FRA_WIDTH_out(16)
) 
SU2 (
    .clk  (clk      ),  
    .rst  (rst      ),  
    .di_en  (su1_do_en  ),  
    .di_re  (su1_do_re  ),  
    .di_im  (su1_do_im  ),  
    .do_en  (do_en  ),  
    .do_re  (do_re  ),  
    .do_im  (do_im  )   
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        output_counter <= 4'd0;
    end
    else if(output_counter==4'd15) begin
        if(tx_counter==2'd2) begin
            output_counter <= 4'd2;
        end
    end
    else if(do_en) begin
        output_counter <= output_counter + 4'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        tx_counter <= 2'd0;
    end
    else if(output_counter==4'd15) begin
        tx_counter <= tx_counter + 2'd1;
    end
    else begin
        tx_counter <= 2'd0;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        done_counter <= 5'd0;
    end
    else if(rst_r) begin
        done_counter <= 5'd1;
    end
    else if(~fir_valid) begin
        done_counter <= done_counter + 5'd1;
    end
end

integer i;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for (i = 0;i<16 ;i=i+1 ) 
        begin
        output_buffer_re[i] <= 16'd0;
        output_buffer_im[i] <= 16'd0;
        end
    end
    else if(done_counter>5'd21) begin
        for (i = 0;i<16 ;i=i+1 ) 
        begin
        output_buffer_re[i] <= output_buffer_re[i];
        output_buffer_im[i] <= output_buffer_im[i];
        end
    end
    else if(do_en&&tx_counter==2'd0)begin
        output_buffer_re[output_counter] <= do_re[23:8];
        output_buffer_im[output_counter] <= do_im[23:8];
    end
    else if(flag) begin
        output_buffer_re[0] <= output_temp_re_1;
        output_buffer_im[0] <= output_temp_im_1;
        output_buffer_re[1] <= output_temp_re_2;
        output_buffer_im[1] <= output_temp_im_2;
        output_buffer_re[output_counter] <= do_re[23:8];
        output_buffer_im[output_counter] <= do_im[23:8];
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        output_temp_im_1 <= 16'd0;
        output_temp_re_1 <= 16'd0;
    end
    else if(tx_counter==2'd1&&do_en) begin
        output_temp_im_1 <= do_im[23:8];
        output_temp_re_1 <= do_re[23:8];
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        output_temp_im_2 <= 16'd0;
        output_temp_re_2 <= 16'd0;
    end
    else if(tx_counter==2'd2&&do_en) begin
        output_temp_im_2 <= do_im[23:8];
        output_temp_re_2 <= do_re[23:8];
    end
end


assign fft_d0  = (tx_counter==2'd1) ? output_buffer_re[ 0] : output_buffer_im[ 0];
assign fft_d1  = (tx_counter==2'd1) ? output_buffer_re[ 8] : output_buffer_im[ 8];
assign fft_d2  = (tx_counter==2'd1) ? output_buffer_re[ 4] : output_buffer_im[ 4];
assign fft_d3  = (tx_counter==2'd1) ? output_buffer_re[ 12] : output_buffer_im[ 12];
assign fft_d4  = (tx_counter==2'd1) ? output_buffer_re[ 2] : output_buffer_im[ 2];
assign fft_d5  = (tx_counter==2'd1) ? output_buffer_re[ 10] : output_buffer_im[ 10];
assign fft_d6  = (tx_counter==2'd1) ? output_buffer_re[ 6] : output_buffer_im[ 6];
assign fft_d7  = (tx_counter==2'd1) ? output_buffer_re[ 14] : output_buffer_im[ 14];
assign fft_d8  = (tx_counter==2'd1) ? output_buffer_re[ 1] : output_buffer_im[ 1];
assign fft_d9  = (tx_counter==2'd1) ? output_buffer_re[ 9] : output_buffer_im[ 9];
assign fft_d10 = (tx_counter==2'd1) ? output_buffer_re[ 5] : output_buffer_im[ 5];
assign fft_d11 = (tx_counter==2'd1) ? output_buffer_re[13] : output_buffer_im[13];
assign fft_d12 = (tx_counter==2'd1) ? output_buffer_re[3]  : output_buffer_im[3];
assign fft_d13 = (tx_counter==2'd1) ? output_buffer_re[11] : output_buffer_im[11];
assign fft_d14 = (tx_counter==2'd1) ? output_buffer_re[7] : output_buffer_im[7];
assign fft_d15 = (tx_counter==2'd1) ? output_buffer_re[15] : output_buffer_im[15];

assign fft_valid = (tx_counter==2'd1) || (tx_counter==2'd2);
assign done = done_r;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        done_r <= 1'b0;
    end
    else begin
        done_r <= (done_counter>5'd21)? 1'b1:1'b0;
    end
end


endmodule