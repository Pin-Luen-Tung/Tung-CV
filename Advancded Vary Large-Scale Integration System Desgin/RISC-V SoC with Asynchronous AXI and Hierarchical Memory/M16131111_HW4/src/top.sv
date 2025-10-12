`include "../include/AXI_define.svh"
`include "../include/def.svh"

module top(
	// System signals
	input  logic           cpu_clk,
  	input  logic           axi_clk,
  	input  logic           rom_clk,
  	input  logic           dram_clk,
  	input  logic           cpu_rst,
  	input  logic           axi_rst,
  	input  logic           rom_rst,
  	input  logic           dram_rst,

	// Connect with ROM
	input logic [31:0] ROM_out,
	output logic ROM_read,
	output logic ROM_enable,
	output logic [11:0] ROM_address,

	// Connect with DRAM
	input logic [31:0] DRAM_Q, //DRAM data output
	input logic DRAM_valid, //DRAM data output valid
	output logic DRAM_CSn,
	output logic [3:0] DRAM_WEn,
	output logic DRAM_RASn, //DRAM row access strobe
	output logic DRAM_CASn, //DRAM column access strobe
	output logic [10:0] DRAM_A, //DRAM address input
	output logic [31:0] DRAM_D //DRAM data input
	
);

///////////////////////////////////////////////////////////////////


   logic WTO_flip_flop1;
   logic WTO_flip_flop2;
   logic WTO_r;
//SLAVE INTERFACE FOR MASTERS

	// M2 is DNA
	//READ ADDRESS                    
	logic[`AXI_ID_BITS-1:0] 	ARID_M2   ;
	logic[`AXI_ADDR_BITS-1:0] 	ARADDR_M2 ;
	logic[`AXI_LEN_BITS-1:0] 	ARLEN_M2  ;
	logic[`AXI_SIZE_BITS-1:0] 	ARSIZE_M2 ;
	logic[1:0] 					ARBURST_M2;
	logic						ARVALID_M2;
	logic 						ARREADY_M2;										  
	
	//READ DATA
	logic [`AXI_ID_BITS-1:0] 	RID_M2   ;
	logic [`AXI_DATA_BITS-1:0] 	RDATA_M2  ;
	logic [1:0] 				RRESP_M2  ;
	logic 						RLAST_M2  ;
	logic 						RVALID_M2 ;
	logic						RREADY_M2 ;

	//WRITE ADDRESS
	logic [`AXI_ID_BITS-1:0] 	AWID_M2;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_M2;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_M2;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_M2;
	logic[1:0] 					AWBURST_M2;
	logic 						AWVALID_M2;
	logic 						AWREADY_M2;
	
	//WRITE DATA
	logic[`AXI_DATA_BITS-1:0] 	WDATA_M2;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_M2;
	logic 						WLAST_M2;
	logic 						WVALID_M2;
	logic 						WREADY_M2;
	
	//WRITE RESPONSE
	logic [`AXI_ID_BITS-1:0] 	BID_M2;
	logic [1:0] 				BRESP_M2;
	logic 						BVALID_M2;
	logic						BREADY_M2;

///////////////////////////////////////////////////////////////////

	// M1 is DM
	//READ ADDRESS1                       
	logic[`AXI_ID_BITS-1:0] 	ARID_M1   ;
	logic[`AXI_ADDR_BITS-1:0] 	ARADDR_M1 ;
	logic[`AXI_LEN_BITS-1:0] 	ARLEN_M1  ;
	logic[`AXI_SIZE_BITS-1:0] 	ARSIZE_M1 ;
	logic[1:0] 					ARBURST_M1;
	logic						ARVALID_M1;
	logic 						ARREADY_M1;										  
	
	//READ DATA1
	logic [`AXI_ID_BITS-1:0] 	RID_M1   ;
	logic [`AXI_DATA_BITS-1:0] 	RDATA_M1  ;
	logic [1:0] 				RRESP_M1  ;
	logic 						RLAST_M1  ;
	logic 						RVALID_M1 ;
	logic						RREADY_M1 ;

	//WRITE ADDRESS
	logic [`AXI_ID_BITS-1:0] 	AWID_M1;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_M1;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_M1;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_M1;
	logic[1:0] 					AWBURST_M1;
	logic 						AWVALID_M1;
	logic 						AWREADY_M1;
	
	//WRITE DATA
	logic[`AXI_DATA_BITS-1:0] 	WDATA_M1;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_M1;
	logic 						WLAST_M1;
	logic 						WVALID_M1;
	logic 						WREADY_M1;
	
	//WRITE RESPONSE
	logic [`AXI_ID_BITS-1:0] 	BID_M1;
	logic [1:0] 				BRESP_M1;
	logic 						BVALID_M1;
	logic						BREADY_M1;
	
