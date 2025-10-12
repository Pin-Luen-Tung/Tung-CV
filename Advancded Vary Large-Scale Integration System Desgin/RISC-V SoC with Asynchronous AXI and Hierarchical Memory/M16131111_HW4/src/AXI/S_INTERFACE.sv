

module S_INTERFACE(

    input  logic                      s_clk,
    input  logic                      s_rst,
    input  logic                      axi_clk,
    input  logic                      axi_rst,
    // AW 
    output logic [`AXI_IDS_BITS -1:0] AWID_S,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S,
	output logic [`AXI_LEN_BITS -1:0] AWLEN_S,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	output logic [1:0]                AWBURST_S,
	output logic                      AWVALID_S,
    input  logic                      AWREADY_S,

    input  logic [`AXI_IDS_BITS -1:0] AWID_AXI,
	input  logic [`AXI_ADDR_BITS-1:0] AWADDR_AXI,
	input  logic [`AXI_LEN_BITS -1:0] AWLEN_AXI,
	input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_AXI,
	input  logic [1:0]                AWBURST_AXI,
	input  logic                      AWVALID_AXI,
    output logic                      AWREADY_AXI,
    // W 
    output logic [`AXI_DATA_BITS-1:0] WDATA_S,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S,
	output logic                      WLAST_S,
	output logic                      WVALID_S,
    input  logic                      WREADY_S,

    input  logic [`AXI_DATA_BITS-1:0] WDATA_AXI,
	input  logic [`AXI_STRB_BITS-1:0] WSTRB_AXI,
	input  logic                      WLAST_AXI,
	input  logic                      WVALID_AXI,
    output logic                      WREADY_AXI,
    // AR 
    output logic [`AXI_IDS_BITS -1:0] ARID_S,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S,
    output logic [`AXI_LEN_BITS -1:0] ARLEN_S,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S,
    output logic [1:0]                ARBURST_S,
    output logic                      ARVALID_S,
    input  logic                      ARREADY_S,

    input  logic [`AXI_IDS_BITS -1:0] ARID_AXI,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_AXI,
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_AXI,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_AXI,
    input  logic [1:0]                ARBURST_AXI,
    input  logic                      ARVALID_AXI,
    output logic                      ARREADY_AXI,
    // R 
    input  logic [`AXI_IDS_BITS -1:0] RID_S,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_S,
	input  logic [1:0]                RRESP_S,
	input  logic                      RLAST_S,
	input  logic                      RVALID_S,
    output logic                      RREADY_S,

    output logic [`AXI_IDS_BITS -1:0] RID_AXI,
    output logic [`AXI_DATA_BITS-1:0] RDATA_AXI,
	output logic [1:0]                RRESP_AXI,
	output logic                      RLAST_AXI,
	output logic                      RVALID_AXI,
    input  logic                      RREADY_AXI,
    // B 
    input  logic [`AXI_IDS_BITS -1:0] BID_S,
    input  logic [1:0]                BRESP_S,
    input  logic                      BVALID_S,
    output logic                      BREADY_S,

    output logic [`AXI_IDS_BITS -1:0] BID_AXI,
    output logic [1:0]                BRESP_AXI,
    output logic                      BVALID_AXI,
    input  logic                      BREADY_AXI
);

//////////////////////////////////
//
//
//       AW channal(AW_FIFO)
//
//
///////////////////////////////////

logic  aw_fifo_full;
logic  aw_fifo_empty;
logic  handshake_AW_AXI;
assign AWREADY_AXI     = ~aw_fifo_full;
assign AWVALID_S         = ~aw_fifo_empty;
assign handshake_AW_AXI = AWVALID_AXI & AWREADY_AXI;

ASYN_FIFO  #(
    .Databits(49), 
    .Addrbits(2)
    ) 
    aw_fifo_a2s(
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (handshake_AW_AXI),
    .wdata ({AWID_AXI,AWADDR_AXI,AWLEN_AXI,AWSIZE_AXI,AWBURST_AXI}),
    .wfull (aw_fifo_full),

    .rclk  (s_clk),
    .rrst  (s_rst),
    .rpop  (AWREADY_S),
    .rdata ({AWID_S,AWADDR_S,AWLEN_S,AWSIZE_S,AWBURST_S}),
    .rempty(aw_fifo_empty)
);

