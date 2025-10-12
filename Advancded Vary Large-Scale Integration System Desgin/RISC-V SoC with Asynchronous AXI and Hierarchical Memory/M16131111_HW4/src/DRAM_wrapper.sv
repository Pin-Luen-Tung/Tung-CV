
module DRAM_wrapper #(
	parameter ADDR_BEG = 32'h2000_0000,
	parameter ADDR_END = 32'h201f_ffff
)
(
    ACLK,
	ARESETn,

//AXI	
// AW
	AWID,
	AWADDR,
	AWLEN,
	AWSIZE,
	AWBURST,
	AWVALID,
	AWREADY,
// W
	WDATA,
	WSTRB,
	WLAST,
	WVALID,
	WREADY,
// B
	BID,
	BRESP,
	BVALID,
	BREADY,	
// AR
	ARID,
	ARADDR,
	ARLEN,
	ARSIZE,
	ARBURST,
	ARVALID,
	ARREADY,
// R
	RID,
	RDATA,
	RRESP,
	RLAST,
	RVALID,	
    RREADY,
//DRAM
    DRAM_Q,     //DRAM data output
    DRAM_valid,  //DRAM data output valid
	DRAM_CSn,   //DRAM chip select
	DRAM_WEn,   //DRAM write enable
	DRAM_RASn,  //DRAM row access strobe
	DRAM_CASn,  //DRAM column access strobe
	DRAM_A,     //DRAM address input
    DRAM_D     //DRAM data input	
);

    input ACLK;
    input ARESETn;
//AXI
//  AW
	input [`AXI_IDS_BITS-1:0]  AWID;
	input [`AXI_ADDR_BITS-1:0] AWADDR;
	input [`AXI_LEN_BITS-1:0]  AWLEN;
	input [`AXI_SIZE_BITS-1:0] AWSIZE;
	input [1:0]                AWBURST;
	input                      AWVALID;
	output logic               AWREADY;
//  W
	input [`AXI_DATA_BITS-1:0] WDATA;
	input [`AXI_STRB_BITS-1:0] WSTRB;
	input                      WLAST;
	input                      WVALID;
	output logic               WREADY;
