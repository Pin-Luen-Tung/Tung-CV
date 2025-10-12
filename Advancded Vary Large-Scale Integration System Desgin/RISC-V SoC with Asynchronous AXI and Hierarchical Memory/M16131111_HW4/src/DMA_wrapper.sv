
module DMA_wrapper #(
    parameter ADDR_BEGIN 	=	32'h1002_0000,
	parameter ADDR_END		=	32'h1002_0400
) (
    input ACLK,
	input ARESETn,
	
	//////////////////////////slave port///////////////// 
    //read channels are unused!!!!!!!!
    //READ ADDRESS S3
	input [`AXI_IDS_BITS-1:0] ARID_S3,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	input [`AXI_LEN_BITS-1:0] ARLEN_S3,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	input [1:0] ARBURST_S3,
	input ARVALID_S3,
	output logic ARREADY_S3,	
	//READ DATA0 S3
	output  [`AXI_IDS_BITS-1:0] RID_S3,
	output  [`AXI_DATA_BITS-1:0] RDATA_S3,
	output logic [1:0] RRESP_S3,
	output logic RLAST_S3,
	output logic RVALID_S3,
	input RREADY_S3,

	//WRITE ADDRESS S3
	input [`AXI_IDS_BITS-1:0] AWID_S3,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	input [`AXI_LEN_BITS-1:0] AWLEN_S3,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	input [1:0] AWBURST_S3,
	input AWVALID_S3,
	output logic AWREADY_S3,	
	//WRITE DATA S3
	input [`AXI_DATA_BITS-1:0] WDATA_S3,
	input [`AXI_STRB_BITS-1:0] WSTRB_S3,
	input WLAST_S3,
	input WVALID_S3,
	output logic WREADY_S3,	
	//WRITE RESPONSE S3
	output logic [`AXI_IDS_BITS-1:0] BID_S3,
	output logic [1:0] BRESP_S3,
	output logic BVALID_S3,
	input BREADY_S3,
	
	//////////////////////////master port/////////////////
	//READ ADDRESS0 M2
	output logic [`AXI_ID_BITS-1:0] ARID_M2,
	output logic[`AXI_ADDR_BITS-1:0] ARADDR_M2,
	output logic[`AXI_LEN_BITS-1:0] ARLEN_M2,
	output logic[`AXI_SIZE_BITS-1:0] ARSIZE_M2,
	output logic[1:0] ARBURST_M2,
	output logic ARVALID_M2,
	input ARREADY_M2,
	//READ DATA0 M2
	input [`AXI_ID_BITS-1:0] RID_M2,
	input [`AXI_DATA_BITS-1:0] RDATA_M2,
	input [1:0] RRESP_M2,
	input RLAST_M2,
	input RVALID_M2,
	output logic RREADY_M2,
	
	//WRITE ADDRESS M2
	output logic[`AXI_ID_BITS-1:0] AWID_M2,
	output logic[`AXI_ADDR_BITS-1:0] AWADDR_M2,
	output logic[`AXI_LEN_BITS-1:0] AWLEN_M2,
	output logic[`AXI_SIZE_BITS-1:0] AWSIZE_M2,
	output logic[1:0] AWBURST_M2,
	output logic AWVALID_M2,
	input AWREADY_M2,
	//WRITE DATA M2
	output logic[`AXI_DATA_BITS-1:0] WDATA_M2,
	output logic[`AXI_STRB_BITS-1:0] WSTRB_M2,
	output logic WLAST_M2,
	output logic WVALID_M2,
	input WREADY_M2,
	//WRITE RESPONSE M2
	input [`AXI_ID_BITS-1:0] BID_M2,
	input [1:0] BRESP_M2,
	input BVALID_M2,
	output logic BREADY_M2,
	
	//interrupt
	output logic interrupt
);
    
    //self define
    logic [31:0] slave_addr;
    logic [31:0] master_addr;
    logic [31:0] master_wr_data;
    logic rd_valid;
    logic wr_valid;
    parameter [1:0] AW=2'd0, W=2'd1, B=2'd2;
    logic [1:0] w_state_slave,w_nstate_slave;
    parameter AR=1'b0, R=1'b1; 
    logic r_state_master,r_nstate_master;
    logic [1:0] w_state_master,w_nstate_master;

