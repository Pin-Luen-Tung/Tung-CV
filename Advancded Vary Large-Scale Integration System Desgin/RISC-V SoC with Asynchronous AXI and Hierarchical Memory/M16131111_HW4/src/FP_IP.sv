
module FP_IP(
    input pipe_freeze,
    input [31:0] i_x_fp,
    input [31:0] i_y_fp,
    input i_fp_sub,
    input clk,
    input rst,

    output logic [31:0] o_fp
);
logic [31:0] i_x_fp_fucking_SRAM;
logic [31:0] i_y_fp_fucking_SRAM;
logic i_fp_sub_fucking_SRAM;


//logic [31:0] o_fp_temp;
//logic [31:0] o_fp_temp_temp;
//parameter  MAX_EXP_DIF = 253;//fraction shift 24 = 0

logic x_signed;
logic y_signed;

logic [7:0] x_exp;
logic [7:0] y_exp;

logic [22:0] x_frac;
logic [22:0] y_frac;

logic exp_comp;

logic [7:0] exp_dif;
logic [7:0] large_exp;
logic [7:0] large_exp_Reg;

logic [23:0] x_inte_frac;
logic [23:0] y_inte_frac;

logic signed [26:0] x_exten;
logic signed [26:0] y_exten;

logic signed [26:0] x_exten_use;
logic signed [26:0] y_exten_use;

logic signed [27:0] x_op;
logic signed [27:0] y_op;

logic signed [28:0] op_result;

logic [28:0] op_result_unsigned;


logic [28:0] op_result_unsigned_shift;
logic sticky;


logic exp_big;
logic [24:0] op_round;

logic [22:0] op_frac;
logic [7:0] op_exp;

//LZC new 
logic lzc1_zero;
logic lzc2_zero;
logic lzc3_zero;
logic lzc4_zero;
logic lzc5_zero;
logic lzc6_zero;
logic lzc7_zero;
logic lzc_last_zero;
logic [4:0] shift_bit;

logic [1:0] lzc1;
logic [1:0] lzc2;
logic [1:0] lzc3;
logic [1:0] lzc4;
logic [1:0] lzc5;
logic [1:0] lzc6;
logic [1:0] lzc7;

logic lzc_up_zero;
logic [1:0] lzc_up_bit;
logic [1:0] lzc_low_bit;

logic [7:0] exp_dif_1;
logic [7:0] exp_dif_2;

logic signed [26:0] x_exten_shift;
logic signed [26:0] y_exten_shift;

logic signed [27:0] x_op_c;
logic signed [27:0] y_op_c;
logic signed [27:0] x_op_nc;
logic signed [27:0] y_op_nc;
logic [28:0] op_result_unsigned_1;
logic [28:0] op_result_unsigned_2;
logic [24:0] op_round_1;
logic [24:0] op_round_2;
logic [4:0] shift_bit1;
logic [4:0] shift_bit2;
logic [4:0] shift_bit3;
logic [4:0] shift_bit4;
logic [4:0] shift_bit5;
logic [5:0] shift_bit6;
logic [5:0] shift_bit7;
logic [5:0] shift_bit8;
logic [22:0] op_frac1;
logic [7:0] op_exp1;
logic [22:0] op_frac2;
logic [7:0] op_exp2;

logic [28:0] op_result_1;
logic [28:0] op_result_unsigned_1_1;
logic [28:0] op_result_unsigned_2_1;
logic [28:0] op_result_unsigned1;
logic [28:0] op_result_unsigned_shift_1;
/*
logic [28:0] op_result_Reg;
logic [28:0] op_result_1_Reg;
*/

logic [31:0] i_x_fp_fucking_SRAM_Reg;
logic [31:0] i_y_fp_fucking_SRAM_Reg;
logic [26:0] x_exten_use_Reg;
logic [26:0] y_exten_use_Reg;
logic x_signed_Reg;
logic y_signed_Reg;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk or posedge rst) begin
    if(rst)begin
        i_x_fp_fucking_SRAM <= 32'd0;
        i_y_fp_fucking_SRAM <= 32'd0;
        i_fp_sub_fucking_SRAM <= 32'd0;
    end
    else if(~pipe_freeze) begin
        i_x_fp_fucking_SRAM <= i_x_fp;
        i_y_fp_fucking_SRAM <= i_y_fp;
        i_fp_sub_fucking_SRAM <= i_fp_sub;
    end
end






