`include "comparator.v"
`define statebits 3
`define mul_statebits 2
`define DIV_statebits 2
module alu(
    input clk,
    input rst,
    input [2:0] operation,

    input signed [15:0] srcA_i,
    input signed [15:0] srcB_i,
    input [15:0] sortNum0_i,
    input [15:0] sortNum1_i,
    input [15:0] sortNum2_i,
    input [15:0] sortNum3_i,
    input [15:0] sortNum4_i,
    input [15:0] sortNum5_i,
    input [15:0] sortNum6_i,
    input [15:0] sortNum7_i,
    input [15:0] sortNum8_i,

    output reg signed  [15:0] data_o,
    output [15:0] sortNum0_o,
    output [15:0] sortNum1_o,
    output [15:0] sortNum2_o,
    output [15:0] sortNum3_o,
    output [15:0] sortNum4_o,
    output [15:0] sortNum5_o,
    output [15:0] sortNum6_o,
    output [15:0] sortNum7_o,
    output [15:0] sortNum8_o,
    output            done
);


localparam DATA_WIDTH = 16;
localparam IDLE = `statebits'd0;
localparam MUL = `statebits'd1;
localparam DIV = `statebits'd2;
localparam OUT = `statebits'd3;
localparam SORT = `statebits'd4;
reg [`statebits - 1:0] current_state;
reg [`statebits - 1:0] next_state;

localparam MUL_IDLE = `statebits'd0;
localparam MUL_ADD = `statebits'd1;
localparam MUL_SHIFT = `statebits'd2;
localparam MUL_ROUND = `statebits'd3;
reg [`mul_statebits - 1:0] mul_current_state;
reg [`mul_statebits - 1:0] mul_next_state;
reg [3:0] mul_counter;


localparam DIV_IDLE = `DIV_statebits'd0;
localparam DIV_SUB = `DIV_statebits'd1;
localparam DIV_TEST = `DIV_statebits'd2;
localparam DIV_DONE = `DIV_statebits'd3;

reg [`DIV_statebits - 1:0] div_current_state;
reg [`DIV_statebits - 1:0] div_next_state;
reg [4:0] div_counter;


reg signed [15:0] src_a;
reg signed [15:0] src_b;
reg signed [31:0] product_multiplier_remainder;//  share with div div use [31:0]
wire signed [31:0] product_multiplier_remainder_neg;
wire signed [15:0] add_result;
wire signed [15:0] sub_result;
wire signed [15:0] add_result_final;
wire signed [15:0] sub_result_final;
reg signed [15:0] mul_result;
wire signed [15:0] mul_result_round;
wire signed [15:0] mul_result_final;
wire G;
wire R;
wire S;// for rounding
reg add_overflow;
reg add_underflow;
reg sub_overflow;
reg sub_underflow;
reg signed round;// 1 up / 0 down

assign product_multiplier_remainder_neg = ~product_multiplier_remainder + 32'd1;
//covert signed to unsigned
wire [15:0] unsigned_divisor_multiplicand;
wire [15:0] unsigned_dividend_multiplier;
reg signed [15:0] div_result;
wire q_product_sign_bit;
//done 
assign done = (current_state==OUT);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end


always @(*) begin
    case (current_state)
        IDLE:begin
            case (operation)
                3'b010:begin
                    next_state = MUL;
                end
                3'b011:begin
                    next_state = DIV;
                end
                3'b011:begin
                    next_state = DIV;
                end
                3'b100:begin
                    next_state = SORT;
                end
                default:begin
                    next_state = OUT;
                end
            endcase
        end
        MUL:begin
            next_state = (mul_current_state==MUL_ROUND)? OUT:MUL;
        end
        DIV:begin
            next_state = (div_current_state==DIV_DONE)? OUT:DIV;
        end
        SORT:begin
            next_state = OUT;
        end
        OUT:begin
            next_state = IDLE;
        end
        default:begin
            ;
        end 
    endcase
end

always @(*) begin
    case (operation)
        3'b000:begin
            data_o = add_result_final;
        end 
        3'b001:begin
            data_o = sub_result_final;
        end
        3'b010:begin
            data_o = mul_result_final;
        end
        default:begin
            data_o = div_result;
        end
    endcase
end
//DIV circuit 
always @(posedge clk or posedge rst) begin
    if(rst) begin
        div_current_state <= DIV_IDLE;
    end
    else begin
        div_current_state <= div_next_state;
    end
end

always @(*) begin
    case (div_current_state)
        DIV_IDLE:begin
            div_next_state = (current_state==DIV)? DIV_SUB:DIV_IDLE;
        end
        DIV_SUB:begin
            div_next_state = DIV_TEST;
        end
        DIV_TEST:begin
            div_next_state = (div_counter==5'd25)? DIV_DONE:DIV_SUB;
        end
        DIV_DONE:begin
            div_next_state =DIV_IDLE;
        end
        default:begin
            ;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        div_counter <= 5'd0;
    end
    else if(current_state==DIV)begin
        div_counter <= (div_counter==5'd25)? div_counter:(div_current_state==DIV_TEST)? (div_counter+4'd1):div_counter;
    end
    else begin
        div_counter <= 5'd0;
    end
end



assign unsigned_dividend_multiplier = srcA_i[15]? (~srcA_i + 16'd1):srcA_i;
assign unsigned_divisor_multiplicand  = srcB_i[15]? (~srcB_i + 16'd1):srcB_i;
assign q_product_sign_bit = srcA_i[15] ^ srcB_i[15];


always @(*) begin
    if(q_product_sign_bit) begin
        div_result = (~product_multiplier_remainder[15:0] + 16'd1) ;
    end 
    else begin
        div_result = product_multiplier_remainder[15:0] ;
    end
end

//MUL circuit (share ADD/SUB with ALU)
always @(posedge clk or posedge rst) begin
    if(rst) begin
        mul_current_state <= MUL_IDLE;
    end
    else begin
        mul_current_state <= mul_next_state;
    end
end

always @(*) begin
    case (mul_current_state)
        MUL_IDLE:begin
            mul_next_state = (current_state==MUL)? MUL_ADD:MUL_IDLE;
        end
        MUL_ADD:begin
            mul_next_state = MUL_SHIFT;
        end
        MUL_SHIFT:begin
            mul_next_state = (mul_counter==4'd15)? MUL_ROUND:MUL_ADD;
        end
        MUL_ROUND:begin
            mul_next_state = MUL_IDLE;
        end
        default:begin
            ;
        end
    endcase
end


assign add_result = src_a + src_b;
assign sub_result = src_a - src_b;
assign mul_result_round = mul_result + {15'd0,round};

assign mul_result_final = (product_multiplier_remainder[31]==0&&(|product_multiplier_remainder[30:26]))? 16'b0111_1111_1111_1111:(product_multiplier_remainder[31]==1&&(&product_multiplier_remainder[30:26])==0)? 16'b1000_0000_0000_0000:mul_result_round;

assign add_result_final = (add_overflow)? 16'b0111_1111_1111_1111:(add_underflow)? 16'b1000_0000_0000_0000:add_result;
assign sub_result_final = (sub_overflow)? 16'b0111_1111_1111_1111:(sub_underflow)? 16'b1000_0000_0000_0000:sub_result;

assign G = product_multiplier_remainder[9];
assign R = product_multiplier_remainder[8];
assign S = |product_multiplier_remainder[7];

always @(*) begin
    if(src_a[15]==0&&src_b[15]==0&&add_result[15]==1)begin
        add_overflow = 1'b1;
    end
    else begin
        add_overflow = 1'b0;
    end
end

always @(*) begin
    if(src_a[15]==1&&src_b[15]==1&&add_result[15]==0)begin
        add_underflow = 1'b1;
    end
    else begin
        add_underflow = 1'b0;
    end
end

always @(*) begin
    if(src_a[15]==0&&src_b[15]==1&&sub_result[15]==1)begin
        sub_overflow = 1'b1;
    end
    else begin
        sub_overflow = 1'b0;
    end
end

always @(*) begin
    if(src_a[15]==1&&src_b[15]==0&&sub_result[15]==0)begin
        sub_underflow = 1'b1;
    end
    else begin
        sub_underflow = 1'b0;
    end
end

always @(*) begin
    if(operation==3'b010) begin
        src_a = product_multiplier_remainder[31:16];
        src_b = srcB_i;
    end
    else if(operation==3'b011) begin
        src_a = product_multiplier_remainder[31:16];
        src_b = unsigned_divisor_multiplicand;
    end
    else begin
        src_a = srcA_i;
        src_b = srcB_i;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mul_counter <= 4'd0;
    end
    else if (current_state==MUL)begin
        mul_counter <= (mul_counter==4'd15)? mul_counter:(mul_current_state==MUL_SHIFT)? (mul_counter+4'd1):mul_counter;
    end
    else begin
        mul_counter <= 4'd0;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        product_multiplier_remainder <= 32'd0;
    end
    else if(current_state==IDLE)begin
        product_multiplier_remainder <= 32'd0;
    end
    else if(current_state==MUL)begin
        if(mul_current_state==MUL_IDLE) begin
            product_multiplier_remainder <= {16'd0,unsigned_dividend_multiplier};
        end
        else if(mul_current_state==MUL_SHIFT) begin
            product_multiplier_remainder <= product_multiplier_remainder >>> 1;
        end
        else if(mul_current_state==MUL_ADD) begin
            if(product_multiplier_remainder[0]==1'b1) begin
                product_multiplier_remainder[31:16] <= add_result;
            end
        end
    end
    else if(current_state==DIV)begin
        if(div_current_state==DIV_IDLE) begin
            product_multiplier_remainder <= {15'd0,unsigned_dividend_multiplier,1'd0};
        end
        else if(div_current_state==DIV_SUB) begin
            product_multiplier_remainder[31:16] <= sub_result;
        end
        else if(div_current_state==DIV_TEST) begin
            if(product_multiplier_remainder[31]) begin
                product_multiplier_remainder <= {add_result[14:0],product_multiplier_remainder[15:0],1'b0};
            end
            else begin
                product_multiplier_remainder <= {product_multiplier_remainder[30:0],1'b1};
            end
        end
    end
end

always @(*) begin
    case ({G,R})
        2'b11:begin
            round = 1'b1;
        end
        2'b10:begin
            if(S==1)begin
                round = 1'b1;
            end
            else begin
                if(product_multiplier_remainder[10]==1'b1) begin
                    round = 1'b1;
                end
                else begin
                    round = 1'b0;
                end
            end
        end
        default:begin
            round = 1'b0;
        end
    endcase
end

always @(*) begin
    mul_result = (q_product_sign_bit)? (product_multiplier_remainder_neg[25:10]):product_multiplier_remainder[25:10];
end

// sort circuit 
// Stage 0: 輸入連線
  wire [DATA_WIDTH-1:0] stage0[0:8];
  assign stage0[0] = sortNum0_i;
  assign stage0[1] = sortNum1_i;
  assign stage0[2] = sortNum2_i;
  assign stage0[3] = sortNum3_i;
  assign stage0[4] = sortNum4_i;
  assign stage0[5] = sortNum5_i;
  assign stage0[6] = sortNum6_i;
  assign stage0[7] = sortNum7_i;
  assign stage0[8] = sortNum8_i;

  // Stage 1 (Layer 1): Comparators [(0,3), (1,7), (2,5), (4,8)]
  wire [DATA_WIDTH-1:0] stage1[0:8];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp0_3 (
       .a(stage0[0]), .b(stage0[3]),
       .min(stage1[0]), .max(stage1[3])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp1_7 (
       .a(stage0[1]), .b(stage0[7]),
       .min(stage1[1]), .max(stage1[7])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp2_5 (
       .a(stage0[2]), .b(stage0[5]),
       .min(stage1[2]), .max(stage1[5])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp4_8 (
       .a(stage0[4]), .b(stage0[8]),
       .min(stage1[4]), .max(stage1[8])
  );
  // 未參與比較的號位直接傳遞
  assign stage1[6] = stage0[6];

  // Stage 2 (Layer 2): Comparators [(0,7), (2,4), (3,8), (5,6)]
  wire [DATA_WIDTH-1:0] stage2[0:8];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp0_7 (
       .a(stage1[0]), .b(stage1[7]),
       .min(stage2[0]), .max(stage2[7])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp2_4 (
       .a(stage1[2]), .b(stage1[4]),
       .min(stage2[2]), .max(stage2[4])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp3_8 (
       .a(stage1[3]), .b(stage1[8]),
       .min(stage2[3]), .max(stage2[8])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp5_6 (
       .a(stage1[5]), .b(stage1[6]),
       .min(stage2[5]), .max(stage2[6])
  );
  // 其他號位傳遞
  assign stage2[1] = stage1[1];

  // Stage 3 (Layer 3): Comparators [(0,2), (1,3), (4,5), (7,8)]
  wire [DATA_WIDTH-1:0] stage3[0:8];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp0_2 (
       .a(stage2[0]), .b(stage2[2]),
       .min(stage3[0]), .max(stage3[2])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp1_3 (
       .a(stage2[1]), .b(stage2[3]),
       .min(stage3[1]), .max(stage3[3])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp4_5 (
       .a(stage2[4]), .b(stage2[5]),
       .min(stage3[4]), .max(stage3[5])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp7_8 (
       .a(stage2[7]), .b(stage2[8]),
       .min(stage3[7]), .max(stage3[8])
  );
  assign stage3[6] = stage2[6];

  // Stage 4 (Layer 4): Comparators [(1,4), (3,6), (5,7)]
  wire [DATA_WIDTH-1:0] stage4[0:8];
  assign stage4[0] = stage3[0];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp1_4 (
       .a(stage3[1]), .b(stage3[4]),
       .min(stage4[1]), .max(stage4[4])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp3_6 (
       .a(stage3[3]), .b(stage3[6]),
       .min(stage4[3]), .max(stage4[6])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp5_7 (
       .a(stage3[5]), .b(stage3[7]),
       .min(stage4[5]), .max(stage4[7])
  );
  assign stage4[2] = stage3[2];
  assign stage4[8] = stage3[8];

  // ---------------------------
  // Pipeline Register Stage
  // ---------------------------
  reg [DATA_WIDTH-1:0] stage4_reg[0:8];
  integer i;
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i = 0; i < 9; i = i + 1)
         stage4_reg[i] <= {DATA_WIDTH{1'b0}};
    end else begin
      for(i = 0; i < 9; i = i + 1)
         stage4_reg[i] <= stage4[i];
    end
  end

  // Stage 5 (Layer 5): Comparators [(0,1), (2,4), (3,5), (6,8)]
  wire [DATA_WIDTH-1:0] stage5[0:8];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp0_1 (
       .a(stage4_reg[0]), .b(stage4_reg[1]),
       .min(stage5[0]), .max(stage5[1])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp2_4_2 (
       .a(stage4_reg[2]), .b(stage4_reg[4]),
       .min(stage5[2]), .max(stage5[4])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp3_5 (
       .a(stage4_reg[3]), .b(stage4_reg[5]),
       .min(stage5[3]), .max(stage5[5])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp6_8 (
       .a(stage4_reg[6]), .b(stage4_reg[8]),
       .min(stage5[6]), .max(stage5[8])
  );
  assign stage5[7] = stage4_reg[7];

  // Stage 6 (Layer 6): Comparators [(2,3), (4,5), (6,7)]
  wire [DATA_WIDTH-1:0] stage6[0:8];
  assign stage6[0] = stage5[0];
  assign stage6[1] = stage5[1];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp2_3 (
       .a(stage5[2]), .b(stage5[3]),
       .min(stage6[2]), .max(stage6[3])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp4_5_2 (
       .a(stage5[4]), .b(stage5[5]),
       .min(stage6[4]), .max(stage6[5])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp6_7 (
       .a(stage5[6]), .b(stage5[7]),
       .min(stage6[6]), .max(stage6[7])
  );
  assign stage6[8] = stage5[8];

  // Stage 7 (Layer 7): Comparators [(1,2), (3,4), (5,6)]
  wire [DATA_WIDTH-1:0] stage7[0:8];
  assign stage7[0] = stage6[0];
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp1_2 (
       .a(stage6[1]), .b(stage6[2]),
       .min(stage7[1]), .max(stage7[2])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp3_4 (
       .a(stage6[3]), .b(stage6[4]),
       .min(stage7[3]), .max(stage7[4])
  );
  comparator #(.DATA_WIDTH(DATA_WIDTH)) comp5_6_2 (
       .a(stage6[5]), .b(stage6[6]),
       .min(stage7[5]), .max(stage7[6])
  );
  assign stage7[7] = stage6[7];
  assign stage7[8] = stage6[8];

  // 輸出：stage7 為最終排序結果
  assign sortNum0_o = stage7[0];
  assign sortNum1_o = stage7[1];
  assign sortNum2_o = stage7[2];
  assign sortNum3_o = stage7[3];
  assign sortNum4_o = stage7[4];
  assign sortNum5_o = stage7[5];
  assign sortNum6_o = stage7[6];
  assign sortNum7_o = stage7[7];
  assign sortNum8_o = stage7[8];
endmodule