//DMA
    DMA dma(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    //slave ports
    .slave_addr(slave_addr),
    .slave_data(WDATA_S3),
    .slave_W_handshake(WVALID_S3 & WREADY_S3),
    //master ports
    .master_rd_data(RDATA_M2),
    .master_addr(master_addr),
    .master_wr_data(master_wr_data),

    //control
    .master_R_handshake(RVALID_M2 & RREADY_M2),
    .master_W_handshake(WVALID_M2 & WREADY_M2),
    .rd_valid(rd_valid),
    .wr_valid(wr_valid),

    //interrupt
    .interrupt(interrupt)
    );

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SLAVE WRITE DATA
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff@(posedge ACLK)begin
	    if(AWVALID_S3 & AWREADY_S3)
		    slave_addr <= AWADDR_S3;
    end

    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    w_state_slave <= AW;
	    else 
		    w_state_slave <=w_nstate_slave ;
    end

    always_comb begin
	    case(w_state_slave)
	        AW: w_nstate_slave=(AWVALID_S3 & AWREADY_S3)?W:AW;
	        W: w_nstate_slave=(WVALID_S3 & WREADY_S3 & WLAST_S3)?B:W;
	        B: w_nstate_slave=(BVALID_S3 & BREADY_S3)?AW:B;
	        default:w_nstate_slave=AW;
	    endcase
    end

    always_comb begin
	    if(w_state_slave==AW)
		    AWREADY_S3 = 1'b1;
	    else 
		    AWREADY_S3 = 1'b0;
    end

    always_comb begin
	    if(w_state_slave==W)
		    WREADY_S3 = 1'b1;
	    else 
		    WREADY_S3 = 1'b0;
    end

    always_comb begin
	    if(w_state_slave==B)
		    BVALID_S3 = 1'b1;
	    else 
		    BVALID_S3 = 1'b0;
    end

    assign BID_S3=AWID_S3;
    assign BRESP=2'd0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MASTER WRITE OR READ DATA
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //read fsm
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    r_state_master <= AR;
	    else 
		    r_state_master <=r_nstate_master ;
    end

    always_comb begin
	    case(r_state_master)
	        AR: r_nstate_master=(ARVALID_M2 & ARREADY_M2)?R:AR;
	        R: r_nstate_master=(RVALID_M2 & RREADY_M2 & RLAST_M2)?AR:R;
	        default:r_nstate_master=AR;
	    endcase
    end

    //read
    always_comb begin
	    if(r_state_master==AR)begin
		    ARID_M2 = 4'd0;
		    ARADDR_M2 = master_addr;
		    ARLEN_M2 = 4'd0;//brust lengh is 1
		    ARSIZE_M2 = 3'd2;//4 bytes in a burst
		    ARBURST_M2 = 2'b01;//burst type is INCR
		    ARVALID_M2 = rd_valid;
	    end
	    else begin
		    ARID_M2 = 4'd0;
		    ARADDR_M2 = 32'd0;
		    ARLEN_M2 = 4'd0;
		    ARSIZE_M2 = 3'd0;
		    ARBURST_M2 = 2'd0;
		    ARVALID_M2 =1'b0;
		    ARVALID_M2 = 1'b0;
	    end
    end

    always_comb begin
	    if(r_state_master==R)
		    RREADY_M2 = rd_valid;		
	    else 
		    RREADY_M2 = 1'b0;
    end

    //write fsm
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    w_state_master <= AW;
	    else 
		    w_state_master <=w_nstate_master ;
    end

    always_comb begin
	    case(w_state_master)
	        AW: w_nstate_master=(AWVALID_M2 & AWREADY_M2)?W:AW;
	        W: w_nstate_master=(WVALID_M2 & WREADY_M2 & WLAST_M2)?B:W;
	        B: w_nstate_master=(BVALID_M2 & BREADY_M2)?AW:B;
	        default:w_nstate_master=AW;
	    endcase
    end

    //write
    always_comb begin
	    if(w_state_master==AW)begin		
		    AWID_M2 = 4'd0;
		    AWADDR_M2 = master_addr;
		    AWLEN_M2 = 4'd0;//brust lengh is 1
		    AWSIZE_M2 = 3'd2;//4 bytes in a burst
		    AWBURST_M2 = 2'b01;//burst type is INCR
		    AWVALID_M2 = wr_valid;
	    end
	    else begin
		    AWID_M2 = 4'd0;
		    AWADDR_M2 = 0;
		    AWLEN_M2 = 20'd0;
		    AWSIZE_M2 = 3'd0;
		    AWBURST_M2 = 2'd0;
		    AWVALID_M2 =1'b0;
	    end
    end

    always_comb begin
	    if(w_state_master==W)begin
		    WDATA_M2 = master_wr_data;
		    WSTRB_M2 = 4'b1111;//4'b1111;
		    WLAST_M2 = 1'b1;
		    WVALID_M2 = wr_valid;
	    end
	    else begin
		    WDATA_M2 = 0;
		    WSTRB_M2 = 4'd0;//0;
		    WLAST_M2 = 1'b0;
		    WVALID_M2 = 1'b0;
	    end
    end

    always_comb begin
	    if(w_state_master==B)
		    BREADY_M2 = 1'b1;		
	    else 
		    BREADY_M2 = 1'b0;
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module DMA #(
    parameter DMAEN_Address  = 32'h10020100,
    parameter DMASRC_Address = 32'h10020200,
    parameter DMADST_Address = 32'h10020300,
    parameter DMALEN_Address = 32'h10020400
) (
    input ACLK,ARESETn,
    //slave ports
    input [31:0]slave_addr,slave_data,
    input slave_W_handshake,
    //master ports
    input [31:0]master_rd_data,
    output logic [31:0]master_addr,master_wr_data,

    //control 
    input master_R_handshake,master_W_handshake,
    output logic rd_valid,wr_valid,

    //interrupt
    output logic interrupt
);

