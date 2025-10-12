
module M_INTERFACE (
    input  logic                      m_clk,
    input  logic                      m_rst,
    input  logic                      axi_clk,
    input  logic                      axi_rst,
    // AW 
    input  logic [`AXI_ID_BITS  -1:0] AWID_M,
	input  logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	input  logic [`AXI_LEN_BITS -1:0] AWLEN_M,
	input  logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	input  logic [1:0]                AWBURST_M,
	input  logic                      AWVALID_M,
    output logic                      AWREADY_M,

    output logic [`AXI_ID_BITS  -1:0] AWID_AXI,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_AXI,
	output logic [`AXI_LEN_BITS -1:0] AWLEN_AXI,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_AXI,
	output logic [1:0]                AWBURST_AXI,
	output logic                      AWVALID_AXI,
    input  logic                      AWREADY_AXI,
    // W 
    input  logic [`AXI_DATA_BITS-1:0] WDATA_M,
	input  logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	input  logic                      WLAST_M,
	input  logic                      WVALID_M,
    output logic                      WREADY_M,

    output logic [`AXI_DATA_BITS-1:0] WDATA_AXI,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_AXI,
	output logic                      WLAST_AXI,
	output logic                      WVALID_AXI,
    input  logic                      WREADY_AXI,
    // AR 
    input  logic [`AXI_ID_BITS  -1:0] ARID_M,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
    input  logic [`AXI_LEN_BITS -1:0] ARLEN_M,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
    input  logic [1:0]                ARBURST_M,
    input  logic                      ARVALID_M,
    output logic                      ARREADY_M,

    output logic [`AXI_ID_BITS  -1:0] ARID_AXI,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_AXI,
    output logic [`AXI_LEN_BITS -1:0] ARLEN_AXI,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_AXI,
    output logic [1:0]                ARBURST_AXI,
    output logic                      ARVALID_AXI,
    input  logic                      ARREADY_AXI,
    // R 
    output logic [`AXI_ID_BITS  -1:0] RID_M,
    output logic [`AXI_DATA_BITS-1:0] RDATA_M,
	output logic [1:0]                RRESP_M,
	output logic                      RLAST_M,
	output logic                      RVALID_M,
    input  logic                      RREADY_M,

    input  logic [`AXI_ID_BITS  -1:0] RID_AXI,
    input  logic [`AXI_DATA_BITS-1:0] RDATA_AXI,
	input  logic [1:0]                RRESP_AXI,
	input  logic                      RLAST_AXI,
	input  logic                      RVALID_AXI,
    output logic                      RREADY_AXI,
    // B 
    output logic [`AXI_ID_BITS  -1:0] BID_M,
    output logic [1:0]                BRESP_M,
    output logic                      BVALID_M,
    input  logic                      BREADY_M,

    input  logic [`AXI_ID_BITS  -1:0] BID_AXI,
    input  logic [1:0]                BRESP_AXI,
    input  logic                      BVALID_AXI,
    output logic                      BREADY_AXI
);

//////////////////////////////////
//
//
//       AW channal(AW_FIFO)
//
//
///////////////////////////////////

logic aw_fifo_full;
logic aw_fifo_empty;
logic handshake_AW_AXI;
assign AWREADY_M         = ~aw_fifo_full;
assign AWVALID_AXI     = ~aw_fifo_empty;
assign handshake_AW_AXI = AWVALID_AXI & AWREADY_AXI;

ASYN_FIFO #(
    .Databits(45),
    .Addrbits(2)
    )
    aw_fifo_m2a(
    .wclk  (m_clk),
    .wrst  (m_rst),
    .wpush (AWVALID_M),
    .wdata ({AWID_M,AWADDR_M,AWLEN_M,AWSIZE_M,AWBURST_M}),
    .wfull (aw_fifo_full),

    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (handshake_AW_AXI),
    .rdata ({AWID_AXI,AWADDR_AXI,AWLEN_AXI,AWSIZE_AXI,AWBURST_AXI}),
    .rempty(aw_fifo_empty)
);