//////////////////////////////////
//
//
//       W channal(W_FIFO)
//
//
///////////////////////////////////

logic  w_fifo_full;
logic  w_fifo_empty;
logic  handshake_W_AXI;
assign WREADY_AXI     = ~w_fifo_full;
assign WVALID_S        = ~w_fifo_empty;
assign handshake_W_AXI = WVALID_AXI & WREADY_AXI;

ASYN_FIFO  #(
    .Databits(37), 
    .Addrbits(2)
    ) 
    w_fifo_a2s(
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (handshake_W_AXI),
    .wdata ({WDATA_AXI,WSTRB_AXI,WLAST_AXI}),
    .wfull (w_fifo_full),

    .rclk  (s_clk),
    .rrst  (s_rst),
    .rpop  (WREADY_S),
    .rdata ({WDATA_S,WSTRB_S,WLAST_S}),
    .rempty(w_fifo_empty)
);

//////////////////////////////////
//
//
//       AR channal(AR_FIFO)
//
//
///////////////////////////////////

logic  ar_fifo_full;
logic  ar_fifo_empty;
logic  handshake_AR_AXI;
assign ARREADY_AXI     = ~ar_fifo_full;
assign ARVALID_S         = ~ar_fifo_empty;
assign handshake_AR_AXI = ARVALID_AXI & ARREADY_AXI;

ASYN_FIFO  #(
    .Databits(49), 
    .Addrbits(2)
    ) 
    ar_fifo_a2s(
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (handshake_AR_AXI),
    .wdata ({ARID_AXI,ARADDR_AXI,ARLEN_AXI,ARSIZE_AXI,ARBURST_AXI}),
    .wfull (ar_fifo_full),

    .rclk  (s_clk),
    .rrst  (s_rst),
    .rpop  (ARREADY_S),
    .rdata ({ARID_S,ARADDR_S,ARLEN_S,ARSIZE_S,ARBURST_S}),
    .rempty(ar_fifo_empty)
);

//////////////////////////////////
//
//
//       R channal(R_FIFO)
//
//
///////////////////////////////////

logic  r_fifo_full;
logic  r_fifo_empty;
logic  handshake_R_AXI;
assign RREADY_S      = ~r_fifo_full;
assign RVALID_AXI  = ~r_fifo_empty;
assign handshake_R_AXI = RVALID_AXI & RREADY_AXI;

ASYN_FIFO  #(
    .Databits(43), 
    .Addrbits(2)
    ) 
    r_fifo_s2a(
    .wclk  (s_clk),
    .wrst  (s_rst),
    .wpush (RVALID_S & RREADY_S),
    .wdata ({RID_S,RDATA_S,RRESP_S,RLAST_S}),
    .wfull (r_fifo_full),

    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (handshake_R_AXI),
    .rdata ({RID_AXI,RDATA_AXI,RRESP_AXI,RLAST_AXI}),
    .rempty(r_fifo_empty)
);

//////////////////////////////////
//
//
//       B channal(B_FIFO)
//
//
///////////////////////////////////

logic  b_fifo_full;
logic  b_fifo_empty;
logic  handshake_B_AXI;
assign BREADY_S         = ~b_fifo_full;
assign BVALID_AXI     = ~b_fifo_empty;
assign handshake_B_AXI = BVALID_AXI & BREADY_AXI;

ASYN_FIFO  #(
    .Databits(10), 
    .Addrbits(2)
    ) 
    b_fifo_s2a(
    .wclk  (s_clk),
    .wrst  (s_rst),
    .wpush (BVALID_S),
    .wdata ({BID_S,BRESP_S}),
    .wfull (b_fifo_full),

    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (handshake_B_AXI),
    .rdata ({BID_AXI,BRESP_AXI}),
    .rempty(b_fifo_empty)
);


endmodule 