///////////////////////////////////////////////////////////////////

	// M0 is IM
	//READ ADDRESS
	logic [`AXI_ID_BITS-1:0] 	ARID_M0;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_M0;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_M0;
	logic[`AXI_SIZE_BITS-1:0] 	ARSIZE_M0;
	logic[1:0] 					ARBURST_M0;
	logic						ARVALID_M0;
	logic 						ARREADY_M0;										  
	
	//READ DATA                     
	logic [`AXI_ID_BITS-1:0] 	RID_M0   ;
	logic [`AXI_DATA_BITS-1:0] 	RDATA_M0  ;
	logic [1:0] 				RRESP_M0  ;
	logic 						RLAST_M0  ;
	logic 						RVALID_M0 ;
	logic						RREADY_M0 ;	
	
///////////////////////////////////////////////////////////////////	

//MASTER INTERFACE FOR SLAVES
// S0 is ROM
	//READ
	logic [`AXI_IDS_BITS-1:0] 	ARID_S0;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S0;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S0;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S0;
	logic [1:0]					ARBURST_S0;
	logic 						ARVALID_S0;
	logic 						ARREADY_S0;
	logic[`AXI_IDS_BITS-1:0] 	RID_S0;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S0;
	logic[1:0] 					RRESP_S0;
	logic						RLAST_S0;
	logic						RVALID_S0;
	logic 						RREADY_S0;

// S1 is IM
	//READ 
	logic [`AXI_IDS_BITS-1:0] 	ARID_S1;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S1;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S1;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S1;
	logic [1:0] 				ARBURST_S1;
	logic 						ARVALID_S1;
	logic 						ARREADY_S1;
	logic[`AXI_IDS_BITS-1:0] 	RID_S1;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S1;
	logic[1:0] 					RRESP_S1;
	logic						RLAST_S1;
	logic						RVALID_S1;
	logic 						RREADY_S1;

	//WRITE 
	logic[`AXI_IDS_BITS-1:0] 	AWID_S1;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_S1;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_S1;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_S1;
	logic[1:0] 					AWBURST_S1;
	logic 						AWVALID_S1;
	logic 						AWREADY_S1;
	logic[`AXI_DATA_BITS-1:0] 	WDATA_S1;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_S1;
	logic 						WLAST_S1;
	logic 						WVALID_S1;
	logic 						WREADY_S1;
	logic[`AXI_IDS_BITS-1:0] 	BID_S1;
	logic[1:0] 					BRESP_S1;
	logic 						BVALID_S1;
	logic 						BREADY_S1;

// S2 is DM
	//READ 
	logic [`AXI_IDS_BITS-1:0] 	ARID_S2;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S2;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S2;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S2;
	logic [1:0] 				ARBURST_S2;
	logic 						ARVALID_S2;
	logic 						ARREADY_S2;
	logic[`AXI_IDS_BITS-1:0] 	RID_S2;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S2;
	logic[1:0] 					RRESP_S2;
	logic						RLAST_S2;
	logic						RVALID_S2;
	logic 						RREADY_S2;

	//WRITE 
	logic[`AXI_IDS_BITS-1:0] 	AWID_S2;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_S2;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_S2;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_S2;
	logic[1:0] 					AWBURST_S2;
	logic 						AWVALID_S2;
	logic 						AWREADY_S2;
	logic[`AXI_DATA_BITS-1:0] 	WDATA_S2;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_S2;
	logic 						WLAST_S2;
	logic 						WVALID_S2;
	logic 						WREADY_S2;
	logic[`AXI_IDS_BITS-1:0] 	BID_S2;
	logic[1:0] 					BRESP_S2;
	logic 						BVALID_S2;
	logic 						BREADY_S2;