//self define
    logic [1:0] state,nstate;
    parameter [1:0] IDLE=2'd0, READ=2'd1, WRITE=2'd2, INTERRUPT=2'd3; 
    logic [31:0] DMALEN;
    logic [31:0] DMASRC;
    logic [31:0] DMADST;
    logic DMAEN;
    logic last_word;

//fsm
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		   state <= IDLE;
	    else 
		   state <= nstate;		
    end

    always_comb begin
	    case(state)
		    IDLE:nstate=(DMAEN)?READ:IDLE;
		    READ:nstate=(DMAEN)?(master_R_handshake)?WRITE:READ : IDLE;
		    WRITE:nstate=(DMAEN)?(master_W_handshake)?(last_word?INTERRUPT:READ):WRITE : IDLE;
		    INTERRUPT:nstate=(DMAEN)?INTERRUPT:IDLE;
		    default:nstate = IDLE;
	    endcase
    end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SLAVE WRITE DATA
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //DMASRC
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    DMASRC <= 32'd0;
	    else if(state == IDLE) begin
		    if((slave_addr == DMASRC_Address) & slave_W_handshake)
			    DMASRC <= slave_data;
		end
	    else if((state == WRITE) & master_W_handshake)
		    DMASRC <= DMASRC + 32'd4;
    end

    //DMADST
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    DMADST <= 32'd0;
	    else if(state == IDLE) begin
		    if((slave_addr == DMADST_Address) & slave_W_handshake)
			    DMADST <= slave_data;	
		end
	    else if((state == WRITE) & master_W_handshake)
		    DMADST <= DMADST + 32'd4;
    end

    //DMALEN
    assign last_word = (DMALEN <= 32'd4);

    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    DMALEN <= 32'd0;
	    else if(state == IDLE) begin
		    if((slave_addr == DMALEN_Address) & slave_W_handshake)
			    DMALEN <= slave_data;
		end
	    else if((state == WRITE) & master_W_handshake)
		    DMALEN <=  DMALEN-32'd4;
    end

    //DMAEN
    always_ff@(posedge ACLK or negedge ARESETn)begin
	    if(!ARESETn)
		    DMAEN <= 1'b0;
	    else if((state == IDLE) || (state == INTERRUPT))
		    if((slave_addr == DMAEN_Address) & slave_W_handshake)
			    DMAEN <= slave_data[0];
    end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MASTER WRITE OR READ DATA
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    assign interrupt = (state==INTERRUPT);
    assign rd_valid = (state == READ);
    assign wr_valid = (state == WRITE);

    always_ff@(posedge ACLK)
	    if((state == READ) & master_R_handshake)
		    master_wr_data <= master_rd_data;
		
		
    always_comb begin
	    case(state)
	        READ: master_addr = DMASRC;
	        WRITE: master_addr = DMADST;
	        default: master_addr = 32'd0;
	    endcase
    end

endmodule