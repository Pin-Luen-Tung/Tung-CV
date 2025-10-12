module ROM_wrapper #(
    parameter ADDR_BEG  =	32'h0000_0000,
    parameter ADDR_END  =	32'h0000_ffff
)(
// System
	input ACLK,
	input ARESETn,
// AXI
	input [`AXI_IDS_BITS-1:0]  ARID_ROM,
	input [`AXI_ADDR_BITS-1:0] ARADDR_ROM,
	input [`AXI_LEN_BITS-1:0]  ARLEN_ROM,   // Not support
	input [`AXI_SIZE_BITS-1:0] ARSIZE_ROM,  // Not support
	input [1:0]                ARBURST_ROM, // Not support
	input                      ARVALID_ROM,
	output logic               ARREADY_ROM,	

	output logic [`AXI_IDS_BITS-1:0]  RID_ROM,
	output logic [`AXI_DATA_BITS-1:0] RDATA_ROM,
	output logic [1:0]                RRESP_ROM,
	output logic                      RLAST_ROM,
	output logic                      RVALID_ROM,
	input                             RREADY_ROM,
// ROM interface
	input [31:0] DO,
	output logic CS,
	output logic OE,
	output logic [11:0] A
);
localparam AR = 2'd0;
localparam PRE_R1 = 2'd1 ;
localparam PRE_R2 = 2'd2 ;
localparam R = 2'd3;

logic handshake_flag_S_AR;
logic handshake_flag_S_R;
logic [1:0] current_state;
logic [1:0] next_state;

assign handshake_flag_S_AR = ARVALID_ROM & ARREADY_ROM;
assign handshake_flag_S_R = RVALID_ROM & RREADY_ROM;

//AR Reg
logic [`AXI_IDS_BITS-1:0] ARID_r;
logic [`AXI_ADDR_BITS-1:0] ARADDR_r;
logic [`AXI_ADDR_BITS-1:0] ARADDR_com;
logic [`AXI_LEN_BITS-1:0]  ARLEN_r;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_r;
logic [`AXI_DATA_BITS-1:0] RDATA_r;
logic [1:0] ARBURST_r;



always_comb begin
    case (current_state)
        AR : next_state = (handshake_flag_S_AR) ? PRE_R1 : AR;
        PRE_R1 : next_state = PRE_R2;
        PRE_R2 : next_state = R;
        R : next_state = (handshake_flag_S_R && (ARLEN_r == 0)) ? AR :(handshake_flag_S_R) ? PRE_R1:R;
        default: next_state = R;
    endcase
end




always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        current_state <= AR;
    end
    else begin
        current_state <= next_state;
    end
end
// AR reg
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn)begin
          ARID_r <=8'b0;
          ARADDR_r <=32'd0;
          ARLEN_r <=4'd0;
          ARSIZE_r <=3'd0;
          RDATA_r <= 32'd0;
    end
    else if(handshake_flag_S_AR)begin
          ARID_r <= ARID_ROM;
          ARADDR_r <= (ARADDR_ROM - ADDR_BEG);
          ARLEN_r <= ARLEN_ROM ;
          ARSIZE_r <= ARSIZE_ROM;
          RDATA_r <= DO;
    end
    else if(handshake_flag_S_R)begin 
          ARADDR_r <= (ARADDR_r + (1 << ARSIZE_r) -ADDR_BEG);
          ARLEN_r <= ARLEN_r - 1 ;
          RDATA_r <= DO;
    end
    else if(current_state == PRE_R2)begin
          RDATA_r <= DO;
    end
end

assign RID_ROM = ARID_r;

assign RDATA_ROM = RDATA_r;



assign RRESP = 2'b00;

assign RLAST_ROM = (current_state == R) & (ARLEN_r == 0);

assign RVALID_S = (current_state == R);

assign ARREADY_ROM = (current_state == AR);
assign RVALID_ROM = (current_state == R);
assign CS = 1;
assign OE = 1;
assign A = ARADDR_r[12:2];


endmodule