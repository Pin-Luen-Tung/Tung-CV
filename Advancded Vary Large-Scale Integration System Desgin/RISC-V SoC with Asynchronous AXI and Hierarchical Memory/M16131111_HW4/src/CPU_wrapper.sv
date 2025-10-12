
module CPU_wrapper (
    input ACLK,
    input ARESETn,
    
    //M0 READ ADDRESS
    output logic[`AXI_ID_BITS-1:0] ARID_M0,
    output logic[`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic[`AXI_LEN_BITS-1:0] ARLEN_M0,
    output logic[`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic[1:0] ARBURST_M0,
    output logic ARVALID_M0,
    input ARREADY_M0,
    //M0 READ DATA 
    input[`AXI_ID_BITS-1:0] RID_M0,
    input[`AXI_DATA_BITS-1:0] RDATA_M0,
    input[1:0] RRESP_M0,
    input RLAST_M0,
    input RVALID_M0,
    output logic RREADY_M0,

    //M1 READ ADDRESS
    output logic[`AXI_ID_BITS-1:0] ARID_M1,
    output logic[`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic[`AXI_LEN_BITS-1:0] ARLEN_M1,
    output logic[`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic[1:0] ARBURST_M1,
    output logic ARVALID_M1,
    input ARREADY_M1,
    //M1 READ DATA 
    input[`AXI_ID_BITS-1:0] RID_M1,
    input[`AXI_DATA_BITS-1:0] RDATA_M1,
    input[1:0] RRESP_M1,
    input RLAST_M1,
    input RVALID_M1,
    output logic RREADY_M1,

    //M1 WRITE ADDRESS
    output logic[`AXI_ID_BITS-1:0] AWID_M1,
    output logic[`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic[`AXI_LEN_BITS-1:0] AWLEN_M1,
    output logic[`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic[1:0] AWBURST_M1,
    output logic AWVALID_M1,
    input AWREADY_M1,
    //M1 WRITE DATA 
    output logic[`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic[`AXI_STRB_BITS-1:0] WSTRB_M1, //write enable
    output logic WLAST_M1,
    output logic WVALID_M1,
    input WREADY_M1,

    //WRITE RESPONCE
    input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1,

    // interrupt
    input WTO,
    input interrupt

);
// contect CPU M0
logic core_req_IM;
// contect CPU M1
logic WRITE_Data_ENABLE;
logic READ_Data_ENABLE;
logic [3:0] Data_BWEB;
// FSM parameter
localparam IDLE = 2'b00;
// MO/M1 R
logic [1:0] M0_current_state_R;
logic [1:0] M0_next_state_R;
logic [1:0] M1_current_state_R;
logic [1:0] M1_next_state_R;
localparam READ_ADDR = 2'b01;
localparam READ_DATA = 2'b10;
//M1 W
logic [1:0] M1_current_state_W;
logic [1:0] M1_next_state_W;
localparam WRITE_ADDR = 2'b01;
localparam WRITE_DATA = 2'b10;
localparam WRITE_RESPONSE = 2'b11;
// handshake flag 1 => handshake success 0 => not handshake yet
logic handshake_flag_m0_AR;
logic handshake_flag_m0_R;
logic handshake_flag_m1_AR;
logic handshake_flag_m1_R;
logic handshake_flag_m1_AW;
logic handshake_flag_m1_W;
logic handshake_flag_m1_B;

// cache port
logic [31:0] core_IM_addr;
logic [31:0] Icache_to_cpu_data;
logic Icache_req;
logic Icache_to_cpu_data_hit;

logic [31:0] core_DM_addr;
logic [31:0] Dcache_to_cpu_data;
logic Dcache_to_cpu_data_hit;
logic core_DM_req;
logic [31:0] core_DM_data;
logic Dcache_req;
logic [31:0] Dcache_addr;
logic Dcache_wen;

// handshake flag
assign handshake_flag_m0_AR = ARVALID_M0 & ARREADY_M0;
assign handshake_flag_m0_R = RVALID_M0 & RREADY_M0;

assign handshake_flag_m1_AR = ARVALID_M1 & ARREADY_M1;
assign handshake_flag_m1_R = RVALID_M1 & RREADY_M1;

assign handshake_flag_m1_AW = AWVALID_M1 & AWREADY_M1;
assign handshake_flag_m1_W = WVALID_M1 & WREADY_M1;

assign handshake_flag_m1_B = BVALID_M1 & BREADY_M1;
////////////////////////////////////////////////////////////////
//
//
//
//         M0 R
//
//
/////////////////////////////////////////////////////////////////




// M0 FSM
// M0 FSM state transfer logic 
always_comb begin
    case (M0_current_state_R)
        IDLE:begin
            M0_next_state_R = (Icache_req)? READ_ADDR : IDLE;
        end
        READ_ADDR:begin
            M0_next_state_R = (handshake_flag_m0_AR)? READ_DATA : READ_ADDR;
        end
        READ_DATA:begin
            M0_next_state_R = (handshake_flag_m0_R & RLAST_M0)? IDLE : READ_DATA;
        end
        default: begin
            M0_next_state_R = IDLE;
        end
    endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        M0_current_state_R <= IDLE;
    end
    else begin
        M0_current_state_R <= M0_next_state_R;
    end
end
// M0 AR FSM output logic
assign ARVALID_M0 = (M0_current_state_R == READ_ADDR)? 1:0; // READ_ADDR 時valid為1
// M0  AR non FSM ctrl output
assign ARID_M0 = 4'b0000;
assign ARLEN_M0 = 4'd3;
assign ARSIZE_M0 = 4'b0010;
assign ARBURST_M0 = 2'b00;
// M0 R FSM output logic
assign RREADY_M0 = (M0_current_state_R == READ_DATA); // READ_DATA 時valid為1



////////////////////////////////////////////////////////////////
//
//
//
//         M1 R
//
//
/////////////////////////////////////////////////////////////////


// M1 FSM state transfer logic for R
always_comb begin
    case (M1_current_state_R)
        IDLE:begin
            M1_next_state_R = (Dcache_req & ~Dcache_wen)? READ_ADDR : IDLE;
        end
        READ_ADDR:begin
            M1_next_state_R = (handshake_flag_m1_AR)? READ_DATA : READ_ADDR;
        end
        READ_DATA:begin
            M1_next_state_R = (handshake_flag_m1_R & RLAST_M1)? IDLE : READ_DATA;
        end
        default: begin
            M1_next_state_R = IDLE;
        end
    endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) begin
        M1_current_state_R <= IDLE;
    end
    else begin
        M1_current_state_R <= M1_next_state_R;
    end
end

// M1 AR FSM output logic
assign ARVALID_M1 = (M1_current_state_R == READ_ADDR); // READ_ADDR 時valid為1
// M1  AR non FSM ctrl output
assign ARID_M1 = 4'b1111;
assign ARLEN_M1 = 4'd3;
assign ARSIZE_M1 = 4'b0010;
assign ARBURST_M1 = 2'b00;
// M1 R FSM output logic
assign RREADY_M1 = (M1_current_state_R == READ_DATA); // READ_DATA 時valid為1




////////////////////////////////////////////////////////////////
//
//
//
//         M1 W
//
//
/////////////////////////////////////////////////////////////////


// M1 FSM state transfer logic for W
always_comb begin 
    case (M1_current_state_W)
        IDLE : begin
            M1_next_state_W = (Dcache_req & Dcache_wen)? WRITE_ADDR : IDLE;
        end
        WRITE_ADDR : begin
            M1_next_state_W = (handshake_flag_m1_AW)? WRITE_DATA : WRITE_ADDR;
        end
        WRITE_DATA : begin
            M1_next_state_W = (handshake_flag_m1_W)? WRITE_RESPONSE : WRITE_DATA;
        end
        WRITE_RESPONSE : begin
            M1_next_state_W = (handshake_flag_m1_B)? IDLE : WRITE_RESPONSE;
        end
    endcase
   end

always_ff @( posedge ACLK or negedge ARESETn ) begin 
    if(~ARESETn) begin
        M1_current_state_W <= IDLE;
    end
    else begin
        M1_current_state_W <= M1_next_state_W;
    end
end
// M1 AW FSM output logic
assign AWVALID_M1 = (M1_current_state_W == WRITE_ADDR);
// M1 AW non FSM ctrl logic
assign AWID_M1 = 4'b1111;
assign AWADDR_M1 = Dcache_addr;
assign ARADDR_M1 = Dcache_addr;
assign AWLEN_M1 = 4'b0000;
assign AWSIZE_M1 = 4'b0010;
assign AWBURST_M1 = 2'b00;
// M1 W FSM output logic
assign WLAST_M1  = (M1_current_state_W == WRITE_DATA);
assign WVALID_M1 = (M1_current_state_W == WRITE_DATA);
// M1 W non FSM ctrl logic
assign WSTRB_M1 = ~Data_BWEB;
//M1 B FSM output logic
assign BREADY_M1 = (M1_current_state_W == WRITE_RESPONSE);



CPU cpu(
    .clk( ACLK ),
    .rst( ~ARESETn ),
    //IM(M0)
    .o_Instruc_CEB    (),//no use
    .o_Instruc_WEB    (),//no use
    .o_Instruc_BWEB   (),//no use
    .o_Instruc_DI     (),//no use
    .O_Instruc_Addr_VALID ( core_req_IM ),//to flag valid address
    .o_Instruc_Addr   ( core_IM_addr ), // to output
    .i_Instruc_data   ( Icache_to_cpu_data ),
    .I_Instruc_data_hit ( Icache_to_cpu_data_hit ),// to flag hit memory data

    //DM(M1)
    .o_Data_CEB       (),//no use
    .o_Data_WEB       (),//no use
    .o_Data_BWEB      ( Data_BWEB ),
    .O_WRITE_Data_ENABLE ( WRITE_Data_ENABLE ),
    .O_READ_Data_ENABLE ( READ_Data_ENABLE ),
    .I_Data_hit ( Dcache_to_cpu_data_hit ),
    .o_Data_DI        ( core_DM_data ),
    .o_Data_Addr      ( core_DM_addr ),
    .i_Data_data      ( Dcache_to_cpu_data ),
    // interrupt
    .i_timer_interrupt_rq(WTO),
    .i_external_interrupt_rq(interrupt)
);

L1C_inst Icache(
    .clk( ACLK ),
    .rst( ~ARESETn ),
  // Core to CPU wrapper
    .core_addr ( core_IM_addr ),// IM address
    .core_req ( core_req_IM ),	// IM address valid
    .I_out ( RDATA_M0 ),// CPU wrapper data
    .I_wait (),// wait signal for cpu wrapper  but no use
    .rvalid_m0_i ( RVALID_M0 ),	// NEW
    .rready_m0_i ( RREADY_M0 ),  
    .core_wait_CD_i (), // no use
  // CPU wrapper to core
    .core_out ( Icache_to_cpu_data ),	// core data
    .core_wait ( Icache_to_cpu_data_hit ),	// this is core data valid
  // CPU wrapper to Mem
    .I_req ( Icache_req ),	// ON when L1CI_state is READ_MISS, like im_OE  
    .I_addr ( ARADDR_M0 ) // when L1CI_state is READ_MISS, send to wrapper
);
assign core_DM_req =  WRITE_Data_ENABLE | READ_Data_ENABLE;

L1C_data Dcache(
    .clk ( ACLK ),
    .rst ( ~ARESETn ),
  // Core to CPU wrapper
    .core_addr ( core_DM_addr ),
    .core_req ( core_DM_req ),
    .core_write ( Data_BWEB ),	// DM_wen from CPU
    .core_in ( core_DM_data ),
  //input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
    .D_out ( RDATA_M1  ),
    .D_wait (), // unused
    .rvalid_m1_i ( RVALID_M1 ),	// NEW
    .rready_m1_i ( RREADY_M1 ),
    .core_wait_CI_i ( handshake_flag_m1_B ), // write B handshake 
  // CPU wrapper to core
    .core_out ( Dcache_to_cpu_data ),
    .core_wait ( Dcache_to_cpu_data_hit ),
  // CPU wrapper to Mem
    .D_req ( Dcache_req ),
    .D_addr ( Dcache_addr ),
    .D_write ( Dcache_wen) ,
    .D_in ( WDATA_M1  ),
    .D_type	() // DM_wen to CPU wrapper
);

endmodule