//////////////////////////////////
//
//
//       W channal(W_FIFO)
//
//
///////////////////////////////////

logic w_fifo_full;
logic w_fifo_empty;
logic handshake_W_AXI;
assign WREADY_M         = ~w_fifo_full;
assign WVALID_AXI     = ~w_fifo_empty;
assign handshake_W_AXI = WVALID_AXI & WREADY_AXI;

ASYN_FIFO #(
    .Databits(37),
    .Addrbits(2)
    ) 
    w_fifo_m2s(
    .wclk  (m_clk),
    .wrst  (m_rst),
    .wpush (WVALID_M),
    .wdata ({WDATA_M,WSTRB_M,WLAST_M}),
    .wfull (w_fifo_full),

    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (handshake_W_AXI),
    .rdata ({WDATA_AXI,WSTRB_AXI,WLAST_AXI}),
    .rempty(w_fifo_empty)
);

//////////////////////////////////
//
//
//       AR channal(AR_FIFO)
//
//
///////////////////////////////////

logic ar_fifo_full;
logic ar_fifo_empty;
logic handshake_AR_AXI;
assign ARREADY_M        = ~ar_fifo_full;
assign ARVALID_AXI     = ~ar_fifo_empty;
assign handshake_AR_AXI = ARVALID_AXI & ARREADY_AXI;

ASYN_FIFO  #(
    .Databits(45),
    .Addrbits(2)
    ) 
ar_fifo_m2a(
    .wclk  (m_clk),
    .wrst  (m_rst),
    .wpush (ARVALID_M),
    .wdata ({ARID_M,ARADDR_M,ARLEN_M,ARSIZE_M,ARBURST_M}),
    .wfull (ar_fifo_full),

    .rclk  (axi_clk),
    .rrst  (axi_rst),
    .rpop  (handshake_AR_AXI),
    .rdata ({ARID_AXI,ARADDR_AXI,ARLEN_AXI,ARSIZE_AXI,ARBURST_AXI}),
    .rempty(ar_fifo_empty)
);

//////////////////////////////////
//
//
//       R channal(R_FIFO)
//
//
///////////////////////////////////

logic r_fifo_full;
logic r_fifo_empty;
logic handshake_R_AXI;
assign RREADY_AXI     = ~r_fifo_full;
assign RVALID_M         = ~r_fifo_empty;
assign handshake_R_AXI = RVALID_AXI & RREADY_AXI;

ASYN_FIFO  #(
    .Databits(39),
    .Addrbits(2)
    )
    r_fifo_a2m(
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (handshake_R_AXI),
    .wdata ({RID_AXI,RDATA_AXI,RRESP_AXI,RLAST_AXI}),
    .wfull (r_fifo_full),

    .rclk  (m_clk),
    .rrst  (m_rst),
    .rpop  (RREADY_M),
    .rdata ({RID_M,RDATA_M,RRESP_M,RLAST_M}),
    .rempty(r_fifo_empty)
);

//////////////////////////////////
//
//
//       B channal(B_FIFO)
//
//
///////////////////////////////////

logic b_fifo_full;
logic b_fifo_empty;
logic handshakeB_AXI;
assign BREADY_AXI     = ~b_fifo_full;
assign BVALID_M         = ~b_fifo_empty;
assign handshakeB_AXI = BVALID_AXI & BREADY_AXI;

ASYN_FIFO  #(
    .Databits(6), 
    .Addrbits(2)
    )
    B_a2m(
    .wclk  (axi_clk),
    .wrst  (axi_rst),
    .wpush (handshakeB_AXI),
    .wdata ({BID_AXI,BRESP_AXI}),
    .wfull (b_fifo_full),

    .rclk  (m_clk),
    .rrst  (m_rst),
    .rpop  (BREADY_M),
    .rdata ({BID_M,BRESP_M}),
    .rempty(b_fifo_empty)
);

endmodule