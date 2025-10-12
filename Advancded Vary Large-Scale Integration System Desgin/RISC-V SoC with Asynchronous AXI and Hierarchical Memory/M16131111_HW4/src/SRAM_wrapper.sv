
module SRAM_wrapper #(
    parameter ADDR_BEG_IM  =	32'h0001_0000,
    parameter ADDR_BEG_DM  =	32'h0002_0000
) (
  input fuck_DM,
  // AXI slave
  input ACLK,
  input ARESETn,

  //read addr
  input [`AXI_IDS_BITS-1 :0] ARID,
  input [`AXI_ADDR_BITS-1:0] ARADDR,
  input [`AXI_LEN_BITS-1 :0] ARLEN,
  input [`AXI_SIZE_BITS-1:0] ARSIZE,
  input [1:0] ARBURST,
  input ARVALID,
  output logic ARREADY,

  //read data
  output logic [`AXI_IDS_BITS-1 :0] RID,
  output logic [`AXI_DATA_BITS-1:0] RDATA,
  output logic [1:0] RRESP,
  output logic RLAST,
  output logic RVALID,
  input RREADY,

  //write addr
  input [`AXI_IDS_BITS-1 :0] AWID,
  input [`AXI_ADDR_BITS-1:0] AWADDR,
  input [`AXI_LEN_BITS-1 :0] AWLEN,
  input [`AXI_SIZE_BITS-1:0] AWSIZE,
  input [1:0] AWBURST,
  input AWVALID,
  output logic AWREADY,
  //write data
  input [`AXI_DATA_BITS-1:0] WDATA,
  input [`AXI_STRB_BITS-1:0] WSTRB,
  input WLAST,
  input WVALID,
  output logic WREADY,
  //write responce
  output logic [`AXI_IDS_BITS-1:0] BID,
  output logic [1:0] BRESP,
  output logic BVALID,
  input BREADY
  
);
  logic CEB;
  logic WEB;
  logic [31:0] BWEB;
  logic [13:0] A;
  logic [31:0] DI;
  logic [31:0] DO;

  

logic [7:0]  ARID_r;      
logic [31:0] ARADDR_r;    
logic [3:0]  ARLEN_r;     
logic [2:0]  ARSIZE_r;    

logic [7:0]  AWID_r;    
logic [31:0] AWADDR_r;
logic [3:0]  AWLEN_r;   
logic [2:0]  AWSIZE_r;  
// logic req for can not R/W at the same time
// FSM parameter
logic read_process_flag;
logic write_process_flag;
// S R
logic  [2:0] current_state;
logic  [2:0] next_state;


localparam READ_ADDR = 3'b000;
localparam READ_DATA = 3'b001;
localparam PRE_R1 = 3'b101;
localparam PRE_R2 = 3'b110;

localparam WRITE_ADDR = 3'b010;
localparam WRITE_DATA = 3'b011;
localparam WRITE_RESPONSE = 3'b100;

//handshake_flag
logic handshake_flag_S_AR;
logic handshake_flag_S_R;
logic handshake_flag_S_AW;
logic handshake_flag_S_W;
logic handshake_flag_S_B;
// R FSM
logic [31:0] RDATA_r;
assign handshake_flag_S_AR = ARREADY & ARVALID;
assign handshake_flag_S_R = RREADY & RVALID;
assign handshake_flag_S_AW = AWVALID & AWREADY;
assign handshake_flag_S_W = WREADY & WVALID;
assign handshake_flag_S_B = BREADY & BVALID;

always_comb begin
  case (current_state)
    READ_ADDR:begin
      next_state = (handshake_flag_S_AR)? PRE_R1 : WRITE_ADDR;
    end
    PRE_R1:begin
      next_state = PRE_R2;
    end
    PRE_R2:begin
      next_state = READ_DATA;
    end
    READ_DATA:begin
      next_state = ((ARLEN_r == 0) && handshake_flag_S_R)? READ_ADDR :(handshake_flag_S_R) ? PRE_R1 : READ_DATA;
    end
    WRITE_ADDR:begin
      next_state = (handshake_flag_S_AW)? WRITE_DATA : READ_ADDR;
    end
    WRITE_DATA:begin
      next_state = (handshake_flag_S_W && WLAST)? WRITE_RESPONSE : WRITE_DATA;
    end
    WRITE_RESPONSE:begin
      next_state = (handshake_flag_S_B )? READ_ADDR : WRITE_RESPONSE;
    end
    default: begin
      next_state = READ_ADDR;
    end
  endcase
end


always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        current_state <= READ_ADDR;
    end
    else begin
        current_state <= next_state;
    end
end

    assign ARREADY = (current_state == READ_ADDR);
    
//R FSM output logic
assign read_process_flag = ((current_state == READ_DATA) | (current_state == PRE_R1))? 1 : (handshake_flag_S_AR == 0)? 0:1;

// read_reg
  always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(~ARESETn)begin
          ARID_r<=8'b0;
          ARADDR_r<=32'd0;
          ARLEN_r<=4'd0;
          ARSIZE_r<=3'd0;
          RDATA_r <= 32'd0;
      end
      else if(handshake_flag_S_AR)begin
          ARID_r<=ARID;
          ARADDR_r<=(fuck_DM)? ARADDR -ADDR_BEG_DM : ARADDR -ADDR_BEG_IM;
          ARLEN_r<=ARLEN;
          ARSIZE_r<=ARSIZE;
          RDATA_r <= DO;
      end
      else if(handshake_flag_S_R)begin
          
          ARADDR_r<=(fuck_DM)? ARADDR_r + (1 << ARSIZE_r) -ADDR_BEG_DM : ARADDR_r + (1 << ARSIZE_r) -ADDR_BEG_IM;
          ARLEN_r<=ARLEN_r - 1 ;
          RDATA_r <= DO;
      end
      else if(current_state == PRE_R2)begin
          RDATA_r <= DO;
      end
  end


 assign RID = ARID_r;
 assign RDATA = RDATA_r;
 always_ff @(posedge ACLK or negedge ARESETn)begin
    if(~ARESETn) RRESP <= 2'b00;
    else RRESP <= 2'b00;
  end
 assign RLAST = (current_state == READ_DATA) & (ARLEN_r == 0) ;
 assign RVALID = (current_state == READ_DATA);
 
 //W FSM output logic
  
  assign AWREADY = (current_state == WRITE_ADDR);

 // write_reg
  always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(~ARESETn)begin
          AWID_r<=8'b0;
          AWADDR_r<=32'd0;
          AWLEN_r<=4'd0;
          AWSIZE_r<=3'd0;
          
      end
      else if(handshake_flag_S_AW)begin
          AWID_r<=AWID;
          AWADDR_r<=(fuck_DM)? AWADDR -ADDR_BEG_DM : AWADDR -ADDR_BEG_IM;
          AWLEN_r<=AWLEN;
          AWSIZE_r<=AWSIZE;
          
      end
      else if(handshake_flag_S_W)begin
          
          AWADDR_r<=(fuck_DM)? AWADDR_r + (1 << AWSIZE_r) -ADDR_BEG_DM : AWADDR_r -ADDR_BEG_IM;
          AWLEN_r<=AWLEN_r - 1;
          
      end
  end
  assign WREADY = (current_state == WRITE_DATA);
  assign BID = AWID_r;
  // BRESP,
  always_ff @(posedge ACLK or negedge ARESETn)begin
    if(~ARESETn) BRESP <= 2'b00;
    else BRESP <= 2'b00;
  end
  assign BVALID = (current_state == WRITE_RESPONSE);
  assign CEB = 0;
  assign WEB = (handshake_flag_S_W)? 0:1;
  
  assign DI = WDATA;
  always_comb begin
    if(handshake_flag_S_W)begin
      BWEB = { {8{~WSTRB[3]}}, {8{~WSTRB[2]}}, {8{~WSTRB[1]}}, {8{~WSTRB[0]}} };
    end
    else begin
      BWEB = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
    end
  end

  always_comb begin
  case (current_state)
    READ_ADDR:begin
      A = ARADDR[15:2];
    end
    READ_DATA:begin
      A = ARADDR_r[15:2];
    end
    PRE_R1:begin
      A = ARADDR_r[15:2];
    end
    WRITE_ADDR:begin
      A = AWADDR[15:2];
    end
    WRITE_DATA:begin
      A = AWADDR_r[15:2];
    end
    WRITE_RESPONSE:begin
      A = AWADDR_r[15:2];
    end
    default: begin
      A = ARADDR[15:2];
    end
  endcase
end

  TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
    .SLP(1'b0),
    .DSLP(1'b0),
    .SD(1'b0),
    .PUDELAY(),
    .CLK(ACLK),
	  .CEB(CEB),
	  .WEB(WEB),
    .A(A),
	  .D(DI),
    .BWEB(BWEB),
    .RTSEL(2'b01),
    .WTSEL(2'b01),
    .Q(DO)
);



endmodule