assign x_signed = i_x_fp_fucking_SRAM[31];
assign y_signed = (i_fp_sub_fucking_SRAM)? (~i_y_fp_fucking_SRAM[31]):(i_y_fp_fucking_SRAM[31]);
assign x_exp = i_x_fp_fucking_SRAM[30:23];
assign y_exp = i_y_fp_fucking_SRAM[30:23];
assign x_frac = i_x_fp_fucking_SRAM[22:0];
assign y_frac = i_y_fp_fucking_SRAM[22:0];
assign x_inte_frac = {1'b1,x_frac};
assign y_inte_frac = {1'b1,y_frac};

assign exp_comp = x_exp > y_exp;
assign exp_big = (exp_dif>27)? 1:0;

assign exp_dif_1 = x_exp - y_exp;
assign exp_dif_2 = y_exp - x_exp;
always_comb begin
    if(exp_comp) begin //x_exp > y_exp
        exp_dif  = exp_dif_1;
        large_exp = x_exp;
    end
    else begin
        exp_dif  = exp_dif_2;
        large_exp = y_exp;
    end
end

always_comb begin
    x_exten = {x_inte_frac , {3{1'b0}}};
    y_exten = {y_inte_frac , {3{1'b0}}};
end





assign x_exten_shift = x_exten >> exp_dif;
assign y_exten_shift = y_exten >> exp_dif;

always_comb begin
    if(!exp_comp) begin
        x_exten_use = x_exten_shift;
    end
    else begin
        x_exten_use = x_exten;
    end
end

always_comb begin
    if(exp_comp) begin
        y_exten_use = y_exten_shift;
    end
    else begin
        y_exten_use = y_exten;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        x_exten_use_Reg <= 0;
        y_exten_use_Reg <= 0;
        large_exp_Reg <= 0;
        i_x_fp_fucking_SRAM_Reg <= 0;
        i_y_fp_fucking_SRAM_Reg <= 0;
        x_signed_Reg <= 0;
        y_signed_Reg <= 0;
    end
    else if(~pipe_freeze) begin
        x_exten_use_Reg <= x_exten_use;
        y_exten_use_Reg <= y_exten_use;
        large_exp_Reg <= large_exp;
        i_x_fp_fucking_SRAM_Reg <= i_x_fp_fucking_SRAM;
        i_y_fp_fucking_SRAM_Reg <= i_y_fp_fucking_SRAM;
        x_signed_Reg <= x_signed;
        y_signed_Reg <= y_signed;
    end
end

assign x_op_c = ~{1'b0 ,x_exten_use_Reg} + 1'b1;
assign x_op_nc = {1'b0 ,x_exten_use_Reg};
assign y_op_c = ~{1'b0 ,y_exten_use_Reg} + 1'b1;
assign y_op_nc = {1'b0 ,y_exten_use_Reg};

always_comb begin
    if(!(|i_x_fp_fucking_SRAM_Reg[30:23])) begin //exponent = 0, value = 0 (case neglect underflow/overflow)
        x_op = 0;
    end
    else if(x_signed_Reg) begin
        x_op = x_op_c;
    end
    else begin
        x_op = x_op_nc;
    end
end

always_comb begin
    if(!(|i_y_fp_fucking_SRAM_Reg[30:23])) begin //exponent = 0, value = 0 (case neglect underflow/overflow)
        y_op = 0;
    end
    else if(y_signed_Reg) begin
        y_op = y_op_c;
    end
    else begin
        y_op = y_op_nc;
    end
end

assign op_result = x_op + y_op;
assign op_result_1 = x_op + y_op + 1;
/*
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        op_result_Reg <= 0;
        op_result_1_Reg <= 0;
        large_exp_Reg <= 0;
    end
    else begin
        op_result_Reg <= op_result;
        op_result_1_Reg <= op_result_1;
        large_exp_Reg <= large_exp;
    end
end
*/
assign op_result_unsigned_1 = ~op_result + 1'b1;
assign op_result_unsigned_2 = op_result;

assign op_result_unsigned_1_1 = ~op_result_1 + 1'b1;
assign op_result_unsigned_2_1 = op_result_1;

always_comb begin
    if(op_result[28]) begin
        op_result_unsigned = op_result_unsigned_1;
    end
    else begin
        op_result_unsigned = op_result_unsigned_2;
    end
end

always_comb begin
    if(op_result_1[28]) begin
        op_result_unsigned1 = op_result_unsigned_1_1;
    end
    else begin
        op_result_unsigned1 = op_result_unsigned_2_1;
    end
end



assign op_result_unsigned_shift = op_result_unsigned << shift_bit;
assign op_result_unsigned_shift_1 = op_result_unsigned1 << shift_bit;
assign sticky = op_result_unsigned_shift[2] ;

assign op_round_1 = {1'b0,op_result_unsigned_shift[28:5]};
assign op_round_2 = {1'b0,op_result_unsigned_shift_1[28:5]};

always_comb begin
    if(!op_result_unsigned_shift[4]) begin//G=0
        op_round = op_round_1;
    end
    else if(op_result_unsigned[4] && op_result_unsigned_shift[3]) begin// G=1,R=1
        op_round = op_round_2;
    end
    else if(op_result_unsigned_shift[3] && sticky) begin//G=1 R=0 S=1
        op_round = op_round_2;
    end
    else begin //G=1 R=0 S=0
        if(op_result_unsigned_shift[5] == 1) begin //G=1 R=0 S=0 LSB=1
            op_round = op_round_2;
        end
        else begin//G=1 R=0 S=0 LSB=0
            op_round = op_round_1;
        end
    end
end

assign op_exp1 = large_exp_Reg - shift_bit + 2;
assign op_exp2 = large_exp_Reg - shift_bit + 3;
assign op_frac1 = op_round[22:0];
assign op_frac2 = op_round[23:1];

always_comb begin
    if(!op_round[24]) begin
        op_exp = op_exp1;
        op_frac = op_frac1;
    end
    else begin
        op_exp = op_exp2;
        op_frac = op_frac2;
    end
end

assign o_fp = {op_result[28],op_exp,op_frac};

/*
always_ff @(posedge clk or posedge rst)begin
    if(rst)begin
        o_fp <= 32'd0;
    end
    else begin
        o_fp <= {op_result[28],op_exp,op_frac};
    end
end
*/
// lzc circuit

assign lzc1_zero = ~(|op_result_unsigned[3:0]);
assign lzc2_zero = ~(|op_result_unsigned[7:4]);
assign lzc3_zero = ~(|op_result_unsigned[11:8]);
assign lzc4_zero = ~(|op_result_unsigned[15:12]);
assign lzc5_zero = ~(|op_result_unsigned[19:16]);
assign lzc6_zero = ~(|op_result_unsigned[23:20]);
assign lzc7_zero = ~(|op_result_unsigned[27:24]);

assign lzc_up_zero = lzc_last_zero & lzc7_zero & lzc6_zero & lzc5_zero;

assign lzc_last_zero = (op_result_unsigned[28])? 0:1; 

assign lzc1[0] = ((~op_result_unsigned[3])&op_result_unsigned[2]) | ((~op_result_unsigned[3])&(~op_result_unsigned[1]));
assign lzc1[1] = ~(op_result_unsigned[3] | op_result_unsigned[2]);

assign lzc2[0] = ((~op_result_unsigned[7])&op_result_unsigned[6]) | ((~op_result_unsigned[7])&(~op_result_unsigned[5]));
assign lzc2[1] = ~(op_result_unsigned[7] | op_result_unsigned[6]);


assign lzc3[0] = ((~op_result_unsigned[11]) & op_result_unsigned[10]) | ((~op_result_unsigned[11]) & (~op_result_unsigned[9]));
assign lzc3[1] = ~(op_result_unsigned[11] | op_result_unsigned[10]);

assign lzc4[0] = ((~op_result_unsigned[15]) & op_result_unsigned[14]) | ((~op_result_unsigned[15]) & (~op_result_unsigned[13]));
assign lzc4[1] = ~(op_result_unsigned[15] | op_result_unsigned[14]);

assign lzc5[0] = ((~op_result_unsigned[19]) & op_result_unsigned[18]) | ((~op_result_unsigned[19]) & (~op_result_unsigned[17]));
assign lzc5[1] = ~(op_result_unsigned[19] | op_result_unsigned[18]);

assign lzc6[0] = ((~op_result_unsigned[23]) & op_result_unsigned[22]) | ((~op_result_unsigned[23]) & (~op_result_unsigned[21]));
assign lzc6[1] = ~(op_result_unsigned[23] | op_result_unsigned[22]);

assign lzc7[0] = ((~op_result_unsigned[27]) & op_result_unsigned[26]) | ((~op_result_unsigned[27]) & (~op_result_unsigned[25]));
assign lzc7[1] = ~(op_result_unsigned[27] | op_result_unsigned[26]);

assign lzc_up_bit[0] = lzc_last_zero&((~lzc7_zero)|(lzc6_zero&(~(lzc5_zero))));
assign lzc_up_bit[1] = lzc_last_zero&lzc7_zero&((~lzc6_zero) | (~lzc5_zero));

assign lzc_low_bit[0] = lzc4_zero&((~lzc3_zero)|(lzc2_zero&(~(lzc1_zero))));
assign lzc_low_bit[1] = lzc4_zero&lzc3_zero&((~lzc2_zero) | (~lzc1_zero));

assign shift_bit1 = 4'd0;
assign shift_bit2 = {2'b0,lzc7} + 4'd1;;
assign shift_bit3 = {2'b0,lzc6} + 4'd5;;
assign shift_bit4 = {2'b0,lzc5} + 4'd9;
assign shift_bit5 = {2'b0,lzc4} + 4'd13;
assign shift_bit6 = {3'b0,lzc3} + 5'd17;
assign shift_bit7 = {3'b0,lzc2} + 5'd21;
assign shift_bit8 = {3'b0,lzc1} + 5'd25;

always_comb begin
    if(!lzc_up_zero)begin
        case(lzc_up_bit)
        0:begin
            shift_bit = shift_bit1;
        end
        1:begin
            shift_bit = shift_bit2;
        end
        2:begin
            shift_bit = shift_bit3;
        end
        3:begin
            shift_bit = shift_bit4;
        end
        default:begin
            shift_bit = 0;
        end
        endcase
    end
    else begin
        case(lzc_low_bit)
        0:begin
            shift_bit = shift_bit5;
        end
        1:begin
            shift_bit = shift_bit6;
        end
        2:begin
            shift_bit = shift_bit7;
        end
        3:begin
            shift_bit = shift_bit8;
        end
        default:begin
            shift_bit = 0;
        end
        endcase
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            debug                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule : FP_IP;