// S3 is DMA
	//READ 
	logic [`AXI_IDS_BITS-1:0] 	ARID_S3;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S3;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S3;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S3;
	logic [1:0] 				ARBURST_S3;
	logic 						ARVALID_S3;
	logic 						ARREADY_S3;
	logic[`AXI_IDS_BITS-1:0] 	RID_S3;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S3;
	logic[1:0] 					RRESP_S3;
	logic						RLAST_S3;
	logic						RVALID_S3;
	logic 						RREADY_S3;

	//WRITE 
	logic[`AXI_IDS_BITS-1:0] 	AWID_S3;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_S3;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_S3;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_S3;
	logic[1:0] 					AWBURST_S3;
	logic 						AWVALID_S3;
	logic 						AWREADY_S3;
	logic[`AXI_DATA_BITS-1:0] 	WDATA_S3;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_S3;
	logic 						WLAST_S3;
	logic 						WVALID_S3;
	logic 						WREADY_S3;
	logic[`AXI_IDS_BITS-1:0] 	BID_S3;
	logic[1:0] 					BRESP_S3;
	logic 						BVALID_S3;
	logic 						BREADY_S3;

// S4 is WDT
	//READ 
	logic [`AXI_IDS_BITS-1:0] 	ARID_S4;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S4;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S4;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S4;
	logic [1:0] 				ARBURST_S4;
	logic 						ARVALID_S4;
	logic 						ARREADY_S4;
	logic[`AXI_IDS_BITS-1:0] 	RID_S4;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S4;
	logic[1:0] 					RRESP_S4;
	logic						RLAST_S4;
	logic						RVALID_S4;
	logic 						RREADY_S4;

	//WRITE 
	logic[`AXI_IDS_BITS-1:0] 	AWID_S4;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_S4;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_S4;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_S4;
	logic[1:0] 					AWBURST_S4;
	logic 						AWVALID_S4;
	logic 						AWREADY_S4;
	logic[`AXI_DATA_BITS-1:0] 	WDATA_S4;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_S4;
	logic 						WLAST_S4;
	logic 						WVALID_S4;
	logic 						WREADY_S4;
	logic[`AXI_IDS_BITS-1:0] 	BID_S4;
	logic[1:0] 					BRESP_S4;
	logic 						BVALID_S4;
	logic 						BREADY_S4;
	