//  B
	output logic [`AXI_IDS_BITS-1:0] BID;
	output logic [1:0] BRESP;
	output logic BVALID;
	input BREADY;	
//  AR
	input [`AXI_IDS_BITS-1:0] ARID;
	input [`AXI_ADDR_BITS-1:0] ARADDR;
	input [`AXI_LEN_BITS-1:0] ARLEN;
	input [`AXI_SIZE_BITS-1:0] ARSIZE;
	input [1:0] ARBURST;
	input ARVALID;
	output logic ARREADY;
//  R
	output logic [`AXI_IDS_BITS-1:0] RID;
	output logic [`AXI_DATA_BITS-1:0] RDATA;
	output logic [1:0] RRESP;
	output logic RLAST;
	output logic RVALID;
	input RREADY;
//DRAM
    input [31:0]        DRAM_Q;     //DRAM data output
    input               DRAM_valid;  //DRAM data output valid
	output logic        DRAM_CSn;   //DRAM chip select
	output logic [3:0]  DRAM_WEn;   //DRAM write enable
	output logic        DRAM_RASn;  //DRAM row access strobe
	output logic        DRAM_CASn;  //DRAM column access strobe
	output logic [10:0] DRAM_A;     //DRAM address input
	output logic [31:0] DRAM_D;     //DRAM data input

//self define
    parameter [2:0] idle=3'd0, R_req=3'd1, R_waiting=3'd2, R_resp=3'd3, W_data=3'd4, W_req=3'd5, W_resp=3'd6;
    logic [2:0] state,nstate;
    logic r_req,w_req;
    logic DRAM_using;
    logic DRAM_valid;
    logic [1:0] w_count;
    logic [7:0] ARID_r;
    logic [31:0] ARADDR_r;
    logic [3:0] ARLEN_r;
    logic [2:0] ARSIZE_r;
    logic [1:0] r_count;
    logic [31:0] RDATA_r;
    logic [7:0] AWID_r;
    logic [31:0] AWADDR_r;
    logic [3:0] AWLEN_r;
    logic [2:0] AWSIZE_r;
    logic [31:0] WDATA_r;
    logic [3:0] WSTRB_r;
    logic DRAM_req;
    logic [31:0] DRAM_addr;
    logic [31:0] DRAM_wdata;
    logic [3:0] DRAM_wstrb;

//fsm
    always_ff @( posedge ACLK or negedge ARESETn ) begin
        if(!ARESETn)
            state<=idle;
        else
            state<=nstate;
    end
	
    always_comb begin 
        case (state)
            idle:nstate=(ARVALID & ARREADY)?R_req:((AWVALID & AWREADY)?W_data:idle);
            R_req:nstate=(DRAM_using)?R_req:R_waiting;
            R_waiting:nstate=(DRAM_valid)?R_resp:R_waiting;
            R_resp:nstate=(RVALID & RREADY & RLAST)?idle:(RVALID & RREADY & ~RLAST)?R_req:R_resp;

            W_data:nstate=(WVALID & WREADY)?W_req:W_data;
            W_req:nstate=(DRAM_using)?W_req:((w_count==AWLEN_r)?W_resp:W_data);
            W_resp:nstate=(BVALID & BREADY)?idle:W_resp;
            default: nstate=idle;
        endcase
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//READ
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//read reg
    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
        if(!ARESETn)begin
          ARID_r    <= 8'd0;
          ARADDR_r  <= 32'd0;
          ARLEN_r   <= 4'd0;
          ARSIZE_r  <= 3'd0;
        end
        else if(ARVALID & ARREADY)begin
          ARID_r   <= ARID;
          ARADDR_r <= ARADDR;
          ARLEN_r  <= ARLEN;
          ARSIZE_r <= ARSIZE;
        end
    end

    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(!ARESETn) 
        RDATA_r <= 32'd0;
      else if(DRAM_valid) 
        RDATA_r <= DRAM_Q;
  end

//r_req
    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
        if(!ARESETn) 
            r_req <= 1'b0;
        else if(ARVALID & ARREADY) 
            r_req <= 1'b1;
        else if(RVALID & RREADY & RLAST) 
            r_req <= 1'b0;
    end

//r_count
    always_ff @( posedge ACLK or negedge ARESETn ) begin
        if(!ARESETn) 
            r_count <= 2'd0;
        else if(ARVALID & ARREADY) 
            r_count <= 2'd0;
        else if(RVALID & RREADY) 
            r_count <= r_count + 2'd1;
    end

//output
    assign ARREADY = ~r_req;

    assign RID     = ARID_r;
    assign RDATA   = RDATA_r;
    assign RRESP   = 2'b00;
    assign RLAST   = (r_count == ARLEN_r) & RVALID;
    assign RVALID  = (state == R_resp);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//WRITE
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//write_reg
    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(!ARESETn)begin
          AWID_r<=8'd0;
          AWADDR_r<=32'd0;
          AWLEN_r<=4'd0;
          AWSIZE_r<=3'd0;
      end
      else if(AWVALID & AWREADY)begin
          AWID_r<=AWID;
          AWADDR_r<=AWADDR;
          AWLEN_r<=AWLEN;
          AWSIZE_r<=AWSIZE;
      end
    end

    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(!ARESETn)begin
        WDATA_r <= 32'b0;
        WSTRB_r <= 4'b0;
      end
      else if(WVALID & WREADY)begin
        WDATA_r <=  WDATA;
        WSTRB_r <=  WSTRB;
      end
    end

//w_req
    always_ff @( posedge ACLK or negedge  ARESETn ) begin 
        if(!ARESETn) 
            w_req <= 1'b0;
        else if(AWVALID & AWREADY) 
            w_req <= 1'b1;
        else if(BVALID & BREADY) 
            w_req <= 1'b0;
    end

//w_count
    always_ff @( posedge ACLK or negedge ARESETn ) begin
        if(!ARESETn) 
            w_count <= 2'd0;
        else if(AWVALID & AWREADY) 
            w_count <= 2'd0;
        else if((state == W_req) & ~DRAM_using) 
            w_count <= w_count + 2'd1;
    end

//output
    assign AWREADY = ~w_req;

    assign WREADY = (state == W_data);

	assign BID    = AWID;
	assign BRESP  = 2'b00;
	assign BVALID = (state == W_resp);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//DRAM controller
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    DRAM_controller DRAM_ctrl(
        .clk  ( ACLK ),
        .rst_n( ARESETn ),
    // wrapper 
        .req  ( DRAM_req   ),
        .busy ( DRAM_using  ),
        .addr ( DRAM_addr  ), // 1bank 11 row 10 col
        .wdata( DRAM_wdata ),
        .wstrb( DRAM_wstrb ),
    // DRAM 
        .CSn  ( DRAM_CSn   ), //DRAM chip select
        .WEn  ( DRAM_WEn   ), //DRAM write enable
        .RASn ( DRAM_RASn  ), //DRAM row access strobe
        .CASn ( DRAM_CASn  ), //DRAM column access strobe
        .A    ( DRAM_A     ), //DRAM address input
        .D    ( DRAM_D     ), //DRAM data input
        .valid( DRAM_valid )  //DRAM data output valid
    );

//DRAM control
    assign DRAM_req = (state == R_req) | (state == W_req);
    assign DRAM_addr = (state == R_req)? (ARADDR_r + (r_count << ARSIZE_r) - ADDR_BEG) : (state == W_req)? (AWADDR_r + (w_count << AWSIZE_r) - ADDR_BEG) : 32'b0;
    assign DRAM_wdata = WDATA_r;
    assign DRAM_wstrb = (state == W_req)? ~WSTRB_r : 4'b1111;

endmodule

module DRAM_controller #(
    parameter tRP  = 5,
    parameter tRCD = 5,
    parameter CL   = 5
)(
    input clk,
    input rst_n,
// wrapper 
    input  req,
    output logic busy,
    input [31:0] addr, // 1bank 11 row 10 col
    input [31:0] wdata,
    input [3:0]  wstrb,
// DRAM 
	output logic        CSn,   //DRAM chip select
	output logic [3:0]  WEn,   //DRAM write enable
	output logic        RASn,  //DRAM row access strobe
	output logic        CASn,  //DRAM column access strobe
	output logic [10:0] A,     //DRAM address input
	output logic [31:0] D,      //DRAM data input

	input               valid  //DRAM data output valid
);

//self define
    localparam [2:0] idle=3'd0, ACT=3'd1, READ=3'd2, WRITE=3'd3, WAIT=3'd4, PRE=3'd5;
    logic [2:0] state,nstate;
    logic [2:0] count;
    logic [3:0] wstrb_r;
    logic row_hit;
    logic [31:0] addr_r;
    logic [31:0] wdata_r;
    logic [10:0] row_register;

//fsm
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n) 
            state <= idle;
        else 
            state <= nstate;
    end

    always_comb begin
        case(state)
            idle   : nstate = (req)? ACT : idle;
            ACT    : nstate = ( count != (tRCD-1) )? ACT : (wstrb_r == 4'b1111)? READ : WRITE;
            READ   : nstate = ( valid )? WAIT : READ;
            WRITE  : nstate = ( count != (CL-1) )? WRITE : WAIT;
            WAIT   : nstate = (~req)? WAIT : (~row_hit)? PRE : (wstrb == 4'b1111)? READ : WRITE;
            PRE    : nstate = ( count != (tRP-1)) ? PRE : ACT;
            default: nstate = idle;
        endcase
    end

//count
    always_ff @( posedge clk or negedge rst_n) begin
        if(!rst_n) 
            count <= 3'd0;
        else if( state == ACT  ) 
            count <= ( count == (tRCD-1) )? 3'd0 : count + 1'b1;
        else if( state == READ ) 
            count <= (valid)? 3'd0 : 3'd1;
        else if( state == WRITE) 
            count <= ( count == (CL-1) )? 3'd0 : count + 1'b1;
        else if( state == PRE  ) 
            count <= ( count == (tRP-1) )? 3'd0 : count + 1'b1;
    end

//reg
    always_ff @( posedge clk or negedge rst_n) begin
        if(!rst_n) 
            addr_r <= 32'd0;
        else if(req & ~busy) 
            addr_r <= addr;
    end

    always_ff @( posedge clk or negedge rst_n) begin
        if(!rst_n) 
            wdata_r <= 32'd0;
        else if(req & ~busy) 
            wdata_r <= wdata;
    end

    always_ff @( posedge clk or negedge rst_n) begin
        if(!rst_n) 
            wstrb_r <= 4'd0;
        else if(req & ~busy) 
            wstrb_r <= wstrb;
    end

//row hit
    assign row_hit = (addr[23:12] == row_register);
    
    always_ff @(posedge clk or negedge rst_n)begin
        if(!rst_n) 
            row_register <= 11'd0;
        else if((state == ACT) & (count == 3'd0)) 
            row_register <= addr_r[23:12]; 
    end

//output
    assign busy = ~((state == idle) | (state == WAIT));
    assign CSn  = 1'b0;
    assign RASn = ~( ( (state == ACT )|(state == PRE  ) ) & (count == 3'd0) );
    assign CASn = ~( ( (state == READ)|(state == WRITE) ) & (count == 3'd0) );
    assign A    = (state == PRE)? row_register : (state == ACT)? addr_r[23:12] : ((state == READ)|(state == WRITE))? {1'b0, addr_r[12:2]} : 11'b0;
    assign WEn  = ((state == PRE) & (count == 3'd0))? 4'b0000 : (state == WRITE)? wstrb_r : 4'b1111;
    assign D    = wdata_r;

endmodule