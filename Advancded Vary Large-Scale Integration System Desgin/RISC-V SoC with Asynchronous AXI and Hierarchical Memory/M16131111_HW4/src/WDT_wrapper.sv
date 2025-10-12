
module WDT_wrapper
(
	input wire clk,
	input wire rst,
		
	// WRITE
	input wire [`AXI_IDS_BITS-1:0] AWID_WDT,
	input wire[`AXI_ADDR_BITS-1:0] AWADDR_WDT,
	input wire[`AXI_LEN_BITS-1:0] AWLEN_WDT,
	input wire[`AXI_SIZE_BITS-1:0] AWSIZE_WDT,
	input wire[1:0] AWBURST_WDT,
	input wire AWVALID_WDT,
	output logic AWREADY_WDT,
	input wire[`AXI_DATA_BITS-1:0] WDATA_WDT,
	input wire[`AXI_STRB_BITS-1:0] WSTRB_WDT,
	input wire WLAST_WDT,
	input wire WVALID_WDT,
	output logic WREADY_WDT,
	output logic [`AXI_IDS_BITS-1:0] BID_WDT,
	output logic [1:0] BRESP_WDT,
	output logic BVALID_WDT,
	input wire BREADY_WDT,
	
	// READ
	input wire [`AXI_IDS_BITS-1:0] ARID_WDT,
	input wire [`AXI_ADDR_BITS-1:0] ARADDR_WDT,
	input wire [`AXI_LEN_BITS-1:0] ARLEN_WDT,
	input wire [`AXI_SIZE_BITS-1:0] ARSIZE_WDT,
	input [1:0] ARBURST_WDT,
	input ARVALID_WDT,
	output logic ARREADY_WDT,
	output logic [`AXI_IDS_BITS-1:0] RID_WDT,
	output logic [`AXI_DATA_BITS-1:0] RDATA_WDT,
	output logic [1:0] RRESP_WDT,
	output logic RLAST_WDT,
	output logic RVALID_WDT,
	input  wire RREADY_WDT,
	
	//connect to CPU
	output logic WTO
);

localparam IDLE = 2'd0;
localparam RDATA = 2'd1;
localparam WDATA = 2'd2;
localparam B = 2'd3;
localparam ADDR_BEGIN = 32'h1001_0000;
localparam ADDR_END   = 32'h1001_03ff;




logic [`AXI_IDS_BITS-1:0]  ARID_r;
logic [`AXI_ADDR_BITS-1:0] ARADDR_r;
logic [`AXI_LEN_BITS-1:0]  ARLEN_r;
logic [`AXI_LEN_BITS-1:0]  R_burst_r;

logic [`AXI_IDS_BITS-1:0] AWID_r;
logic [`AXI_ADDR_BITS-1:0] AWADDR_r;
logic [`AXI_LEN_BITS-1:0] AWLEN_r;
logic [`AXI_LEN_BITS-1:0] W_burst_r;

logic WDEN;
logic WDLIVE;
logic [31:0] WTOCNT;


logic handshake_flag_S_AR;
logic handshake_flag_S_R;
logic handshake_flag_S_AW;
logic handshake_flag_S_W;
logic handshake_flag_S_B;
//state machine
logic [1:0] current_state; 
logic [1:0] next_state;


assign RID_WDT = ARID_r;
assign ARREADY_WDT = (current_state == IDLE)? 1'b1 : 1'b0;
assign RVALID_WDT = (current_state == RDATA)? 1'b1 : 1'b0;
assign RDATA_WDT = 32'd0;
assign RLAST_WDT = (RVALID_WDT && (R_burst_r==ARLEN_r))? 1'b1 : 1'b0;
assign RRESP_WDT = ((ARADDR_r>=ADDR_BEGIN) && (ARADDR_r<=ADDR_END))? 2'b00 : 2'b11;
assign AWREADY_WDT = (current_state == IDLE) ? 1'b1: 1'b0;
assign WREADY_WDT = (current_state == WDATA) ? 1'b1: 1'b0;
assign BRESP_WDT = ((ARADDR_r>=ADDR_BEGIN) && (ARADDR_r<=ADDR_END))? 2'b00 : 2'b11;


always_ff @(posedge clk or posedge rst)begin
	if(rst)
		current_state <= IDLE;
	else 
		current_state <= next_state;
end

assign handshake_flag_S_AR = ARREADY_WDT & ARVALID_WDT;
assign handshake_flag_S_AW = AWVALID_WDT & AWREADY_WDT;
assign handshake_flag_S_R = RVALID_WDT & RREADY_WDT;
assign handshake_flag_S_W = WVALID_WDT & WREADY_WDT;
assign handshake_flag_S_B = BVALID_WDT & BREADY_WDT;


always_comb begin
	case (current_state)
        IDLE 	:next_state = (handshake_flag_S_AR) ? RDATA :(handshake_flag_S_AW) ? WDATA:IDLE;
		RDATA :next_state = (handshake_flag_S_R & RLAST_WDT) ? IDLE : RDATA;
		WDATA :next_state = (handshake_flag_S_W & WLAST_WDT) ? B : WDATA;
		B  :next_state = (handshake_flag_S_B) ? IDLE : B;
		default :next_state = IDLE;
	endcase
end

////////////////////////////////////////
//
//         AXI read process control
//
////////////////////////////////////////

always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		R_burst_r <= 4'd0;
	end
	else if(handshake_flag_S_R)begin
		if(RLAST_WDT)begin
			R_burst_r <= 4'd0;
		end
		else begin
			R_burst_r <= R_burst_r + 4'd1;
		end
	end
end

always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		ARID_r   <= 8'd0;
		ARADDR_r <= 32'd0;
		ARLEN_r <= 4'd0;
	end
	else if(handshake_flag_S_AR)begin
		ARID_r   <= ARID_WDT;
		ARADDR_r <= ARADDR_WDT;
		ARLEN_r  <= ARLEN_WDT;
	end
end

////////////////////////////////////////
//
//         AXI write process control
//
////////////////////////////////////////

always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		AWADDR_r <= 32'd0;
		AWID_r   <= 8'd0;
		AWLEN_r  <= 4'd0;
	end
	else if(handshake_flag_S_AW)begin
		AWADDR_r <= AWADDR_WDT;
		AWID_r   <= AWID_WDT;
		AWLEN_r  <= AWLEN_WDT;
	end
end

always_ff @(posedge clk or posedge rst)begin
	if(rst)
		BVALID_WDT <= 1'd0;
	else if(next_state == B)
		BVALID_WDT <= 1'd1;
	else
		BVALID_WDT <= 1'd0;
end

always_ff @(posedge clk or posedge rst)begin
	if(rst)
		BID_WDT <= 8'd0;
	else if(next_state == B)
		BID_WDT <= AWID_WDT;
end

///////////////////////////////////////////////////
//
//         WDT data in CDC　ASYFIFO
//
//////////////////////////////////////////////////////



always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		WDEN 	   <= 1'd0;
	end
	else if(current_state == WDATA && AWADDR_r == 32'h1001_0100)begin
		WDEN 	   <= WDATA_WDT[0];
	end
end

always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		WDLIVE       <= 1'd0;
	end
	else if(current_state == WDATA && AWADDR_r == 32'h1001_0200)begin
		WDLIVE       <= WDATA_WDT[0];
	end
end

always_ff @(posedge clk or posedge rst)begin
	if(rst)begin
		WTOCNT       <= 32'd0;
	end
	else if(handshake_flag_S_W && AWADDR_r == 32'h1001_0300)begin
		WTOCNT       <= WDATA_WDT;
	end
end


WDT wdt(
    .clk(clk),
    .rst(rst),
    .WDEN(WDEN),
    .WDLIVE(WDLIVE),
    .WTOCNT(WTOCNT),
    .WTO(WTO)
);





endmodule