// S5 is DRAM
	//READ 
	logic [`AXI_IDS_BITS-1:0] 	ARID_S5;
	logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S5;
	logic [`AXI_LEN_BITS-1:0] 	ARLEN_S5;
	logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S5;
	logic [1:0] 				ARBURST_S5;
	logic 						ARVALID_S5;
	logic 						ARREADY_S5;
	logic[`AXI_IDS_BITS-1:0] 	RID_S5;
	logic[`AXI_DATA_BITS-1:0] 	RDATA_S5;
	logic[1:0] 					RRESP_S5;
	logic						RLAST_S5;
	logic						RVALID_S5;
	logic 						RREADY_S5;

	//WRITE 
	logic[`AXI_IDS_BITS-1:0] 	AWID_S5;
	logic[`AXI_ADDR_BITS-1:0] 	AWADDR_S5;
	logic[`AXI_LEN_BITS-1:0] 	AWLEN_S5;
	logic[`AXI_SIZE_BITS-1:0] 	AWSIZE_S5;
	logic[1:0] 					AWBURST_S5;
	logic 						AWVALID_S5;
	logic 						AWREADY_S5;
	logic[`AXI_DATA_BITS-1:0] 	WDATA_S5;
	logic[`AXI_STRB_BITS-1:0] 	WSTRB_S5;
	logic 						WLAST_S5;
	logic 						WVALID_S5;
	logic 						WREADY_S5;
	logic[`AXI_IDS_BITS-1:0] 	BID_S5;
	logic[1:0] 					BRESP_S5;
	logic 						BVALID_S5;
	logic 						BREADY_S5;
	logic 						WTO;
	
	//connect to cpu
	logic DMA_interrupt;

///////////////////////////////////////////////////////

	// S0 ROM
	ROM_wrapper ROM_wrap(
	.ACLK(rom_clk),
	.ARESETn(~rom_rst),
	.ARID_ROM(ARID_S0),
	.ARADDR_ROM(ARADDR_S0),
	.ARLEN_ROM(ARLEN_S0),
	.ARSIZE_ROM(ARSIZE_S0),
	.ARBURST_ROM(ARBURST_S0),
	.ARVALID_ROM(ARVALID_S0),
	.ARREADY_ROM(ARREADY_S0),
	.RID_ROM(RID_S0),
	.RDATA_ROM(RDATA_S0),
	.RRESP_ROM(RRESP_S0),
	.RLAST_ROM(RLAST_S0),
	.RVALID_ROM(RVALID_S0),
	.RREADY_ROM(RREADY_S0),
	.DO(ROM_out),
	.CS(ROM_enable),
	.OE(ROM_read),
	.A(ROM_address));

///////////////////////////////////////////////////////

    // S1 IM
	SRAM_wrapper  IM1
	(
	.fuck_DM(1'b0),
	.ACLK(cpu_clk),
	.ARESETn(~cpu_rst),
	//READ ADDRESS     
	.ARID(ARID_S1),
	.ARADDR(ARADDR_S1),
	.ARLEN(ARLEN_S1),
	.ARSIZE(ARSIZE_S1),
	.ARBURST(ARBURST_S1),
	.ARVALID(ARVALID_S1),
	.ARREADY(ARREADY_S1),

	//READ DATA        
	.RID(RID_S1),
	.RDATA(RDATA_S1),
	.RRESP(RRESP_S1),
	.RLAST(RLAST_S1),
	.RVALID(RVALID_S1),
	.RREADY(RREADY_S1),
						
	//WRITE ADDRESS     
	.AWID(AWID_S1),
	.AWADDR(AWADDR_S1),
	.AWLEN(AWLEN_S1),
	.AWSIZE(AWSIZE_S1),
	.AWBURST(AWBURST_S1),
	.AWVALID(AWVALID_S1),
	.AWREADY(AWREADY_S1),
						
	//WRITE DATA        
	.WDATA(WDATA_S1),
	.WSTRB(WSTRB_S1),
	.WLAST(WLAST_S1),
	.WVALID(WVALID_S1),
	.WREADY(WREADY_S1),
						
	//WRITE RESPONSE    
	.BID(BID_S1),
	.BRESP(BRESP_S1),
	.BVALID(BVALID_S1),
	.BREADY(BREADY_S1));

///////////////////////////////////////////////////////

	// S2 DM
	SRAM_wrapper DM1(
	.fuck_DM(1'b1),
	.ACLK(cpu_clk),
	.ARESETn(~cpu_rst),
	//READ ADDRESS     
	.ARID(ARID_S2),
	.ARADDR(ARADDR_S2),
	.ARLEN(ARLEN_S2),
	.ARSIZE(ARSIZE_S2),
	.ARBURST(ARBURST_S2),
	.ARVALID(ARVALID_S2),
	.ARREADY(ARREADY_S2),

	//READ DATA        
	.RID(RID_S2),
	.RDATA(RDATA_S2),
	.RRESP(RRESP_S2),
	.RLAST(RLAST_S2),
	.RVALID(RVALID_S2),
	.RREADY(RREADY_S2),
						
	//WRITE ADDRESS     
	.AWID(AWID_S2),
	.AWADDR(AWADDR_S2),
	.AWLEN(AWLEN_S2),
	.AWSIZE(AWSIZE_S2),
	.AWBURST(AWBURST_S2),
	.AWVALID(AWVALID_S2),
	.AWREADY(AWREADY_S2),
						
	//WRITE DATA        
	.WDATA(WDATA_S2),
	.WSTRB(WSTRB_S2),
	.WLAST(WLAST_S2),
	.WVALID(WVALID_S2),
	.WREADY(WREADY_S2),
						
	//WRITE RESPONSE    
	.BID(BID_S2),
	.BRESP(BRESP_S2),
	.BVALID(BVALID_S2),
	.BREADY(BREADY_S2));

///////////////////////////////////////////////////////

	// S3 + M2
	DMA_wrapper DMA_wrap(
	.ACLK(cpu_clk),
	.ARESETn(~cpu_rst),
	.interrupt(DMA_interrupt),

	// MASTER　　interface

	//WRITE ADDRESS
	.AWID_M2	(AWID_M2),
	.AWADDR_M2	(AWADDR_M2),
	.AWLEN_M2	(AWLEN_M2),
	.AWSIZE_M2	(AWSIZE_M2),
	.AWBURST_M2	(AWBURST_M2),
	.AWVALID_M2	(AWVALID_M2),
	.AWREADY_M2	(AWREADY_M2),
	//WRITE DATA
	.WDATA_M2(WDATA_M2),
	.WSTRB_M2(WSTRB_M2),
	.WLAST_M2(WLAST_M2),
	.WVALID_M2(WVALID_M2),
	.WREADY_M2(WREADY_M2),
	//WRITE RESPONSE
	.BID_M2(BID_M2),
	.BRESP_M2(BRESP_M2),
	.BVALID_M2(BVALID_M2),
	.BREADY_M2(BREADY_M2),

	//READ ADDRESS
	.ARID_M2(ARID_M2),
	.ARADDR_M2(ARADDR_M2),
	.ARLEN_M2(ARLEN_M2),
	.ARSIZE_M2(ARSIZE_M2),
	.ARBURST_M2(ARBURST_M2),
	.ARVALID_M2(ARVALID_M2),
	.ARREADY_M2(ARREADY_M2),
	//READ DATA
	.RID_M2(RID_M2),
	.RDATA_M2(RDATA_M2),
	.RRESP_M2(RRESP_M2),
	.RLAST_M2(RLAST_M2),
	.RVALID_M2(RVALID_M2),
	.RREADY_M2(RREADY_M2),

	// SLAVE　　interface

	//READ ADDRESS     
	.ARID_S3(ARID_S3),
	.ARADDR_S3(ARADDR_S3),
	.ARLEN_S3(ARLEN_S3),
	.ARSIZE_S3(ARSIZE_S3),
	.ARBURST_S3(ARBURST_S3),
	.ARVALID_S3(ARVALID_S3),
	.ARREADY_S3(ARREADY_S3),

	//READ DATA        
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),
	.RREADY_S3(RREADY_S3),
						
	//WRITE ADDRESS     
	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),
	.AWREADY_S3(AWREADY_S3),
						
	//WRITE DATA        
	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),
	.WREADY_S3(WREADY_S3),
						
	//WRITE RESPONSE    
	.BID_S3(BID_S3),
	.BRESP_S3(BRESP_S3),
	.BVALID_S3(BVALID_S3),
	.BREADY_S3(BREADY_S3));

///////////////////////////////////////////////////////

	// S4 WDT
	WDT_wrapper WDT_wrap(
	.clk(rom_clk),
	.rst(rom_rst),
	//WRITE      
	.AWID_WDT(AWID_S4),
	.AWADDR_WDT(AWADDR_S4),
	.AWLEN_WDT(AWLEN_S4),
	.AWSIZE_WDT(AWSIZE_S4),
	.AWBURST_WDT(AWBURST_S4),
	.AWVALID_WDT(AWVALID_S4),
	.AWREADY_WDT(AWREADY_S4),     
	.WDATA_WDT(WDATA_S4),
	.WSTRB_WDT(WSTRB_S4),
	.WLAST_WDT(WLAST_S4),
	.WVALID_WDT(WVALID_S4),
	.WREADY_WDT(WREADY_S4),
	.BID_WDT(BID_S4),
	.BRESP_WDT(BRESP_S4),
	.BVALID_WDT(BVALID_S4),
	.BREADY_WDT(BREADY_S4),
	
	//READ    
	.ARID_WDT(ARID_S4),
	.ARADDR_WDT(ARADDR_S4),
	.ARLEN_WDT(ARLEN_S4),
	.ARSIZE_WDT(ARSIZE_S4),
	.ARBURST_WDT(ARBURST_S4),
	.ARVALID_WDT(ARVALID_S4),
	.ARREADY_WDT(ARREADY_S4),

	.RID_WDT(RID_S4),
	.RDATA_WDT(RDATA_S4),
	.RRESP_WDT(RRESP_S4),
	.RLAST_WDT(RLAST_S4),
	.RVALID_WDT(RVALID_S4),
	.RREADY_WDT(RREADY_S4),
	.WTO(WTO));

///////////////////////////////////////////////////////

	// S5 DRAM
	DRAM_wrapper DRAM_wrap(
	.ACLK(dram_clk),
	.ARESETn(~dram_rst),
	
	//WRITE      
	.AWID(AWID_S5),
	.AWADDR(AWADDR_S5),
	.AWLEN(AWLEN_S5),
	.AWSIZE(AWSIZE_S5),
	.AWBURST(AWBURST_S5),
	.AWVALID(AWVALID_S5),
	.AWREADY(AWREADY_S5),     
	.WDATA(WDATA_S5),
	.WSTRB(WSTRB_S5),
	.WLAST(WLAST_S5),
	.WVALID(WVALID_S5),
	.WREADY(WREADY_S5),
	.BID(BID_S5),
	.BRESP(BRESP_S5),
	.BVALID(BVALID_S5),
	.BREADY(BREADY_S5),
	
	//READ    
	.ARID(ARID_S5),
	.ARADDR(ARADDR_S5),
	.ARLEN(ARLEN_S5),
	.ARSIZE(ARSIZE_S5),
	.ARBURST(ARBURST_S5),
	.ARVALID(ARVALID_S5),
	.ARREADY(ARREADY_S5),   
	.RID(RID_S5),
	.RDATA(RDATA_S5),
	.RRESP(RRESP_S5),
	.RLAST(RLAST_S5),
	.RVALID(RVALID_S5),
	.RREADY(RREADY_S5),
	
	//DRAM
	.DRAM_Q(DRAM_Q),
	.DRAM_valid(DRAM_valid),
	.DRAM_CSn(DRAM_CSn),
	.DRAM_WEn(DRAM_WEn),
	.DRAM_RASn(DRAM_RASn),
	.DRAM_CASn(DRAM_CASn),
	.DRAM_A(DRAM_A),
	.DRAM_D(DRAM_D));

///////////////////////////////////////////////////////


	CPU_wrapper CPU_wrap(
	.ACLK(cpu_clk),
	.ARESETn(~cpu_rst),

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	.AWID_M1	(AWID_M1),
	.AWADDR_M1	(AWADDR_M1),
	.AWLEN_M1	(AWLEN_M1),
	.AWSIZE_M1	(AWSIZE_M1),
	.AWBURST_M1	(AWBURST_M1),
	.AWVALID_M1	(AWVALID_M1),
	.AWREADY_M1	(AWREADY_M1),
	//WRITE DATA
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	.WREADY_M1(WREADY_M1),
	//WRITE RESPONSE
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	//READ ADDRESS0
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),
	//READ DATA0
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),
	//READ ADDRESS1
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),
	//READ DATA1
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),
	.interrupt(DMA_interrupt),
    .WTO(WTO_flip_flop2));

always_ff @(posedge cpu_clk or posedge cpu_rst) begin
	if(cpu_rst) begin
		WTO_flip_flop1 <= 1'b0;
		WTO_flip_flop2 <= 1'b0;
	end
	else begin
		WTO_flip_flop1 <= WTO_r;
		WTO_flip_flop2 <= WTO_flip_flop1;
	end
end

always_ff @(posedge rom_clk or posedge rom_rst) begin
	if(rom_rst) begin
		WTO_r <= 1'b0;
	end
	else begin
		WTO_r <= WTO;
	end
end

AXI BUS(
	
	.i_CPU_CLK( cpu_clk ), // m0 m1
	.i_DMA_CLK( cpu_clk ), // m2
	.i_SRAM_CLK( cpu_clk ),// s1 s2
	.i_WDT_CLK( rom_clk ),// s4
	.i_AXI_CLK( axi_clk ),// axi
	.i_ROM_CLK( rom_clk ),// s0
	.i_DRAM_CLK( dram_clk ),// s5

	// rst

	.i_CPU_RST( cpu_rst ),// m0 m1
	.i_DMA_RST( cpu_rst ), // m2
	.i_SRAM_RST( cpu_rst ),// s1 s2
	.i_WDT_RST( rom_rst ),// s4
	.i_AXI_RST( axi_rst ),// axi
	.i_ROM_RST( rom_rst ),// s0
	.i_DRAM_RST( dram_rst ),// s5

	.AWID_M2    (AWID_M2),
	.AWADDR_M2  (AWADDR_M2),
	.AWLEN_M2   (AWLEN_M2),
	.AWSIZE_M2  (AWSIZE_M2),
	.AWBURST_M2 (AWBURST_M2),
	.AWVALID_M2 (AWVALID_M2),
	.AWREADY_M2 (AWREADY_M2),
	.WDATA_M2   (WDATA_M2),
	.WSTRB_M2   (WSTRB_M2),
	.WLAST_M2   (WLAST_M2),
	.WVALID_M2  (WVALID_M2),
	.WREADY_M2  (WREADY_M2),
	.BID_M2     (BID_M2),
	.BRESP_M2   (BRESP_M2),
	.BVALID_M2  (BVALID_M2),
	.BREADY_M2  (BREADY_M2),

	.AWID_M1    (AWID_M1),
	.AWADDR_M1  (AWADDR_M1),
	.AWLEN_M1   (AWLEN_M1),
	.AWSIZE_M1  (AWSIZE_M1),
	.AWBURST_M1 (AWBURST_M1),
	.AWVALID_M1 (AWVALID_M1),
	.AWREADY_M1 (AWREADY_M1),
	.WDATA_M1   (WDATA_M1),
	.WSTRB_M1   (WSTRB_M1),
	.WLAST_M1   (WLAST_M1),
	.WVALID_M1  (WVALID_M1),
	.WREADY_M1  (WREADY_M1),
	.BID_M1     (BID_M1),
	.BRESP_M1   (BRESP_M1),
	.BVALID_M1  (BVALID_M1),
	.BREADY_M1  (BREADY_M1),
	
	//READ ADDRESS0
	.ARID_M0	(ARID_M0),
	.ARADDR_M0	(ARADDR_M0),
	.ARLEN_M0	(ARLEN_M0),
	.ARSIZE_M0	(ARSIZE_M0),
	.ARBURST_M0	(ARBURST_M0),
	.ARVALID_M0	(ARVALID_M0),
	.ARREADY_M0	(ARREADY_M0),
	
	//READ DATA0
	.RID_M0		(RID_M0),
	.RDATA_M0	(RDATA_M0),
	.RRESP_M0	(RRESP_M0),
	.RLAST_M0	(RLAST_M0),
	.RVALID_M0	(RVALID_M0),
	.RREADY_M0	(RREADY_M0),
	
	//READ ADDRESS1
	.ARID_M1	(ARID_M1),
	.ARADDR_M1	(ARADDR_M1),
	.ARLEN_M1	(ARLEN_M1),
	.ARSIZE_M1	(ARSIZE_M1),
	.ARBURST_M1	(ARBURST_M1),
	.ARVALID_M1	(ARVALID_M1),
	.ARREADY_M1	(ARREADY_M1),
                
	//READ DATA1
	.RID_M1		(RID_M1),
	.RDATA_M1	(RDATA_M1),
	.RRESP_M1	(RRESP_M1),
	.RLAST_M1	(RLAST_M1),
	.RVALID_M1	(RVALID_M1),
	.RREADY_M1	(RREADY_M1),

	//READ ADDRESS2
	.ARID_M2	(ARID_M2),
	.ARADDR_M2	(ARADDR_M2),
	.ARLEN_M2	(ARLEN_M2),
	.ARSIZE_M2	(ARSIZE_M2),
	.ARBURST_M2	(ARBURST_M2),
	.ARVALID_M2	(ARVALID_M2),
	.ARREADY_M2	(ARREADY_M2),
                
	//READ DATA2
	.RID_M2		(RID_M2),
	.RDATA_M2	(RDATA_M2),
	.RRESP_M2	(RRESP_M2),
	.RLAST_M2	(RLAST_M2),
	.RVALID_M2	(RVALID_M2),
	.RREADY_M2	(RREADY_M2),
                

//MASTER INTERFACE FOR SLAVES
// S0 is ROM
	//WRITE
	.AWID_S0    (),
	.AWADDR_S0  (),
	.AWLEN_S0   (),
	.AWSIZE_S0  (),
	.AWBURST_S0 (),
	.AWVALID_S0 (),
	.AWREADY_S0 (1'b0),
	.WDATA_S0   (),
	.WSTRB_S0   (),
	.WLAST_S0   (),
	.WVALID_S0  (),
	.WREADY_S0  (1'b0),
	.BID_S0     (),
	.BRESP_S0   (),
	.BVALID_S0  (1'b0),
	.BREADY_S0  (),
	//READ
	.ARID_S0	(ARID_S0),
	.ARADDR_S0	(ARADDR_S0),
	.ARLEN_S0	(ARLEN_S0),
	.ARSIZE_S0	(ARSIZE_S0),
	.ARBURST_S0	(ARBURST_S0),
	.ARVALID_S0	(ARVALID_S0),
	.ARREADY_S0	(ARREADY_S0),
	.RID_S0		(RID_S0),
	.RDATA_S0	(RDATA_S0),
	.RRESP_S0	(RRESP_S0),
	.RLAST_S0	(RLAST_S0),
	.RVALID_S0	(RVALID_S0),
	.RREADY_S0	(RREADY_S0),
	
// S1 is IM
	//WRITE
	.AWID_S1    (AWID_S1),
	.AWADDR_S1  (AWADDR_S1),
	.AWLEN_S1   (AWLEN_S1),
	.AWSIZE_S1  (AWSIZE_S1),
	.AWBURST_S1 (AWBURST_S1),
	.AWVALID_S1 (AWVALID_S1),
	.AWREADY_S1 (AWREADY_S1),
	.WDATA_S1   (WDATA_S1),
	.WSTRB_S1   (WSTRB_S1),
	.WLAST_S1   (WLAST_S1),
	.WVALID_S1  (WVALID_S1),
	.WREADY_S1  (WREADY_S1),
	.BID_S1     (BID_S1),
	.BRESP_S1   (BRESP_S1),
	.BVALID_S1  (BVALID_S1),
	.BREADY_S1  (BREADY_S1),
	
	//READ
	.ARID_S1	(ARID_S1),
	.ARADDR_S1	(ARADDR_S1),
	.ARLEN_S1	(ARLEN_S1),
	.ARSIZE_S1	(ARSIZE_S1),
	.ARBURST_S1	(ARBURST_S1),
	.ARVALID_S1	(ARVALID_S1),
	.ARREADY_S1	(ARREADY_S1),
	.RID_S1		(RID_S1),
	.RDATA_S1	(RDATA_S1),
	.RRESP_S1	(RRESP_S1),
	.RLAST_S1	(RLAST_S1),
	.RVALID_S1	(RVALID_S1),
	.RREADY_S1	(RREADY_S1),
	
// S2 is DM
	//WRITE
	.AWID_S2    (AWID_S2),
	.AWADDR_S2  (AWADDR_S2),
	.AWLEN_S2   (AWLEN_S2),
	.AWSIZE_S2  (AWSIZE_S2),
	.AWBURST_S2 (AWBURST_S2),
	.AWVALID_S2 (AWVALID_S2),
	.AWREADY_S2 (AWREADY_S2),
	.WDATA_S2   (WDATA_S2),
	.WSTRB_S2   (WSTRB_S2),
	.WLAST_S2   (WLAST_S2),
	.WVALID_S2  (WVALID_S2),
	.WREADY_S2  (WREADY_S2),
	.BID_S2     (BID_S2),
	.BRESP_S2   (BRESP_S2),
	.BVALID_S2  (BVALID_S2),
	.BREADY_S2  (BREADY_S2),
	
	//READ
	.ARID_S2	(ARID_S2),
	.ARADDR_S2	(ARADDR_S2),
	.ARLEN_S2	(ARLEN_S2),
	.ARSIZE_S2	(ARSIZE_S2),
	.ARBURST_S2	(ARBURST_S2),
	.ARVALID_S2	(ARVALID_S2),
	.ARREADY_S2	(ARREADY_S2),
	.RID_S2		(RID_S2),
	.RDATA_S2	(RDATA_S2),
	.RRESP_S2	(RRESP_S2),
	.RLAST_S2	(RLAST_S2),
	.RVALID_S2	(RVALID_S2),
	.RREADY_S2	(RREADY_S2),
	
// S3 is DMA
	//WRITE
	.AWID_S3    (AWID_S3),
	.AWADDR_S3  (AWADDR_S3),
	.AWLEN_S3   (AWLEN_S3),
	.AWSIZE_S3  (AWSIZE_S3),
	.AWBURST_S3 (AWBURST_S3),
	.AWVALID_S3 (AWVALID_S3),
	.AWREADY_S3 (AWREADY_S3),
	.WDATA_S3   (WDATA_S3),
	.WSTRB_S3   (WSTRB_S3),
	.WLAST_S3   (WLAST_S3),
	.WVALID_S3  (WVALID_S3),
	.WREADY_S3  (WREADY_S3),
	.BID_S3     (BID_S3),
	.BRESP_S3   (BRESP_S3),
	.BVALID_S3  (BVALID_S3),
	.BREADY_S3  (BREADY_S3),
	
	//READ
	.ARID_S3	(ARID_S3),
	.ARADDR_S3	(ARADDR_S3),
	.ARLEN_S3	(ARLEN_S3),
	.ARSIZE_S3	(ARSIZE_S3),
	.ARBURST_S3	(ARBURST_S3),
	.ARVALID_S3	(ARVALID_S3),
	.ARREADY_S3	(ARREADY_S3),
	.RID_S3		(RID_S3),
	.RDATA_S3	(RDATA_S3),
	.RRESP_S3	(RRESP_S3),
	.RLAST_S3	(RLAST_S3),
	.RVALID_S3	(RVALID_S3),
	.RREADY_S3	(RREADY_S3),
	
// S4 is WDT
	//WRITE
	.AWID_S4    (AWID_S4),
	.AWADDR_S4  (AWADDR_S4),
	.AWLEN_S4   (AWLEN_S4),
	.AWSIZE_S4  (AWSIZE_S4),
	.AWBURST_S4 (AWBURST_S4),
	.AWVALID_S4 (AWVALID_S4),
	.AWREADY_S4 (AWREADY_S4),
	.WDATA_S4   (WDATA_S4),
	.WSTRB_S4   (WSTRB_S4),
	.WLAST_S4   (WLAST_S4),
	.WVALID_S4  (WVALID_S4),
	.WREADY_S4  (WREADY_S4),
	.BID_S4     (BID_S4),
	.BRESP_S4   (BRESP_S4),
	.BVALID_S4  (BVALID_S4),
	.BREADY_S4  (BREADY_S4),
	
	//READ
	.ARID_S4	(ARID_S4),
	.ARADDR_S4	(ARADDR_S4),
	.ARLEN_S4	(ARLEN_S4),
	.ARSIZE_S4	(ARSIZE_S4),
	.ARBURST_S4	(ARBURST_S4),
	.ARVALID_S4	(ARVALID_S4),
	.ARREADY_S4	(ARREADY_S4),
	.RID_S4		(RID_S4),
	.RDATA_S4	(RDATA_S4),
	.RRESP_S4	(RRESP_S4),
	.RLAST_S4	(RLAST_S4),
	.RVALID_S4	(RVALID_S4),
	.RREADY_S4	(RREADY_S4),
	
// S5 is DRAM
	//WRITE
	.AWID_S5    (AWID_S5),
	.AWADDR_S5  (AWADDR_S5),
	.AWLEN_S5   (AWLEN_S5),
	.AWSIZE_S5  (AWSIZE_S5),
	.AWBURST_S5 (AWBURST_S5),
	.AWVALID_S5 (AWVALID_S5),
	.AWREADY_S5 (AWREADY_S5),
	.WDATA_S5   (WDATA_S5),
	.WSTRB_S5   (WSTRB_S5),
	.WLAST_S5   (WLAST_S5),
	.WVALID_S5  (WVALID_S5),
	.WREADY_S5  (WREADY_S5),
	.BID_S5     (BID_S5),
	.BRESP_S5   (BRESP_S5),
	.BVALID_S5  (BVALID_S5),
	.BREADY_S5  (BREADY_S5),
	
	//READ
	.ARID_S5	(ARID_S5),
	.ARADDR_S5	(ARADDR_S5),
	.ARLEN_S5	(ARLEN_S5),
	.ARSIZE_S5	(ARSIZE_S5),
	.ARBURST_S5	(ARBURST_S5),
	.ARVALID_S5	(ARVALID_S5),
	.ARREADY_S5	(ARREADY_S5),
	.RID_S5		(RID_S5),
	.RDATA_S5	(RDATA_S5),
	.RRESP_S5	(RRESP_S5),
	.RLAST_S5	(RLAST_S5),
	.RVALID_S5	(RVALID_S5),
	.RREADY_S5	(RREADY_S5));

endmodule
