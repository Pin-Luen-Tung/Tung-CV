//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////


module AXI(

	// clk

    input  i_CPU_CLK, // m0 m1
	input  i_DMA_CLK, // m2
	input  i_SRAM_CLK,// s1 s2
	input  i_WDT_CLK,// s4
	input  i_AXI_CLK,// axi
	input  i_ROM_CLK,// s0
	input  i_DRAM_CLK,// s5

	// rst

	input  i_CPU_RST,// m0 m1
	input  i_DMA_RST, // m2
	input  i_SRAM_RST,// s1 s2
	input  i_WDT_RST,// s4
	input  i_AXI_RST,// axi
	input  i_ROM_RST,// s0
	input  i_DRAM_RST,// s5

    // M2 interface DMA(W+R)
    //WRITE ADDRESS2
	input [`AXI_ID_BITS-1:0] AWID_M2,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M2,
	input [`AXI_LEN_BITS-1:0] AWLEN_M2,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M2,
	input [1:0] AWBURST_M2,
	input AWVALID_M2,
	output logic AWREADY_M2,
	
	//WRITE DATA2
	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	output logic WREADY_M2,
	
	//WRITE RESPONSE2
	output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,

	//READ ADDRESS2
	input [`AXI_ID_BITS-1:0] ARID_M2,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M2,
	input [`AXI_LEN_BITS-1:0] ARLEN_M2,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M2,
	input [1:0] ARBURST_M2,
	input ARVALID_M2,
	output logic ARREADY_M2,
	
	//READ DATA2
	output logic [`AXI_ID_BITS-1:0] RID_M2,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M2,
	output logic [1:0] RRESP_M2,
	output logic RLAST_M2,
	output logic RVALID_M2,
	input RREADY_M2,



    // M1 interface DM(W+R)
    //WRITE ADDRESS1
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA1
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE1
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,



    // M0 interface IM(R)
	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0, 


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

    // S0 interface ROM 
    //WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

//////////////////////////////////////////////////////////////////////////// 

    // S1 interface IM
    //WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,

////////////////////////////////////////////////////////////////////////////

    // S2 interface DM
    //WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

////////////////////////////////////////////////////////////////////////////

    // S3 interface DMA
    //WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
	input AWREADY_S3,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output logic [1:0] ARBURST_S3,
	output logic ARVALID_S3,
	input ARREADY_S3,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3,

////////////////////////////////////////////////////////////////////////////

    // S4 interface WDT
    //WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
	input ARREADY_S4,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,

////////////////////////////////////////////////////////////////////////////
     
    // S5 interface DRAM
    //WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
	input AWREADY_S5,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5,
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
	input ARREADY_S5,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5
);

    // S0: ROM
	localparam MMIO_S0_START = 32'h0000_0000;
	localparam MMIO_S0_END   = 32'h0000_1FFF;
	// S1: IM
	localparam MMIO_S1_START = 32'h0001_0000;
	localparam MMIO_S1_END   = 32'h0001_FFFF;
	// S2: DM
	localparam MMIO_S2_START = 32'h0002_0000;
	localparam MMIO_S2_END   = 32'h0002_FFFF;
	// S3: DMA
	localparam MMIO_S3_START = 32'h1002_0000;
	localparam MMIO_S3_END   = 32'h1002_0400;
	// S4: WDT
	localparam MMIO_S4_START = 32'h1001_0000;
	localparam MMIO_S4_END   = 32'h1001_03FF;
	// S5: DRAM
	localparam MMIO_S5_START = 32'h2000_0000;
	localparam MMIO_S5_END   = 32'h201F_FFFF;
	

// AXI circuit

///////////////////////////////////////////////
//                
//		       Master  ports              
//
///////////////////////////////////////////////

//--------- AR____M0 ----------//

logic                      ARREADY_M0_AXI;
logic [`AXI_ID_BITS  -1:0] ARID_M0_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M0_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_M0_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_AXI;
logic [1:0]                ARBURST_M0_AXI;
logic                      ARVALID_M0_AXI;

//--------- RDATA____M0 ----------//

logic [`AXI_ID_BITS  -1:0] RID_M0_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_M0_AXI;
logic [1:0]                RRESP_M0_AXI;
logic                      RLAST_M0_AXI;
logic                      RVALID_M0_AXI;
logic                      RREADY_M0_AXI;

//--------- AR____M1 ----------//

logic                      ARREADY_M1_AXI;
logic [`AXI_ID_BITS  -1:0] ARID_M1_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M1_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_M1_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_AXI;
logic [1:0]                ARBURST_M1_AXI;
logic                      ARVALID_M1_AXI;

//--------- RDATA____M1 ----------//

logic [`AXI_ID_BITS  -1:0] RID_M1_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_M1_AXI;
logic [1:0]                RRESP_M1_AXI;
logic                      RLAST_M1_AXI;
logic                      RVALID_M1_AXI;
logic                      RREADY_M1_AXI;

//--------- AW____M1 ----------//

logic                      AWREADY_M1_AXI;
logic [`AXI_ID_BITS  -1:0] AWID_M1_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_M1_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1_AXI;
logic [1:0]                AWBURST_M1_AXI;
logic                      AWVALID_M1_AXI;

//--------- WDATA____M1 ----------//

logic                      WREADY_M1_AXI;
logic [`AXI_DATA_BITS-1:0] WDATA_M1_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1_AXI;
logic                      WLAST_M1_AXI;
logic                      WVALID_M1_AXI;

//--------- B____M1 ----------//

logic [`AXI_ID_BITS  -1:0] BID_M1_AXI;
logic [1:0]                BRESP_M1_AXI;
logic                      BVALID_M1_AXI;
logic                      BREADY_M1_AXI;

//--------- AR____M2 ----------//

logic                      ARREADY_M2_AXI;
logic [`AXI_ID_BITS  -1:0] ARID_M2_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M2_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_M2_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M2_AXI;
logic [1:0]                ARBURST_M2_AXI;
logic                      ARVALID_M2_AXI;

//--------- RDATA____M2 ----------//

logic [`AXI_ID_BITS  -1:0] RID_M2_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_M2_AXI;
logic [1:0]                RRESP_M2_AXI;
logic                      RLAST_M2_AXI;
logic                      RVALID_M2_AXI;
logic                      RREADY_M2_AXI;

//--------- AW____M2 ----------//

logic                      AWREADY_M2_AXI;
logic [`AXI_ID_BITS  -1:0] AWID_M2_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M2_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_M2_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M2_AXI;
logic [1:0]                AWBURST_M2_AXI;
logic                      AWVALID_M2_AXI;

//--------- WDATA____M2 ----------//

logic                      WREADY_M2_AXI;
logic [`AXI_DATA_BITS-1:0] WDATA_M2_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_M2_AXI;
logic                      WLAST_M2_AXI;
logic                      WVALID_M2_AXI;

//--------- B____M2 ----------//

logic [`AXI_ID_BITS  -1:0] BID_M2_AXI;
logic [1:0]                BRESP_M2_AXI;
logic                      BVALID_M2_AXI;
logic                      BREADY_M2_AXI;
///////////////////////////////////////////////
//                
//		       Slave  ports              
//
///////////////////////////////////////////////

//--------- AR____S0 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S0_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S0_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S0_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0_AXI;
logic [1:0]                ARBURST_S0_AXI;
logic                      ARVALID_S0_AXI;
logic                      ARREADY_S0_AXI;

//--------- RDATA____S0 ----------//

logic                      RREADY_S0_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S0_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S0_AXI;
logic [1:0]                RRESP_S0_AXI;
logic                      RLAST_S0_AXI;
logic                      RVALID_S0_AXI;

//--------- AW____S0 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S0_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S0_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S0_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0_AXI;
logic [1:0]                AWBURST_S0_AXI;
logic                      AWVALID_S0_AXI;
logic                      AWREADY_S0_AXI;

//--------- WDATA____S0 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S0_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S0_AXI;
logic                      WLAST_S0_AXI;
logic                      WVALID_S0_AXI;
logic                      WREADY_S0_AXI;

//--------- B____S0 ----------//

logic                      BREADY_S0_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S0_AXI;
logic [1:0]                BRESP_S0_AXI;
logic                      BVALID_S0_AXI;

//--------- AR____S1 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S1_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S1_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S1_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1_AXI;
logic [1:0]                ARBURST_S1_AXI;
logic                      ARVALID_S1_AXI;
logic                      ARREADY_S1_AXI;

//--------- RDATA____S1 ----------//

logic                      RREADY_S1_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S1_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S1_AXI;
logic [1:0]                RRESP_S1_AXI;
logic                      RLAST_S1_AXI;
logic                      RVALID_S1_AXI;

//--------- AW____S1 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S1_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S1_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S1_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1_AXI;
logic [1:0]                AWBURST_S1_AXI;
logic                      AWVALID_S1_AXI;
logic                      AWREADY_S1_AXI;

//--------- WDATA____S1 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S1_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S1_AXI;
logic                      WLAST_S1_AXI;
logic                      WVALID_S1_AXI;
logic                      WREADY_S1_AXI;

//--------- B____S1 ----------//

logic                      BREADY_S1_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S1_AXI;
logic [1:0]                BRESP_S1_AXI;
logic                      BVALID_S1_AXI;

//--------- AR____S2 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S2_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S2_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S2_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2_AXI;
logic [1:0]                ARBURST_S2_AXI;
logic                      ARVALID_S2_AXI;
logic                      ARREADY_S2_AXI;

//--------- RDATA____S2 ----------//

logic                      RREADY_S2_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S2_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S2_AXI;
logic [1:0]                RRESP_S2_AXI;
logic                      RLAST_S2_AXI;
logic                      RVALID_S2_AXI;

//--------- AW____S2 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S2_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S2_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S2_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2_AXI;
logic [1:0]                AWBURST_S2_AXI;
logic                      AWVALID_S2_AXI;
logic                      AWREADY_S2_AXI;

//--------- WDATA____S2 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S2_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S2_AXI;
logic                      WLAST_S2_AXI;
logic                      WVALID_S2_AXI;
logic                      WREADY_S2_AXI;

//--------- B____S2 ----------//

logic                      BREADY_S2_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S2_AXI;
logic [1:0]                BRESP_S2_AXI;
logic                      BVALID_S2_AXI;

//--------- AR____S3 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S3_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S3_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S3_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3_AXI;
logic [1:0]                ARBURST_S3_AXI;
logic                      ARVALID_S3_AXI;
logic                      ARREADY_S3_AXI;

//--------- RDATA____S3 ----------//

logic                      RREADY_S3_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S3_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S3_AXI;
logic [1:0]                RRESP_S3_AXI;
logic                      RLAST_S3_AXI;
logic                      RVALID_S3_AXI;

//--------- AW____S3 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S3_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S3_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S3_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3_AXI;
logic [1:0]                AWBURST_S3_AXI;
logic                      AWVALID_S3_AXI;
logic                      AWREADY_S3_AXI;

//--------- WDATA____S3 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S3_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S3_AXI;
logic                      WLAST_S3_AXI;
logic                      WVALID_S3_AXI;
logic                      WREADY_S3_AXI;

//--------- B____S3 ----------//

logic                      BREADY_S3_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S3_AXI;
logic [1:0]                BRESP_S3_AXI;
logic                      BVALID_S3_AXI;

//--------- AR____S4 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S4_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S4_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S4_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4_AXI;
logic [1:0]                ARBURST_S4_AXI;
logic                      ARVALID_S4_AXI;
logic                      ARREADY_S4_AXI;

//--------- RDATA____S4 ----------//

logic                      RREADY_S4_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S4_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S4_AXI;
logic [1:0]                RRESP_S4_AXI;
logic                      RLAST_S4_AXI;
logic                      RVALID_S4_AXI;

//--------- AW____S4 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S4_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S4_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S4_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4_AXI;
logic [1:0]                AWBURST_S4_AXI;
logic                      AWVALID_S4_AXI;
logic                      AWREADY_S4_AXI;

//--------- WDATA____S4 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S4_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S4_AXI;
logic                      WLAST_S4_AXI;
logic                      WVALID_S4_AXI;
logic                      WREADY_S4_AXI;

//--------- B____S4 ----------//

logic                      BREADY_S4_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S4_AXI;
logic [1:0]                BRESP_S4_AXI;
logic                      BVALID_S4_AXI;

//--------- AR____S5 ----------//

logic [`AXI_IDS_BITS -1:0] ARID_S5_AXI;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S5_AXI;
logic [`AXI_LEN_BITS -1:0] ARLEN_S5_AXI;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5_AXI;
logic [1:0]                ARBURST_S5_AXI;
logic                      ARVALID_S5_AXI;
logic                      ARREADY_S5_AXI;

//--------- RDATA____S5 ----------//

logic                      RREADY_S5_AXI;
logic [`AXI_IDS_BITS -1:0] RID_S5_AXI;
logic [`AXI_DATA_BITS-1:0] RDATA_S5_AXI;
logic [1:0]                RRESP_S5_AXI;
logic                      RLAST_S5_AXI;
logic                      RVALID_S5_AXI;

//--------- AW____S5 ----------//

logic [`AXI_IDS_BITS -1:0] AWID_S5_AXI;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S5_AXI;
logic [`AXI_LEN_BITS -1:0] AWLEN_S5_AXI;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5_AXI;
logic [1:0]                AWBURST_S5_AXI;
logic                      AWVALID_S5_AXI;
logic                      AWREADY_S5_AXI;

//--------- WDATA____S5 ----------//

logic [`AXI_DATA_BITS-1:0] WDATA_S5_AXI;
logic [`AXI_STRB_BITS-1:0] WSTRB_S5_AXI;
logic                      WLAST_S5_AXI;
logic                      WVALID_S5_AXI;
logic                      WREADY_S5_AXI;

//--------- B____S5 ----------//

logic                      BREADY_S5_AXI;
logic [`AXI_IDS_BITS -1:0] BID_S5_AXI;
logic [1:0]                BRESP_S5_AXI;
logic                      BVALID_S5_AXI;


//////////////////////////////////////////////
//             
//                             
//         Master interface (CDC)      
//      
//                                    
//////////////////////////////////////////////

// M0 interface

M_INTERFACE M0_CDC_INTERFACE(
	// Clock & Reset
	.m_clk        ( i_CPU_CLK ),
	.m_rst        ( i_CPU_RST ),
	.axi_clk    ( i_AXI_CLK ),
	.axi_rst    ( i_AXI_RST),
	// AW Channel
	.AWID_M       (`AXI_ID_BITS'b0),
	.AWADDR_M     (`AXI_ADDR_BITS'b0),
	.AWLEN_M      (`AXI_LEN_BITS'b0),
	.AWSIZE_M     (`AXI_SIZE_BITS'b0),
	.AWBURST_M    (2'b0),
	.AWVALID_M    (1'b0),
	.AWREADY_M    (),
	.AWID_AXI   (),
	.AWADDR_AXI (),
	.AWLEN_AXI  (),
	.AWSIZE_AXI (),
	.AWBURST_AXI(),
	.AWVALID_AXI(),
	.AWREADY_AXI(1'b0),
	// W Channel
	.WDATA_M      (`AXI_DATA_BITS'b0),
	.WSTRB_M      (`AXI_STRB_BITS'b0),
	.WLAST_M      (1'b0),
	.WVALID_M     (1'b0),
	.WREADY_M     (),
	.WDATA_AXI  (),
	.WSTRB_AXI  (),
	.WLAST_AXI  (),
	.WVALID_AXI (),
	.WREADY_AXI (1'b0),
	// AR Channel
	.ARID_M       (ARID_M0       ),
	.ARADDR_M     (ARADDR_M0     ),
	.ARLEN_M      (ARLEN_M0      ),
	.ARSIZE_M     (ARSIZE_M0     ),
	.ARBURST_M    (ARBURST_M0    ),
	.ARVALID_M    (ARVALID_M0    ),
	.ARREADY_M    (ARREADY_M0    ),
	.ARID_AXI   (ARID_M0_AXI   ),
	.ARADDR_AXI (ARADDR_M0_AXI ),
	.ARLEN_AXI  (ARLEN_M0_AXI  ),
	.ARSIZE_AXI (ARSIZE_M0_AXI ),
	.ARBURST_AXI(ARBURST_M0_AXI),
	.ARVALID_AXI(ARVALID_M0_AXI),
	.ARREADY_AXI(ARREADY_M0_AXI),
	// R Channel
	.RID_M        (RID_M0        ),
	.RDATA_M      (RDATA_M0      ),
	.RRESP_M      (RRESP_M0      ),
	.RLAST_M      (RLAST_M0      ),
	.RVALID_M     (RVALID_M0     ),
	.RREADY_M     (RREADY_M0     ),
	.RID_AXI    (RID_M0_AXI    ),
	.RDATA_AXI  (RDATA_M0_AXI  ),
	.RRESP_AXI  (RRESP_M0_AXI  ),
	.RLAST_AXI  (RLAST_M0_AXI  ),
	.RVALID_AXI (RVALID_M0_AXI ),
	.RREADY_AXI (RREADY_M0_AXI ),
	// B Channel
	.BID_M        (),
	.BRESP_M      (),
	.BVALID_M     (),
	.BREADY_M     (1'b0),
	.BID_AXI    (`AXI_ID_BITS'b0),
	.BRESP_AXI  (2'b0),
	.BVALID_AXI (1'b0),
	.BREADY_AXI ()
);

// m1 interface

M_INTERFACE M1_CDC_INTERFACE(
	// Clock & Reset
	.m_clk        ( i_CPU_CLK     ),
	.m_rst        ( i_CPU_RST     ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_M       (AWID_M1       ),
	.AWADDR_M     (AWADDR_M1     ),
	.AWLEN_M      (AWLEN_M1      ),
	.AWSIZE_M     (AWSIZE_M1     ),
	.AWBURST_M    (AWBURST_M1    ),
	.AWVALID_M    (AWVALID_M1    ),
	.AWREADY_M    (AWREADY_M1    ),
	.AWID_AXI   (AWID_M1_AXI   ),
	.AWADDR_AXI (AWADDR_M1_AXI ),
	.AWLEN_AXI  (AWLEN_M1_AXI  ),
	.AWSIZE_AXI (AWSIZE_M1_AXI ),
	.AWBURST_AXI(AWBURST_M1_AXI),
	.AWVALID_AXI(AWVALID_M1_AXI),
	.AWREADY_AXI(AWREADY_M1_AXI),
	// W Channel
	.WDATA_M      (WDATA_M1      ),
	.WSTRB_M      (WSTRB_M1      ),
	.WLAST_M      (WLAST_M1      ),
	.WVALID_M     (WVALID_M1     ),
	.WREADY_M     (WREADY_M1     ),
	.WDATA_AXI  (WDATA_M1_AXI  ),
	.WSTRB_AXI  (WSTRB_M1_AXI  ),
	.WLAST_AXI  (WLAST_M1_AXI  ),
	.WVALID_AXI (WVALID_M1_AXI ),
	.WREADY_AXI (WREADY_M1_AXI ),
	// AR Channel
	.ARID_M       (ARID_M1       ),
	.ARADDR_M     (ARADDR_M1     ),
	.ARLEN_M      (ARLEN_M1      ),
	.ARSIZE_M     (ARSIZE_M1     ),
	.ARBURST_M    (ARBURST_M1    ),
	.ARVALID_M    (ARVALID_M1    ),
	.ARREADY_M    (ARREADY_M1    ),
	.ARID_AXI   (ARID_M1_AXI   ),
	.ARADDR_AXI (ARADDR_M1_AXI ),
	.ARLEN_AXI  (ARLEN_M1_AXI  ),
	.ARSIZE_AXI (ARSIZE_M1_AXI ),
	.ARBURST_AXI(ARBURST_M1_AXI),
	.ARVALID_AXI(ARVALID_M1_AXI),
	.ARREADY_AXI(ARREADY_M1_AXI),
	// R Channel
	.RID_M        (RID_M1        ),
	.RDATA_M      (RDATA_M1      ),
	.RRESP_M      (RRESP_M1      ),
	.RLAST_M      (RLAST_M1      ),
	.RVALID_M     (RVALID_M1     ),
	.RREADY_M     (RREADY_M1     ),
	.RID_AXI    (RID_M1_AXI    ),
	.RDATA_AXI  (RDATA_M1_AXI  ),
	.RRESP_AXI  (RRESP_M1_AXI  ),
	.RLAST_AXI  (RLAST_M1_AXI  ),
	.RVALID_AXI (RVALID_M1_AXI ),
	.RREADY_AXI (RREADY_M1_AXI ),
	// B Channel
	.BID_M        (BID_M1        ),
	.BRESP_M      (BRESP_M1      ),
	.BVALID_M     (BVALID_M1     ),
	.BREADY_M     (BREADY_M1     ),
	.BID_AXI    (BID_M1_AXI    ),
	.BRESP_AXI  (BRESP_M1_AXI  ),
	.BVALID_AXI (BVALID_M1_AXI ),
	.BREADY_AXI (BREADY_M1_AXI )
);

// m2 interface

M_INTERFACE M2_CDC_INTERFACE(
	// Clock & Reset
	.m_clk        ( i_DMA_CLK     ),
	.m_rst        ( i_DMA_RST     ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_M       (AWID_M2       ),
	.AWADDR_M     (AWADDR_M2     ),
	.AWLEN_M      (AWLEN_M2      ),
	.AWSIZE_M     (AWSIZE_M2     ),
	.AWBURST_M    (AWBURST_M2    ),
	.AWVALID_M    (AWVALID_M2    ),
	.AWREADY_M    (AWREADY_M2    ),
	.AWID_AXI   (AWID_M2_AXI   ),
	.AWADDR_AXI (AWADDR_M2_AXI ),
	.AWLEN_AXI  (AWLEN_M2_AXI  ),
	.AWSIZE_AXI (AWSIZE_M2_AXI ),
	.AWBURST_AXI(AWBURST_M2_AXI),
	.AWVALID_AXI(AWVALID_M2_AXI),
	.AWREADY_AXI(AWREADY_M2_AXI),
	// W Channel
	.WDATA_M      (WDATA_M2      ),
	.WSTRB_M      (WSTRB_M2      ),
	.WLAST_M      (WLAST_M2      ),
	.WVALID_M     (WVALID_M2     ),
	.WREADY_M     (WREADY_M2     ),
	.WDATA_AXI  (WDATA_M2_AXI  ),
	.WSTRB_AXI  (WSTRB_M2_AXI  ),
	.WLAST_AXI  (WLAST_M2_AXI  ),
	.WVALID_AXI (WVALID_M2_AXI ),
	.WREADY_AXI (WREADY_M2_AXI ),
	// AR Channel
	.ARID_M       (ARID_M2       ),
	.ARADDR_M     (ARADDR_M2     ),
	.ARLEN_M      (ARLEN_M2      ),
	.ARSIZE_M     (ARSIZE_M2     ),
	.ARBURST_M    (ARBURST_M2    ),
	.ARVALID_M    (ARVALID_M2    ),
	.ARREADY_M    (ARREADY_M2    ),
	.ARID_AXI   (ARID_M2_AXI   ),
	.ARADDR_AXI (ARADDR_M2_AXI ),
	.ARLEN_AXI  (ARLEN_M2_AXI  ),
	.ARSIZE_AXI (ARSIZE_M2_AXI ),
	.ARBURST_AXI(ARBURST_M2_AXI),
	.ARVALID_AXI(ARVALID_M2_AXI),
	.ARREADY_AXI(ARREADY_M2_AXI),
	// R Channel
	.RID_M        (RID_M2        ),
	.RDATA_M      (RDATA_M2      ),
	.RRESP_M      (RRESP_M2      ),
	.RLAST_M      (RLAST_M2      ),
	.RVALID_M     (RVALID_M2     ),
	.RREADY_M     (RREADY_M2     ),
	.RID_AXI    (RID_M2_AXI    ),
	.RDATA_AXI  (RDATA_M2_AXI  ),
	.RRESP_AXI  (RRESP_M2_AXI  ),
	.RLAST_AXI  (RLAST_M2_AXI  ),
	.RVALID_AXI (RVALID_M2_AXI ),
	.RREADY_AXI (RREADY_M2_AXI ),
	// B Channel
	.BID_M        (BID_M2        ),
	.BRESP_M      (BRESP_M2      ),
	.BVALID_M     (BVALID_M2     ),
	.BREADY_M     (BREADY_M2     ),
	.BID_AXI    (BID_M2_AXI    ),
	.BRESP_AXI  (BRESP_M2_AXI  ),
	.BVALID_AXI (BVALID_M2_AXI ),
	.BREADY_AXI (BREADY_M2_AXI )
);

//////////////////////////////////////////////
//             
//                             
//         Slave interface (CDC)      
//      
//                                    
//////////////////////////////////////////////

// s0 interface

S_INTERFACE S0_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_ROM_CLK     ),
	.s_rst        ( i_ROM_RST    ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (),
	.AWADDR_S     (),
	.AWLEN_S      (),
	.AWSIZE_S     (),
	.AWBURST_S    (),
	.AWVALID_S    (),
	.AWREADY_S    (),
	.AWID_AXI   (),
	.AWADDR_AXI (),
	.AWLEN_AXI  (),
	.AWSIZE_AXI (),
	.AWBURST_AXI(),
	.AWVALID_AXI(),
	.AWREADY_AXI(),
	// W Channel
	.WDATA_S      (),
	.WSTRB_S      (),
	.WLAST_S      (),
	.WVALID_S     (),
	.WREADY_S     (),
	.WDATA_AXI  (),
	.WSTRB_AXI  (),
	.WLAST_AXI  (),
	.WVALID_AXI (),
	.WREADY_AXI (),
	// AR Channel
	.ARID_S       (ARID_S0       ),
	.ARADDR_S     (ARADDR_S0     ),
	.ARLEN_S      (ARLEN_S0      ),
	.ARSIZE_S     (ARSIZE_S0     ),
	.ARBURST_S    (ARBURST_S0    ),
	.ARVALID_S    (ARVALID_S0    ),
	.ARREADY_S    (ARREADY_S0    ),
	.ARID_AXI   (ARID_S0_AXI   ),
	.ARADDR_AXI (ARADDR_S0_AXI ),
	.ARLEN_AXI  (ARLEN_S0_AXI  ),
	.ARSIZE_AXI (ARSIZE_S0_AXI ),
	.ARBURST_AXI(ARBURST_S0_AXI),
	.ARVALID_AXI(ARVALID_S0_AXI),
	.ARREADY_AXI(ARREADY_S0_AXI),
	// R Channel
	.RID_S        (RID_S0        ),
	.RDATA_S      (RDATA_S0      ),
	.RRESP_S      (RRESP_S0      ),
	.RLAST_S      (RLAST_S0      ),
	.RVALID_S     (RVALID_S0     ),
	.RREADY_S     (RREADY_S0     ),
	.RID_AXI    (RID_S0_AXI    ),
	.RDATA_AXI  (RDATA_S0_AXI  ),
	.RRESP_AXI  (RRESP_S0_AXI  ),
	.RLAST_AXI  (RLAST_S0_AXI  ),
	.RVALID_AXI (RVALID_S0_AXI ),
	.RREADY_AXI (RREADY_S0_AXI ),
	// B Channel
	.BID_S        (),
	.BRESP_S      (),
	.BVALID_S     (),
	.BREADY_S     (),
	.BID_AXI    (),
	.BRESP_AXI  (),
	.BVALID_AXI (),
	.BREADY_AXI ()
);

// s1 interface

S_INTERFACE S1_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_SRAM_CLK    ),
	.s_rst        ( i_SRAM_RST    ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (AWID_S1       ),
	.AWADDR_S     (AWADDR_S1     ),
	.AWLEN_S      (AWLEN_S1      ),
	.AWSIZE_S     (AWSIZE_S1     ),
	.AWBURST_S    (AWBURST_S1    ),
	.AWVALID_S    (AWVALID_S1    ),
	.AWREADY_S    (AWREADY_S1    ),
	.AWID_AXI   (AWID_S1_AXI   ),
	.AWADDR_AXI (AWADDR_S1_AXI ),
	.AWLEN_AXI  (AWLEN_S1_AXI  ),
	.AWSIZE_AXI (AWSIZE_S1_AXI ),
	.AWBURST_AXI(AWBURST_S1_AXI),
	.AWVALID_AXI(AWVALID_S1_AXI),
	.AWREADY_AXI(AWREADY_S1_AXI),
	// W Channel
	.WDATA_S      (WDATA_S1      ),
	.WSTRB_S      (WSTRB_S1      ),
	.WLAST_S      (WLAST_S1      ),
	.WVALID_S     (WVALID_S1     ),
	.WREADY_S     (WREADY_S1     ),
	.WDATA_AXI  (WDATA_S1_AXI  ),
	.WSTRB_AXI  (WSTRB_S1_AXI  ),
	.WLAST_AXI  (WLAST_S1_AXI  ),
	.WVALID_AXI (WVALID_S1_AXI ),
	.WREADY_AXI (WREADY_S1_AXI ),
	// AR Channel
	.ARID_S       (ARID_S1       ),
	.ARADDR_S     (ARADDR_S1     ),
	.ARLEN_S      (ARLEN_S1      ),
	.ARSIZE_S     (ARSIZE_S1     ),
	.ARBURST_S    (ARBURST_S1    ),
	.ARVALID_S    (ARVALID_S1    ),
	.ARREADY_S    (ARREADY_S1    ),
	.ARID_AXI   (ARID_S1_AXI   ),
	.ARADDR_AXI (ARADDR_S1_AXI ),
	.ARLEN_AXI  (ARLEN_S1_AXI  ),
	.ARSIZE_AXI (ARSIZE_S1_AXI ),
	.ARBURST_AXI(ARBURST_S1_AXI),
	.ARVALID_AXI(ARVALID_S1_AXI),
	.ARREADY_AXI(ARREADY_S1_AXI),
	// R Channel
	.RID_S        (RID_S1        ),
	.RDATA_S      (RDATA_S1      ),
	.RRESP_S      (RRESP_S1      ),
	.RLAST_S      (RLAST_S1      ),
	.RVALID_S     (RVALID_S1     ),
	.RREADY_S     (RREADY_S1     ),
	.RID_AXI    (RID_S1_AXI    ),
	.RDATA_AXI  (RDATA_S1_AXI  ),
	.RRESP_AXI  (RRESP_S1_AXI  ),
	.RLAST_AXI  (RLAST_S1_AXI  ),
	.RVALID_AXI (RVALID_S1_AXI ),
	.RREADY_AXI (RREADY_S1_AXI ),
	// B Channel
	.BID_S        (BID_S1        ),
	.BRESP_S      (BRESP_S1      ),
	.BVALID_S     (BVALID_S1     ),
	.BREADY_S     (BREADY_S1     ),
	.BID_AXI    (BID_S1_AXI    ),
	.BRESP_AXI  (BRESP_S1_AXI  ),
	.BVALID_AXI (BVALID_S1_AXI ),
	.BREADY_AXI (BREADY_S1_AXI )
);

// s2 interface

S_INTERFACE S2_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_SRAM_CLK    ),
	.s_rst        ( i_SRAM_RST    ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (AWID_S2       ),
	.AWADDR_S     (AWADDR_S2     ),
	.AWLEN_S      (AWLEN_S2      ),
	.AWSIZE_S     (AWSIZE_S2     ),
	.AWBURST_S    (AWBURST_S2    ),
	.AWVALID_S    (AWVALID_S2    ),
	.AWREADY_S    (AWREADY_S2    ),
	.AWID_AXI   (AWID_S2_AXI   ),
	.AWADDR_AXI (AWADDR_S2_AXI ),
	.AWLEN_AXI  (AWLEN_S2_AXI  ),
	.AWSIZE_AXI (AWSIZE_S2_AXI ),
	.AWBURST_AXI(AWBURST_S2_AXI),
	.AWVALID_AXI(AWVALID_S2_AXI),
	.AWREADY_AXI(AWREADY_S2_AXI),
	// W Channel
	.WDATA_S      (WDATA_S2      ),
	.WSTRB_S      (WSTRB_S2      ),
	.WLAST_S      (WLAST_S2      ),
	.WVALID_S     (WVALID_S2     ),
	.WREADY_S     (WREADY_S2     ),
	.WDATA_AXI  (WDATA_S2_AXI  ),
	.WSTRB_AXI  (WSTRB_S2_AXI  ),
	.WLAST_AXI  (WLAST_S2_AXI  ),
	.WVALID_AXI (WVALID_S2_AXI ),
	.WREADY_AXI (WREADY_S2_AXI ),
	// AR Channel
	.ARID_S       (ARID_S2       ),
	.ARADDR_S     (ARADDR_S2     ),
	.ARLEN_S      (ARLEN_S2      ),
	.ARSIZE_S     (ARSIZE_S2     ),
	.ARBURST_S    (ARBURST_S2    ),
	.ARVALID_S    (ARVALID_S2    ),
	.ARREADY_S    (ARREADY_S2    ),
	.ARID_AXI   (ARID_S2_AXI   ),
	.ARADDR_AXI (ARADDR_S2_AXI ),
	.ARLEN_AXI  (ARLEN_S2_AXI  ),
	.ARSIZE_AXI (ARSIZE_S2_AXI ),
	.ARBURST_AXI(ARBURST_S2_AXI),
	.ARVALID_AXI(ARVALID_S2_AXI),
	.ARREADY_AXI(ARREADY_S2_AXI),
	// R Channel
	.RID_S        (RID_S2        ),
	.RDATA_S      (RDATA_S2      ),
	.RRESP_S      (RRESP_S2      ),
	.RLAST_S      (RLAST_S2      ),
	.RVALID_S     (RVALID_S2     ),
	.RREADY_S     (RREADY_S2     ),
	.RID_AXI    (RID_S2_AXI    ),
	.RDATA_AXI  (RDATA_S2_AXI  ),
	.RRESP_AXI  (RRESP_S2_AXI  ),
	.RLAST_AXI  (RLAST_S2_AXI  ),
	.RVALID_AXI (RVALID_S2_AXI ),
	.RREADY_AXI (RREADY_S2_AXI ),
	// B Channel
	.BID_S        (BID_S2        ),
	.BRESP_S      (BRESP_S2      ),
	.BVALID_S     (BVALID_S2     ),
	.BREADY_S     (BREADY_S2     ),
	.BID_AXI    (BID_S2_AXI    ),
	.BRESP_AXI  (BRESP_S2_AXI  ),
	.BVALID_AXI (BVALID_S2_AXI ),
	.BREADY_AXI (BREADY_S2_AXI )
);

// s3 interface

S_INTERFACE S3_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_DMA_CLK    ),
	.s_rst        ( i_DMA_RST    ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (AWID_S3       ),
	.AWADDR_S     (AWADDR_S3     ),
	.AWLEN_S      (AWLEN_S3      ),
	.AWSIZE_S     (AWSIZE_S3     ),
	.AWBURST_S    (AWBURST_S3    ),
	.AWVALID_S    (AWVALID_S3    ),
	.AWREADY_S    (AWREADY_S3    ),
	.AWID_AXI   (AWID_S3_AXI   ),
	.AWADDR_AXI (AWADDR_S3_AXI ),
	.AWLEN_AXI  (AWLEN_S3_AXI  ),
	.AWSIZE_AXI (AWSIZE_S3_AXI ),
	.AWBURST_AXI(AWBURST_S3_AXI),
	.AWVALID_AXI(AWVALID_S3_AXI),
	.AWREADY_AXI(AWREADY_S3_AXI),
	// W Channel
	.WDATA_S      (WDATA_S3      ),
	.WSTRB_S      (WSTRB_S3      ),
	.WLAST_S      (WLAST_S3      ),
	.WVALID_S     (WVALID_S3     ),
	.WREADY_S     (WREADY_S3     ),
	.WDATA_AXI  (WDATA_S3_AXI  ),
	.WSTRB_AXI  (WSTRB_S3_AXI  ),
	.WLAST_AXI  (WLAST_S3_AXI  ),
	.WVALID_AXI (WVALID_S3_AXI ),
	.WREADY_AXI (WREADY_S3_AXI ),
	// AR Channel
	.ARID_S       (ARID_S3       ),
	.ARADDR_S     (ARADDR_S3     ),
	.ARLEN_S      (ARLEN_S3      ),
	.ARSIZE_S     (ARSIZE_S3     ),
	.ARBURST_S    (ARBURST_S3    ),
	.ARVALID_S    (ARVALID_S3    ),
	.ARREADY_S    (ARREADY_S3    ),
	.ARID_AXI   (ARID_S3_AXI   ),
	.ARADDR_AXI (ARADDR_S3_AXI ),
	.ARLEN_AXI  (ARLEN_S3_AXI  ),
	.ARSIZE_AXI (ARSIZE_S3_AXI ),
	.ARBURST_AXI(ARBURST_S3_AXI),
	.ARVALID_AXI(ARVALID_S3_AXI),
	.ARREADY_AXI(ARREADY_S3_AXI),
	// R Channel
	.RID_S        (RID_S3        ),
	.RDATA_S      (RDATA_S3      ),
	.RRESP_S      (RRESP_S3      ),
	.RLAST_S      (RLAST_S3      ),
	.RVALID_S     (RVALID_S3     ),
	.RREADY_S     (RREADY_S3     ),
	.RID_AXI    (RID_S3_AXI    ),
	.RDATA_AXI  (RDATA_S3_AXI  ),
	.RRESP_AXI  (RRESP_S3_AXI  ),
	.RLAST_AXI  (RLAST_S3_AXI  ),
	.RVALID_AXI (RVALID_S3_AXI ),
	.RREADY_AXI (RREADY_S3_AXI ),
	// B Channel
	.BID_S        (BID_S3        ),
	.BRESP_S      (BRESP_S3      ),
	.BVALID_S     (BVALID_S3     ),
	.BREADY_S     (BREADY_S3     ),
	.BID_AXI    (BID_S3_AXI    ),
	.BRESP_AXI  (BRESP_S3_AXI  ),
	.BVALID_AXI (BVALID_S3_AXI ),
	.BREADY_AXI (BREADY_S3_AXI )
);

// s4 interface

S_INTERFACE S4_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_WDT_CLK    ),
	.s_rst        ( i_WDT_RST    ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (AWID_S4       ),
	.AWADDR_S     (AWADDR_S4     ),
	.AWLEN_S      (AWLEN_S4      ),
	.AWSIZE_S     (AWSIZE_S4     ),
	.AWBURST_S    (AWBURST_S4    ),
	.AWVALID_S    (AWVALID_S4    ),
	.AWREADY_S    (AWREADY_S4    ),
	.AWID_AXI   (AWID_S4_AXI   ),
	.AWADDR_AXI (AWADDR_S4_AXI ),
	.AWLEN_AXI  (AWLEN_S4_AXI  ),
	.AWSIZE_AXI (AWSIZE_S4_AXI ),
	.AWBURST_AXI(AWBURST_S4_AXI),
	.AWVALID_AXI(AWVALID_S4_AXI),
	.AWREADY_AXI(AWREADY_S4_AXI),
	// W Channel
	.WDATA_S      (WDATA_S4      ),
	.WSTRB_S      (WSTRB_S4      ),
	.WLAST_S      (WLAST_S4      ),
	.WVALID_S     (WVALID_S4     ),
	.WREADY_S     (WREADY_S4     ),
	.WDATA_AXI  (WDATA_S4_AXI  ),
	.WSTRB_AXI  (WSTRB_S4_AXI  ),
	.WLAST_AXI  (WLAST_S4_AXI  ),
	.WVALID_AXI (WVALID_S4_AXI ),
	.WREADY_AXI (WREADY_S4_AXI ),
	// AR Channel
	.ARID_S       (ARID_S4       ),
	.ARADDR_S     (ARADDR_S4     ),
	.ARLEN_S      (ARLEN_S4      ),
	.ARSIZE_S     (ARSIZE_S4     ),
	.ARBURST_S    (ARBURST_S4    ),
	.ARVALID_S    (ARVALID_S4    ),
	.ARREADY_S    (ARREADY_S4    ),
	.ARID_AXI   (ARID_S4_AXI   ),
	.ARADDR_AXI (ARADDR_S4_AXI ),
	.ARLEN_AXI  (ARLEN_S4_AXI  ),
	.ARSIZE_AXI (ARSIZE_S4_AXI ),
	.ARBURST_AXI(ARBURST_S4_AXI),
	.ARVALID_AXI(ARVALID_S4_AXI),
	.ARREADY_AXI(ARREADY_S4_AXI),
	// R Channel
	.RID_S        (RID_S4        ),
	.RDATA_S      (RDATA_S4      ),
	.RRESP_S      (RRESP_S4      ),
	.RLAST_S      (RLAST_S4      ),
	.RVALID_S     (RVALID_S4     ),
	.RREADY_S     (RREADY_S4     ),
	.RID_AXI    (RID_S4_AXI    ),
	.RDATA_AXI  (RDATA_S4_AXI  ),
	.RRESP_AXI  (RRESP_S4_AXI  ),
	.RLAST_AXI  (RLAST_S4_AXI  ),
	.RVALID_AXI (RVALID_S4_AXI ),
	.RREADY_AXI (RREADY_S4_AXI ),
	// B Channel
	.BID_S        (BID_S4        ),
	.BRESP_S      (BRESP_S4      ),
	.BVALID_S     (BVALID_S4     ),
	.BREADY_S     (BREADY_S4     ),
	.BID_AXI    (BID_S4_AXI    ),
	.BRESP_AXI  (BRESP_S4_AXI  ),
	.BVALID_AXI (BVALID_S4_AXI ),
	.BREADY_AXI (BREADY_S4_AXI )
);

// s5 interface

S_INTERFACE S5_INTERFACE_CDC(
	// Clock & Reset
	.s_clk        ( i_DRAM_CLK   ),
	.s_rst        ( i_DRAM_RST   ),
	.axi_clk    ( i_AXI_CLK     ),
	.axi_rst    ( i_AXI_RST     ),
	// AW Channel
	.AWID_S       (AWID_S5       ),
	.AWADDR_S     (AWADDR_S5     ),
	.AWLEN_S      (AWLEN_S5      ),
	.AWSIZE_S     (AWSIZE_S5     ),
	.AWBURST_S    (AWBURST_S5    ),
	.AWVALID_S    (AWVALID_S5    ),
	.AWREADY_S    (AWREADY_S5    ),
	.AWID_AXI   (AWID_S5_AXI   ),
	.AWADDR_AXI (AWADDR_S5_AXI ),
	.AWLEN_AXI  (AWLEN_S5_AXI  ),
	.AWSIZE_AXI (AWSIZE_S5_AXI ),
	.AWBURST_AXI(AWBURST_S5_AXI),
	.AWVALID_AXI(AWVALID_S5_AXI),
	.AWREADY_AXI(AWREADY_S5_AXI),
	// W Channel
	.WDATA_S      (WDATA_S5      ),
	.WSTRB_S      (WSTRB_S5      ),
	.WLAST_S      (WLAST_S5      ),
	.WVALID_S     (WVALID_S5     ),
	.WREADY_S     (WREADY_S5     ),
	.WDATA_AXI  (WDATA_S5_AXI  ),
	.WSTRB_AXI  (WSTRB_S5_AXI  ),
	.WLAST_AXI  (WLAST_S5_AXI  ),
	.WVALID_AXI (WVALID_S5_AXI ),
	.WREADY_AXI (WREADY_S5_AXI ),
	// AR Channel
	.ARID_S       (ARID_S5       ),
	.ARADDR_S     (ARADDR_S5     ),
	.ARLEN_S      (ARLEN_S5      ),
	.ARSIZE_S     (ARSIZE_S5     ),
	.ARBURST_S    (ARBURST_S5    ),
	.ARVALID_S    (ARVALID_S5    ),
	.ARREADY_S    (ARREADY_S5    ),
	.ARID_AXI   (ARID_S5_AXI   ),
	.ARADDR_AXI (ARADDR_S5_AXI ),
	.ARLEN_AXI  (ARLEN_S5_AXI  ),
	.ARSIZE_AXI (ARSIZE_S5_AXI ),
	.ARBURST_AXI(ARBURST_S5_AXI),
	.ARVALID_AXI(ARVALID_S5_AXI),
	.ARREADY_AXI(ARREADY_S5_AXI),
	// R Channel
	.RID_S        (RID_S5        ),
	.RDATA_S      (RDATA_S5      ),
	.RRESP_S      (RRESP_S5      ),
	.RLAST_S      (RLAST_S5      ),
	.RVALID_S     (RVALID_S5     ),
	.RREADY_S     (RREADY_S5     ),
	.RID_AXI    (RID_S5_AXI    ),
	.RDATA_AXI  (RDATA_S5_AXI  ),
	.RRESP_AXI  (RRESP_S5_AXI  ),
	.RLAST_AXI  (RLAST_S5_AXI  ),
	.RVALID_AXI (RVALID_S5_AXI ),
	.RREADY_AXI (RREADY_S5_AXI ),
	// B Channel
	.BID_S        (BID_S5        ),
	.BRESP_S      (BRESP_S5      ),
	.BVALID_S     (BVALID_S5     ),
	.BREADY_S     (BREADY_S5     ),
	.BID_AXI    (BID_S5_AXI    ),
	.BRESP_AXI  (BRESP_S5_AXI  ),
	.BVALID_AXI (BVALID_S5_AXI ),
	.BREADY_AXI (BREADY_S5_AXI )
);


// AR logic
	logic [`AXI_ADDR_BITS-1:0] arb_ARADDR;
	logic [               5:0] AR_decode;
	logic [               2:0] AR_grant;
	logic                      arb_ARREADY;
	logic [`AXI_IDS_BITS-1: 0] arb_ARID;
	logic [`AXI_LEN_BITS-1: 0] arb_ARLEN;
	logic [`AXI_SIZE_BITS-1:0] arb_ARSIZE;
	logic [               1:0] arb_ARBURST;
	logic                      arb_ARVALID;

    logic 			   AR_using;
// R logic
	logic [`AXI_IDS_BITS-1:0]  arb_RID;
	logic [`AXI_DATA_BITS-1:0] arb_RDATA;
	logic [1:0]                arb_RRESP;
	logic                      arb_RLAST;
	logic                      arb_RVALID;
	logic                      arb_RREADY;
	logic [6:0]                R_device;
	logic [2:0]                R_decode;
// AW logic
    logic [`AXI_ADDR_BITS-1:0] arb_AWADDR;
  	logic [5:0] AW_decode;
    logic [               1:0] AW_grant;
    logic                      arb_AWREADY;
    logic [`AXI_IDS_BITS-1: 0] arb_AWID;
    logic [`AXI_LEN_BITS-1: 0] arb_AWLEN;
    logic [`AXI_SIZE_BITS-1:0] arb_AWSIZE;
    logic [               1:0] arb_AWBURST;
    logic                      arb_AWVALID;
// W logic
	logic [5:0] W_device;
    logic [1:0] W_decode;
    logic [`AXI_DATA_BITS-1:0] arb_WDATA;
	logic [`AXI_STRB_BITS-1:0] arb_WSTRB;
	logic arb_WLAST;
	logic arb_WVALID;
    logic arb_WREADY;
	logic AW_using;
// B logic
	logic [5:0] B_device;
    logic [1:0] B_decode;
    logic [`AXI_ID_BITS-1:0] arb_BID;
	logic [1:0] arb_BRESP;
	logic arb_BVALID;
	logic arb_BREADY;

// default slave logic
	logic ARVALID_DECERR;
	logic ARREADY_DECERR;
	logic [`AXI_IDS_BITS-1:0] RID_DECERR;
	logic [1:0] RRESP_DECERR;
	logic RLAST_DECERR;
	logic RVALID_DECERR;
	logic RREADY_DECERR;
	
	logic AWVALID_DECERR;
	logic AWREADY_DECERR;
	
	logic WLAST_DECERR;
	logic WVALID_DECERR;
	logic WREADY_DECERR;
	
	logic [`AXI_IDS_BITS-1:0] BID_DECERR;
	logic [1:0] BRESP_DECERR;
	logic BVALID_DECERR;
	logic BREADY_DECERR;


//---------- AR ----------//
    assign AR_decode[0] = (arb_ARADDR >= MMIO_S0_START) & (arb_ARADDR <= MMIO_S0_END);
	assign AR_decode[1] = (arb_ARADDR >= MMIO_S1_START) & (arb_ARADDR <= MMIO_S1_END);
	assign AR_decode[2] = (arb_ARADDR >= MMIO_S2_START) & (arb_ARADDR <= MMIO_S2_END);
	assign AR_decode[3] = (arb_ARADDR >= MMIO_S3_START) & (arb_ARADDR <= MMIO_S3_END);
	assign AR_decode[4] = (arb_ARADDR >= MMIO_S4_START) & (arb_ARADDR <= MMIO_S4_END);
	assign AR_decode[5] = (arb_ARADDR >= MMIO_S5_START) & (arb_ARADDR <= MMIO_S5_END);

    always_ff@(posedge i_AXI_CLK or posedge i_AXI_RST)begin
	   if(i_AXI_RST) AR_using <= 1'b0;
	   else if(arb_RREADY & arb_RVALID & arb_RLAST) AR_using <= 1'b0;
	   else if(arb_ARREADY & arb_ARVALID) AR_using <= 1'b1;
    end

    arbiter_3M AR_arbiter(
		.clk  ( i_AXI_CLK ),
		.rst_n( ~i_AXI_RST ),
		.valid( {ARVALID_M2_AXI,ARVALID_M1_AXI, ARVALID_M0_AXI} ),
		.ready( {arb_RREADY,arb_RVALID, arb_RLAST} ),
		.grant( AR_grant )
	);

    // AR interconect

    assign arb_ARADDR = (AR_grant[0])? ARADDR_M0_AXI :
	                    (AR_grant[1])? ARADDR_M1_AXI : 
                        (AR_grant[2])? ARADDR_M2_AXI : {`AXI_ADDR_BITS{1'b0}};

	assign arb_ARID   = (AR_grant[0])? {4'b0000, ARID_M0_AXI} :
	                    (AR_grant[1])? {4'b0001, ARID_M1_AXI} : 
                        (AR_grant[2])? {4'b0010, ARID_M2_AXI} : {`AXI_IDS_BITS{1'b1}};	

	assign arb_ARLEN  = (AR_grant[0])? ARLEN_M0_AXI :
	                    (AR_grant[1])? ARLEN_M1_AXI : 
                        (AR_grant[2])? ARLEN_M2_AXI : {`AXI_LEN_BITS{1'b0}};

	assign arb_ARSIZE = (AR_grant[0])? ARSIZE_M0_AXI :
	                    (AR_grant[1])? ARSIZE_M1_AXI : 
                        (AR_grant[2])? ARSIZE_M2_AXI : {`AXI_SIZE_BITS{1'b0}};

	assign arb_ARBURST = (AR_grant[0])? ARBURST_M0_AXI :
	                     (AR_grant[1])? ARBURST_M1_AXI : 
                         (AR_grant[2])? ARBURST_M1_AXI : 2'b00;

	assign arb_ARVALID = (AR_grant[0])? ARVALID_M0_AXI :
	                     (AR_grant[1])? ARVALID_M1_AXI : 
                         (AR_grant[2])? ARVALID_M2_AXI : 1'b0;

	assign arb_ARREADY = (AR_decode[0])? ARREADY_S0_AXI :
	                     (AR_decode[1])? ARREADY_S1_AXI : 
						 (AR_decode[2])? ARREADY_S2_AXI : 
						 (AR_decode[3])? ARREADY_S3_AXI : 
						 (AR_decode[4])? ARREADY_S4_AXI : 
						 (AR_decode[5])? ARREADY_S5_AXI : ARREADY_DECERR;

    
    // AR conect to each device

    assign ARREADY_M0_AXI = (AR_grant[0])? arb_ARREADY: 1'b0;
    assign ARREADY_M1_AXI = (AR_grant[1])? arb_ARREADY: 1'b0;
	assign ARREADY_M2_AXI = (AR_grant[2])? arb_ARREADY: 1'b0;

    assign ARID_S0_AXI    = (AR_decode[0])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S0_AXI  = (AR_decode[0])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S0_AXI   = (AR_decode[0])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S0_AXI  = (AR_decode[0])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S0_AXI = (AR_decode[0])? arb_ARBURST : 2'b00;
    assign ARVALID_S0_AXI = (AR_decode[0])? arb_ARVALID : 1'b0;

    assign ARID_S1_AXI    = (AR_decode[1])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S1_AXI  = (AR_decode[1])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S1_AXI   = (AR_decode[1])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S1_AXI  = (AR_decode[1])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S1_AXI = (AR_decode[1])? arb_ARBURST : 2'b00;
    assign ARVALID_S1_AXI = (AR_decode[1])? arb_ARVALID : 1'b0;

    assign ARID_S2_AXI    = (AR_decode[2])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S2_AXI  = (AR_decode[2])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S2_AXI   = (AR_decode[2])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S2_AXI  = (AR_decode[2])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S2_AXI = (AR_decode[2])? arb_ARBURST : 2'b00;
    assign ARVALID_S2_AXI = (AR_decode[2])? arb_ARVALID : 1'b0;

    assign ARID_S3_AXI    = (AR_decode[3])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S3_AXI  = (AR_decode[3])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S3_AXI   = (AR_decode[3])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S3_AXI  = (AR_decode[3])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S3_AXI = (AR_decode[3])? arb_ARBURST : 2'b00;
    assign ARVALID_S3_AXI = (AR_decode[3])? arb_ARVALID : 1'b0;

    assign ARID_S4_AXI    = (AR_decode[4])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S4_AXI  = (AR_decode[4])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S4_AXI   = (AR_decode[4])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S4_AXI  = (AR_decode[4])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S4_AXI = (AR_decode[4])? arb_ARBURST : 2'b00;
    assign ARVALID_S4_AXI = (AR_decode[4])? arb_ARVALID : 1'b0;

    assign ARID_S5_AXI    = (AR_decode[5])? arb_ARID    : {`AXI_IDS_BITS{1'b0}};
    assign ARADDR_S5_AXI  = (AR_decode[5])? arb_ARADDR  : {`AXI_ADDR_BITS{1'b0}};
    assign ARLEN_S5_AXI   = (AR_decode[5])? arb_ARLEN   : {`AXI_LEN_BITS{1'b0}};
    assign ARSIZE_S5_AXI  = (AR_decode[5])? arb_ARSIZE  : {`AXI_SIZE_BITS{1'b0}};
    assign ARBURST_S5_AXI = (AR_decode[5])? arb_ARBURST : 2'b00;
    assign ARVALID_S5_AXI = (AR_decode[5])? arb_ARVALID : 1'b0;

	assign ARVALID_DECERR = ((AR_decode == 6'd0))? arb_ARVALID : 1'b0;



    //---------- R ----------//
    always_ff@(posedge i_AXI_CLK or posedge i_AXI_RST)begin
	   if(i_AXI_RST) R_device <= 7'b0000000;
	   else if(arb_ARREADY & arb_ARVALID & ~AR_using) begin
            case (AR_decode)
                6'b000001: R_device <= 7'b0000001;
                6'b000010: R_device <= 7'b0000010;
                6'b000100: R_device <= 7'b0000100;
                6'b001000: R_device <= 7'b0001000;
                6'b010000: R_device <= 7'b0010000;
                6'b100000: R_device <= 7'b0100000;
                default: R_device <= 7'b1000000;
            endcase
       end
    end


    assign arb_RID    = (R_device[6])? RID_DECERR :
	                    (R_device[0])? RID_S0_AXI :
	                    (R_device[1])? RID_S1_AXI : 
						(R_device[2])? RID_S2_AXI : 
						(R_device[3])? RID_S3_AXI : 
						(R_device[4])? RID_S4_AXI : 
						(R_device[5])? RID_S5_AXI : {`AXI_IDS_BITS{1'b0}};

	assign arb_RDATA  = (R_device[6])? {`AXI_DATA_BITS{1'b1}} :
	                    (R_device[0])? RDATA_S0_AXI :
	                    (R_device[1])? RDATA_S1_AXI : 
						(R_device[2])? RDATA_S2_AXI : 
						(R_device[3])? RDATA_S3_AXI : 
						(R_device[4])? RDATA_S4_AXI : 
						(R_device[5])? RDATA_S5_AXI : {`AXI_DATA_BITS{1'b0}};

	assign arb_RRESP  = (R_device[6])? RRESP_DECERR :
	                    (R_device[0])? RRESP_S0_AXI :
	                    (R_device[1])? RRESP_S1_AXI : 
						(R_device[2])? RRESP_S2_AXI : 
						(R_device[3])? RRESP_S3_AXI : 
						(R_device[4])? RRESP_S4_AXI : 
						(R_device[5])? RRESP_S5_AXI : 2'b00;

	assign arb_RLAST  = (R_device[6])? RLAST_DECERR :
	                    (R_device[0])? RLAST_S0_AXI :
	                    (R_device[1])? RLAST_S1_AXI : 
						(R_device[2])? RLAST_S2_AXI : 
						(R_device[3])? RLAST_S3_AXI : 
						(R_device[4])? RLAST_S4_AXI : 
						(R_device[5])? RLAST_S5_AXI : 1'b0;

	assign arb_RVALID = (R_device[6])? RVALID_DECERR :
	                    (R_device[0])? RVALID_S0_AXI :
	                    (R_device[1])? RVALID_S1_AXI : 
						(R_device[2])? RVALID_S2_AXI : 
						(R_device[3])? RVALID_S3_AXI : 
						(R_device[4])? RVALID_S4_AXI : 
						(R_device[5])? RVALID_S5_AXI : 1'b0;


    assign R_decode[0] = (arb_RID[7:4] == 4'b0000);
	assign R_decode[1] = (arb_RID[7:4] == 4'b0001);
    assign R_decode[2] = (arb_RID[7:4] == 4'b0010);


    assign RID_M0_AXI    = (R_decode[0])? arb_RID[3:0] : {`AXI_ID_BITS{1'b0}};
	assign RDATA_M0_AXI  = (R_decode[0])? arb_RDATA    : {`AXI_DATA_BITS{1'b0}};
	assign RRESP_M0_AXI  = (R_decode[0])? arb_RRESP    : 2'b00;
	assign RLAST_M0_AXI  = (R_decode[0] & AR_using)? arb_RLAST    : 1'b0;
	assign RVALID_M0_AXI = (R_decode[0] & AR_using)? arb_RVALID   : 1'b0;

	assign RID_M1_AXI    = (R_decode[1])? arb_RID[3:0] : {`AXI_ID_BITS{1'b0}};
	assign RDATA_M1_AXI  = (R_decode[1])? arb_RDATA    : {`AXI_DATA_BITS{1'b0}};
	assign RRESP_M1_AXI  = (R_decode[1])? arb_RRESP    : 2'b00;
	assign RLAST_M1_AXI  = (R_decode[1] & AR_using)? arb_RLAST    : 1'b0;
	assign RVALID_M1_AXI = (R_decode[1] & AR_using)? arb_RVALID   : 1'b0;

    assign RID_M2_AXI    = (R_decode[2])? arb_RID[3:0] : {`AXI_ID_BITS{1'b0}};
	assign RDATA_M2_AXI  = (R_decode[2])? arb_RDATA    : {`AXI_DATA_BITS{1'b0}};
	assign RRESP_M2_AXI  = (R_decode[2])? arb_RRESP    : 2'b00;
	assign RLAST_M2_AXI  = (R_decode[2] & AR_using)? arb_RLAST    : 1'b0;
	assign RVALID_M2_AXI = (R_decode[2] & AR_using)? arb_RVALID   : 1'b0;

    assign arb_RREADY = (R_decode[0])? RREADY_M0_AXI :
	                    (R_decode[1])? RREADY_M1_AXI : 
                        (R_decode[2])? RREADY_M2_AXI :1'b0;


    assign RREADY_S0_AXI = (R_device[0] & AR_using)? arb_RREADY: 1'b0;
    assign RREADY_S1_AXI = (R_device[1] & AR_using)? arb_RREADY: 1'b0;
    assign RREADY_S2_AXI = (R_device[2] & AR_using)? arb_RREADY: 1'b0;
    assign RREADY_S3_AXI = (R_device[3] & AR_using)? arb_RREADY: 1'b0;
    assign RREADY_S4_AXI = (R_device[4] & AR_using)? arb_RREADY: 1'b0;
    assign RREADY_S5_AXI = (R_device[5] & AR_using)? arb_RREADY: 1'b0;

	assign RREADY_DECERR = (R_device[6] & AR_using)? arb_RREADY: 1'b0;


//---------- AW ----------//

    assign AW_decode[0] = (arb_AWADDR >= MMIO_S0_START) & (arb_AWADDR <= MMIO_S0_END);
	assign AW_decode[1] = (arb_AWADDR >= MMIO_S1_START) & (arb_AWADDR <= MMIO_S1_END);
	assign AW_decode[2] = (arb_AWADDR >= MMIO_S2_START) & (arb_AWADDR <= MMIO_S2_END);
	assign AW_decode[3] = (arb_AWADDR >= MMIO_S3_START) & (arb_AWADDR <= MMIO_S3_END);
	assign AW_decode[4] = (arb_AWADDR >= MMIO_S4_START) & (arb_AWADDR <= MMIO_S4_END);
	assign AW_decode[5] = (arb_AWADDR >= MMIO_S5_START) & (arb_AWADDR <= MMIO_S5_END);

    always_ff @( posedge i_AXI_CLK or posedge i_AXI_RST ) begin
		if(i_AXI_RST) AW_using <= 1'b0;
		else if( arb_AWVALID & arb_AWREADY) AW_using <= 1'b1;
		else if( arb_BREADY & arb_BVALID ) AW_using <= 1'b0;
	end

    arbiter AW_arbiter(
		.clk  ( i_AXI_CLK ),
		.rst_n( ~i_AXI_RST ),
		.valid( {AWVALID_M2_AXI,AWVALID_M1_AXI} ),
		.ready( {arb_BVALID,arb_BREADY} ),
		.grant( AW_grant )
	);


    // AW interconect

    assign arb_AWADDR = (AW_grant[0])? AWADDR_M1_AXI :
	                    (AW_grant[1])? AWADDR_M2_AXI : {`AXI_ADDR_BITS{1'b0}};

	assign arb_AWID   = (AW_grant[0])? {4'b0000, AWID_M1_AXI} :
	                    (AW_grant[1])? {4'b0001, AWID_M2_AXI} : {`AXI_IDS_BITS{1'b1}};	

	assign arb_AWLEN  = (AW_grant[0])? AWLEN_M1_AXI :
	                    (AW_grant[1])? AWLEN_M2_AXI : {`AXI_LEN_BITS{1'b0}};

	assign arb_AWSIZE = (AW_grant[0])? AWSIZE_M1_AXI :
	                    (AW_grant[1])? AWSIZE_M2_AXI : {`AXI_SIZE_BITS{1'b0}};

	assign arb_AWBURST = (AW_grant[0])? AWBURST_M1_AXI :
	                     (AW_grant[1])? AWBURST_M2_AXI : 2'b00;

	assign arb_AWVALID = (AW_grant[0])? AWVALID_M1_AXI :
	                     (AW_grant[1])? AWVALID_M2_AXI : 1'b0;

	assign arb_AWREADY = (AW_decode[0])? AWREADY_S0_AXI :
	                     (AW_decode[1])? AWREADY_S1_AXI : 
						 (AW_decode[2])? AWREADY_S2_AXI : 
						 (AW_decode[3])? AWREADY_S3_AXI : 
						 (AW_decode[4])? AWREADY_S4_AXI : 
						 (AW_decode[5])? AWREADY_S5_AXI : AWREADY_DECERR;

    // AW connect to each other

    assign AWREADY_M1_AXI = (AW_grant[0])? arb_AWREADY: 1'b0;
    assign AWREADY_M2_AXI = (AW_grant[1])? arb_AWREADY: 1'b0;

	assign AWID_S0_AXI    = (AW_decode[0])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S0_AXI  = (AW_decode[0])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S0_AXI   = (AW_decode[0])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S0_AXI  = (AW_decode[0])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S0_AXI = (AW_decode[0])? arb_AWBURST : 2'b00;
	assign AWVALID_S0_AXI = (AW_decode[0])? arb_AWVALID : 1'b0;

	assign AWID_S1_AXI    = (AW_decode[1])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S1_AXI  = (AW_decode[1])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S1_AXI   = (AW_decode[1])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S1_AXI  = (AW_decode[1])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S1_AXI = (AW_decode[1])? arb_AWBURST : 2'b00;
	assign AWVALID_S1_AXI = (AW_decode[1])? arb_AWVALID : 1'b0;

	assign AWID_S2_AXI    = (AW_decode[2])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S2_AXI  = (AW_decode[2])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S2_AXI   = (AW_decode[2])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S2_AXI  = (AW_decode[2])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S2_AXI = (AW_decode[2])? arb_AWBURST : 2'b00;
	assign AWVALID_S2_AXI = (AW_decode[2])? arb_AWVALID : 1'b0;

	assign AWID_S3_AXI    = (AW_decode[3])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S3_AXI  = (AW_decode[3])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S3_AXI   = (AW_decode[3])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S3_AXI  = (AW_decode[3])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S3_AXI = (AW_decode[3])? arb_AWBURST : 2'b00;
	assign AWVALID_S3_AXI = (AW_decode[3])? arb_AWVALID : 1'b0;

	assign AWID_S4_AXI    = (AW_decode[4])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S4_AXI  = (AW_decode[4])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S4_AXI   = (AW_decode[4])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S4_AXI  = (AW_decode[4])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S4_AXI = (AW_decode[4])? arb_AWBURST : 2'b00;
	assign AWVALID_S4_AXI = (AW_decode[4])? arb_AWVALID : 1'b0;

	assign AWID_S5_AXI    = (AW_decode[5])? arb_AWID    : {`AXI_IDS_BITS{1'b0}};
	assign AWADDR_S5_AXI  = (AW_decode[5])? arb_AWADDR  : {`AXI_ADDR_BITS{1'b0}};
	assign AWLEN_S5_AXI   = (AW_decode[5])? arb_AWLEN   : {`AXI_LEN_BITS{1'b0}};
	assign AWSIZE_S5_AXI  = (AW_decode[5])? arb_AWSIZE  : {`AXI_SIZE_BITS{1'b0}};
	assign AWBURST_S5_AXI = (AW_decode[5])? arb_AWBURST : 2'b00;
	assign AWVALID_S5_AXI = (AW_decode[5])? arb_AWVALID : 1'b0;

	assign AWVALID_DECERR = (AW_decode == 6'd0)? arb_AWVALID : 1'b0;

//----------  W ----------//

    always_ff @( posedge i_AXI_CLK or posedge i_AXI_RST ) begin
		if(i_AXI_RST) begin
            W_device <= 6'd0;
            W_decode <= 2'd0;

            B_device <= 6'd0;
            B_decode <= 2'd0;
        end
		else if( arb_AWVALID & arb_AWREADY & ~AW_using) begin
            W_device <= AW_decode;// represent which slave use W
            B_device <= AW_decode;;
            // represent which master use W
            W_decode[0] <= (arb_AWID[7:4] == 4'b0000);
            W_decode[1] <= (arb_AWID[7:4] == 4'b0001);
            B_decode[0] <= (arb_AWID[7:4] == 4'b0000);
            B_decode[1] <= (arb_AWID[7:4] == 4'b0001);

        end
	end


    assign arb_WDATA =  (W_decode[0])? WDATA_M1_AXI :
	                    (W_decode[1])? WDATA_M2_AXI : {`AXI_ADDR_BITS{1'b0}};

    assign arb_WSTRB =  (W_decode[0])? WSTRB_M1_AXI :
	                    (W_decode[1])? WSTRB_M2_AXI : {`AXI_STRB_BITS{1'b0}};

    assign arb_WLAST =  (W_decode[0])? WLAST_M1_AXI :
	                    (W_decode[1])? WLAST_M2_AXI : 1'b0; 

    assign arb_WVALID = (W_decode[0])? WVALID_M1_AXI :
	                    (W_decode[1])? WVALID_M2_AXI : 1'b0;
    
    assign arb_WREADY = (W_device == 6'd0)? WREADY_DECERR :
                        (W_device[0])? WREADY_S0_AXI :
	                    (W_device[1])? WREADY_S1_AXI : 
						(W_device[2])? WREADY_S2_AXI : 
						(W_device[3])? WREADY_S3_AXI : 
						(W_device[4])? WREADY_S4_AXI : 
						(W_device[5])? WREADY_S5_AXI : 1'b0;

    // connect to each other

    assign WDATA_S0_AXI  = arb_WDATA;
	assign WSTRB_S0_AXI  = arb_WSTRB;
	assign WLAST_S0_AXI  = (W_device[0])? arb_WLAST : 1'b0;
	assign WVALID_S0_AXI = (W_device[0] & AW_using)? arb_WVALID : 1'b0;

    assign WDATA_S1_AXI  = arb_WDATA;
	assign WSTRB_S1_AXI  = arb_WSTRB;
	assign WLAST_S1_AXI  = (W_device[1])? arb_WLAST : 1'b0;
	assign WVALID_S1_AXI = (W_device[1] & AW_using)? arb_WVALID : 1'b0;

    assign WDATA_S2_AXI  = arb_WDATA;
	assign WSTRB_S2_AXI  = arb_WSTRB;
	assign WLAST_S2_AXI  = (W_device[2])? arb_WLAST : 1'b0;
	assign WVALID_S2_AXI = (W_device[2] & AW_using)? arb_WVALID : 1'b0;

    assign WDATA_S3_AXI  = arb_WDATA;
	assign WSTRB_S3_AXI  = arb_WSTRB;
	assign WLAST_S3_AXI  = (W_device[3])? arb_WLAST : 1'b0;
	assign WVALID_S3_AXI = (W_device[3] & AW_using)? arb_WVALID : 1'b0;

    assign WDATA_S4_AXI  = arb_WDATA;
	assign WSTRB_S4_AXI  = arb_WSTRB;
	assign WLAST_S4_AXI  = (W_device[4])? arb_WLAST : 1'b0;
	assign WVALID_S4_AXI = (W_device[4] & AW_using)? arb_WVALID : 1'b0;

    assign WDATA_S5_AXI  = arb_WDATA;
	assign WSTRB_S5_AXI  = arb_WSTRB;
	assign WLAST_S5_AXI  = (W_device[5])? arb_WLAST : 1'b0;
	assign WVALID_S5_AXI = (W_device[5] & AW_using)? arb_WVALID : 1'b0;

    assign WLAST_DECERR  = (W_device == 6'd0)? arb_WLAST : 1'b0;
	assign WVALID_DECERR = ((W_device == 6'd0) & AW_using)? arb_WVALID : 1'b0;

    assign WREADY_M1_AXI = (AW_using & W_decode[0])? arb_WREADY:1'b0;
    assign WREADY_M2_AXI = (AW_using & W_decode[1])? arb_WREADY:1'b0;
//----------  B ----------//

    assign arb_BID =    (B_device == 6'd0)? BID_DECERR :
                        (B_device[0])? BID_S0_AXI :
	                    (B_device[1])? BID_S1_AXI : 
						(B_device[2])? BID_S2_AXI : 
						(B_device[3])? BID_S3_AXI : 
						(B_device[4])? BID_S4_AXI : 
						(B_device[5])? BID_S5_AXI : 1'b0;

    assign arb_BRESP =  (B_device == 6'd0)? BRESP_DECERR :
                        (B_device[0])? BRESP_S0_AXI :
	                    (B_device[1])? BRESP_S1_AXI : 
						(B_device[2])? BRESP_S2_AXI : 
						(B_device[3])? BRESP_S3_AXI : 
						(B_device[4])? BRESP_S4_AXI : 
						(B_device[5])? BRESP_S5_AXI : 1'b0;

    assign arb_BVALID = (B_device == 6'd0)? BVALID_DECERR :
                        (B_device[0])? BVALID_S0_AXI :
	                    (B_device[1])? BVALID_S1_AXI : 
						(B_device[2])? BVALID_S2_AXI : 
						(B_device[3])? BVALID_S3_AXI : 
						(B_device[4])? BVALID_S4_AXI : 
						(B_device[5])? BVALID_S5_AXI : 1'b0;

    assign arb_BREADY = (B_decode[0])? BREADY_M1_AXI :
	                    (B_decode[1])? BREADY_M2_AXI : 1'b0;

     // connect to each other

    assign BID_M1_AXI = arb_BID;
    assign BID_M2_AXI = arb_BID;

    assign BRESP_M1_AXI = arb_BRESP;
    assign BRESP_M2_AXI = arb_BRESP;

    assign BVALID_M1_AXI = (AW_using & B_decode[0])? arb_BVALID:1'b0;
    assign BVALID_M2_AXI = (AW_using & B_decode[1])? arb_BVALID:1'b0;

    assign BREADY_S0_AXI = (AW_using & B_device[0])? arb_BREADY:1'b0;
    assign BREADY_S1_AXI = (AW_using & B_device[1])? arb_BREADY:1'b0;
    assign BREADY_S2_AXI = (AW_using & B_device[2])? arb_BREADY:1'b0;
    assign BREADY_S3_AXI = (AW_using & B_device[3])? arb_BREADY:1'b0;
    assign BREADY_S4_AXI = (AW_using & B_device[4])? arb_BREADY:1'b0;
    assign BREADY_S5_AXI = (AW_using & B_device[5])? arb_BREADY:1'b0;
    assign BREADY_DECERR = (AW_using && (B_device==6'd0))? arb_BREADY:1'b0;
    
//------------------------//
//     default slave      //
//------------------------//
	default_slave DECERR_SLV(
	// AXI slave
	  .ACLK   ( i_AXI_CLK ),
	  .ARESETn( ~i_AXI_RST ),

	  //read addr
	  .ARID   ( arb_ARID ) ,
	  .ARLEN  ( arb_ARLEN ),
	  .ARVALID( ARVALID_DECERR ),
	  .ARREADY( ARREADY_DECERR ),

	  //read data
	  .RID( RID_DECERR ),
	  .RRESP( RRESP_DECERR ),
	  .RLAST( RLAST_DECERR ),
	  .RVALID( RVALID_DECERR ),
	  .RREADY( RREADY_DECERR ),

	  //write addr
	  .AWID( {4'b0,AWID_M1} ),
	  .AWLEN( AWLEN_M1 ),
	  .AWVALID( AWVALID_DECERR ),
	  .AWREADY( AWREADY_DECERR ),
	  //write data
	  .WLAST( WLAST_DECERR ),
	  .WVALID( WVALID_DECERR ),
	  .WREADY( WREADY_DECERR ),
	  //write responce
	  .BID( BID_DECERR ),
	  .BRESP( BRESP_DECERR ),
	  .BVALID( BVALID_DECERR ),
	  .BREADY( BREADY_DECERR )
	);
endmodule