
							
module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input [3:0] core_write,	// DM_wen from CPU
  input [`DATA_BITS-1:0] core_in,
  //input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait, // unused
  input rvalid_m1_i,	// NEW
  input rready_m1_i,
  input core_wait_CI_i, // write B handshake 
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [3:0] D_type	// DM_wen to CPU wrapper
);
  logic [`DATA_BITS-1:0] core_out_1;	// core data
  logic [`DATA_BITS-1:0] core_out_2;	// core data
  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out_1;	// 128 bits
  logic [`CACHE_DATA_BITS-1:0] DA_out_2;	// 128 bits
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out_1;
  logic [`CACHE_TAG_BITS-1:0] TA_out_2;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid_1;
  logic [`CACHE_LINES-1:0] valid_2;
  logic [31:0] LRU_map;
  logic LRU;
  logic [4:0] index_r;
  logic [32:0] fucking_SRAM;
  logic fucking_SRAM_flag;
  //--------------- complete this part by yourself -----------------//
  localparam IDLE = 2'd0;
  localparam TAG_CHECK = 2'd1;
  localparam MEM_ALLOCATE = 2'd2;
  localparam WRITE = 2'd3;
  
  logic [1:0] current_state;
  logic [1:0] next_state;
  
  logic handshake_m0_R;
  logic hit;
  logic hit_1;
  logic hit_2;
  logic [1:0] block_offset;
  logic [31:0] core_addr_r;
  logic [1:0] counter;
  logic cpu_write_req;
  // cpu_write_req
  assign cpu_write_req = ~(&core_write);

  // wrapper handshake
  assign handshake_m0_R = rvalid_m1_i & rready_m1_i;

  // FSM circuit

  always_comb begin
    case(current_state)
    IDLE    : next_state = (core_req)? TAG_CHECK : IDLE;
    TAG_CHECK     : next_state = (cpu_write_req)? WRITE : (hit)? IDLE : MEM_ALLOCATE;
    MEM_ALLOCATE: next_state = (handshake_m0_R & (counter == 2'd3))? TAG_CHECK : MEM_ALLOCATE;
    WRITE   : next_state =  (core_wait_CI_i)? IDLE:WRITE;
    endcase
  end
  
  always_ff @(posedge clk or posedge rst)begin
    if(rst) current_state <= IDLE;
    else current_state <= next_state;
  end

  // core_addr_reg
  always_ff@(posedge clk or posedge rst)begin
    if(rst) core_addr_r <= 32'b0;
    else if(core_req) core_addr_r <= core_addr;
  end

  // index
  assign index = core_addr[8:4];

  // block_offset
  assign block_offset = core_addr_r[3:2];

  // hit
  assign hit = hit_1 | hit_2;
  assign hit_1 = valid_1[core_addr_r[8:4]] & (TA_out_1 == core_addr_r[31:9]) & (current_state == TAG_CHECK);
  assign hit_2 = valid_2[core_addr_r[8:4]] & (TA_out_2 == core_addr_r[31:9]) & (current_state == TAG_CHECK);

  // IM_hit or DM_hit
  assign core_wait = (~cpu_write_req & hit) | ((current_state == WRITE) & core_wait_CI_i);

  // valid 
  always_ff@(posedge clk or posedge rst)begin
    if(rst) valid_1 <= 32'b0;
    else if((current_state == TAG_CHECK) & ~hit_1 & ~hit_2 & ~cpu_write_req) valid_1[index] <= valid_2[index]? 1'b1 : 1'b0;
  end
 
 always_ff@(posedge clk or posedge rst)begin
    if(rst) valid_2 <= 32'b0;
    else if((current_state == TAG_CHECK) & ~hit_2 & ~hit_1 & ~cpu_write_req) valid_2[index] <= 1'b1;
  end
  // counter
  always_ff@(posedge clk or posedge rst)begin
    if(rst) counter <= 2'd0;
    else if((current_state == MEM_ALLOCATE) & handshake_m0_R) counter <= counter + 1'b1;
  end

  // D_req
  assign D_req = (current_state == MEM_ALLOCATE) | (current_state == WRITE);

  // D_address
  assign D_addr = (current_state == MEM_ALLOCATE)? {core_addr_r[31:4], 4'd0} : (current_state == WRITE)? core_addr_r : 32'd0;

  // D_write
  assign D_write = (current_state == WRITE);

  // D_in
  assign D_in = core_in;

  // D_type
  assign D_type = core_write;

  // DA_write
  always_comb begin
    if(current_state == TAG_CHECK)begin
      if(cpu_write_req & hit)begin
        case(block_offset)
          2'd0: DA_write = {12'hfff,core_write};
          2'd1: DA_write = {8'hff,core_write,4'hf};
          2'd2: DA_write = {4'hf,core_write,8'hff};
          2'd3: DA_write = {core_write,12'hfff};
        endcase
      end else DA_write = 16'hffff;
    end 
    else if((current_state == MEM_ALLOCATE) & (handshake_m0_R | core_wait_CI_i))begin
      case(counter)
        2'd0: DA_write = 16'hfff0;
        2'd1: DA_write = 16'hff0f;
        2'd2: DA_write = 16'hf0ff;
        2'd3: DA_write = 16'h0fff;
      endcase
    end
    else DA_write = 16'hffff;
  end

  // DA_in
  always_comb begin
    if(current_state == TAG_CHECK)begin
        case(block_offset)
          2'd0: DA_in = {96'd0, core_in};
          2'd1: DA_in = {64'd0, core_in, 32'd0};
          2'd2: DA_in = {32'd0, core_in, 64'd0};
          2'd3: DA_in = {core_in, 96'd0};
        endcase
    end
    else if((current_state == MEM_ALLOCATE) & (handshake_m0_R | core_wait_CI_i))begin
      case(counter)
        2'd0:DA_in = {96'd0, D_out};
        2'd1:DA_in = {64'd0, D_out, 32'd0};
        2'd2:DA_in = {32'd0, D_out, 64'd0};
        2'd3:DA_in = {D_out, 96'd0};
      endcase
    end
    else DA_in = 128'd0;
  end

  // DA_read
  assign DA_read = 1'b1;

 // DA_out
  assign core_out_1  = (block_offset == 2'd0)? DA_out_1[ 0+:32]:
                     (block_offset == 2'd1)? DA_out_1[32+:32]:
                     (block_offset == 2'd2)? DA_out_1[64+:32]:
                     (block_offset == 2'd3)? (fucking_SRAM_flag)? fucking_SRAM:DA_out_1[96+:32]: 32'b0;

  assign core_out_2  = (block_offset == 2'd0)? DA_out_2[ 0+:32]:
                     (block_offset == 2'd1)? DA_out_2[32+:32]:
                     (block_offset == 2'd2)? DA_out_2[64+:32]:
                     (block_offset == 2'd3)? (fucking_SRAM_flag)? fucking_SRAM:DA_out_2[96+:32]: 32'b0;
  
  assign core_out = (hit_1)? core_out_1 :
                    (hit_2)? core_out_2 : 32'd0;
  
  data_array_wrapper DA(
    .A(index),
    .DO_1(DA_out_1),
    .DO_2(DA_out_2),
    .DI(DA_in),
    .CK(clk),
    .LRU(LRU),
    .hit_1(hit_1),
    .hit_2(hit_2),
    .WEB(DA_write),	// each bit control 1 byte, 128=16*8 bits
    .OE(DA_read),
    .CS(1'b1)
  );
  
  // TA_write
  assign TA_write = ~((current_state == TAG_CHECK) & ~hit & ~cpu_write_req);
  // TA_read
  assign TA_read  = 1'b1;
  // TA_address
  assign TA_in    = core_addr_r[31:9];
  tag_array_wrapper  TA(
    .A(index),
    .DO_1(TA_out_1),
    .DO_2(TA_out_2),
    .DI(TA_in),
    .CK(clk),
    .LRU(LRU),
    .hit_1(hit_1),
    .hit_2(hit_2),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );
  
  // LRU_map
  always_ff@(posedge clk or posedge rst)begin
    if(rst) LRU_map <= 32'd0;
    else if ((current_state == TAG_CHECK) && hit) LRU_map[index_r] <= hit_1? 1'b0:1'b1;
  end

  // LRU
  always_ff@(posedge clk or posedge rst)begin
    if(rst) LRU <= 1'd0;
    else if (next_state == TAG_CHECK) LRU <= LRU_map[index];
  end

  always_ff@(posedge clk or posedge rst)begin
    if(rst) index_r <= 1'd0;
    else  index_r <= index;
  end

  always_ff @(posedge clk or posedge rst) begin
    if(rst) fucking_SRAM <= 32'd0;
    else if(handshake_m0_R & (counter == 2'd3)) fucking_SRAM <= DA_in[96+:32];
  end

  always_ff @(posedge clk or posedge rst) begin
    if(rst) fucking_SRAM_flag <= 1'b0;
    else if(handshake_m0_R & (counter == 2'd3)) fucking_SRAM_flag <= 1'b1;
    else if(current_state == IDLE) fucking_SRAM_flag <= 1'b0;
  end

  
// cache hit rate circuit
// not for synthesize just calculate cache hit
// synopsys translate_off
// performance counter
  logic [31:0] read_req_count;
  logic [31:0] write_req_count;
  logic [31:0] read_miss_count;
  logic [31:0] write_miss_count;

  always_ff@(posedge clk)begin
    if(rst) read_req_count <= 32'b0;
    else if((current_state == IDLE) & core_req & ~cpu_write_req) read_req_count <= read_req_count + 1'b1;
  end
  always_ff@(posedge clk)begin
    if(rst) write_req_count <= 32'b0;
    else if((current_state == IDLE) & core_req & cpu_write_req) write_req_count <= write_req_count + 1'b1;
  end
  always_ff@(posedge clk)begin
    if(rst) read_miss_count <= 32'b0;
    else if((current_state == MEM_ALLOCATE) & handshake_m0_R & (counter == 2'd3)) read_miss_count <= read_miss_count + 1'b1;
  end
  always_ff@(posedge clk)begin
    if(rst) write_miss_count <= 32'b0;
    else if((current_state == TAG_CHECK) & cpu_write_req & ~hit) write_miss_count <= write_miss_count + 1'b1;
  end

// synopsys translate_on

endmodule

