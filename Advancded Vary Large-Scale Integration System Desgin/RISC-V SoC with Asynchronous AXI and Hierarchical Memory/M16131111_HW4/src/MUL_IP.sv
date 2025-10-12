
module MUL_IP (
    input pipe_freeze,
    input [31:0] i_x_mul,
    input [31:0] i_y_mul,
    input [1:0] mul_sel,
    input clk,
    input rst,
    output logic [31:0] o_mul
);
// mul_sel 0  MUL rd = lower 32 bits 
// mul_sel 1 MULH rd = upper 32 bits signed * signed
// mul_sel 2 MULHSU rd = upper 32 bits signed * unsigned
// mul_sel 3 MULHU rd = upper 32 bits unsigned * unsigned
logic [31:0] i_x_mul_Reg;
logic [31:0] i_y_mul_Reg;
logic [1:0] mul_sel_Reg;

logic [63:0] answer_Reg;
logic  i_x_mul_Reg_Reg_31;
logic  i_y_mul_Reg_Reg_31;
logic data_x_need_sign_to_unsign_Reg;
logic data_y_need_sign_to_unsign_Reg;
logic [1:0] mul_sel_Reg_Reg;


logic [63:0] answer;
logic [63:0] answer_complement;
logic [63:0] out;
logic data_x_need_sign_to_unsign;
logic data_y_need_sign_to_unsign;
logic [31:0] data_x_op;
logic [31:0] data_y_op;
logic [31:0] o_mul_temp;
logic [1:0] mul_sel_temp;


    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            i_x_mul_Reg <= 0;
            i_y_mul_Reg <= 0;
            mul_sel_Reg <= 0;
        end
        else if(~pipe_freeze) begin
            i_x_mul_Reg <= i_x_mul;
            i_y_mul_Reg <= i_y_mul;
            mul_sel_Reg <= mul_sel;
        end
    end


    assign data_x_need_sign_to_unsign = !(mul_sel_Reg[0] & mul_sel_Reg[1]);
    assign data_y_need_sign_to_unsign = !mul_sel_Reg[1];
    assign data_x_op = (i_x_mul_Reg[31] & data_x_need_sign_to_unsign) ? ((~i_x_mul_Reg) + 1'b1) : i_x_mul_Reg;
    assign data_y_op = (i_y_mul_Reg[31] & data_y_need_sign_to_unsign) ? ((~i_y_mul_Reg) + 1'b1) : i_y_mul_Reg;
    //assign answer = data_x_op * data_y_op;
    
    
    logic [31:0] mul_part [0:3];
    logic [31:0] mul_part_Reg [0:3];
    assign mul_part[0] = data_x_op[15:0] * data_y_op[15:0];
    assign mul_part[1] = data_x_op[31:16] * data_y_op[15:0];
    assign mul_part[2] = data_x_op[15:0] * data_y_op[31:16];
    assign mul_part[3] = data_x_op[31:16] * data_y_op[31:16];
     
    always_ff @(posedge clk or posedge rst)begin
        if(rst) begin
            mul_part_Reg [0] <= 0;
            mul_part_Reg [1] <= 0;
            mul_part_Reg [2] <= 0;
            mul_part_Reg [3] <= 0;
            i_y_mul_Reg_Reg_31 <= 0;
            i_x_mul_Reg_Reg_31 <= 0;
            data_x_need_sign_to_unsign_Reg <= 0;
            data_y_need_sign_to_unsign_Reg <= 0;
            mul_sel_Reg_Reg <= 0;
        end
        else if (~pipe_freeze) begin
            mul_part_Reg [0] <= mul_part [0];
            mul_part_Reg [1] <= mul_part [1];
            mul_part_Reg [2] <= mul_part [2];
            mul_part_Reg [3] <= mul_part [3];
            i_y_mul_Reg_Reg_31 <= i_y_mul_Reg[31];
            i_x_mul_Reg_Reg_31 <= i_x_mul_Reg[31];
            data_x_need_sign_to_unsign_Reg <= data_x_need_sign_to_unsign;
            data_y_need_sign_to_unsign_Reg <= data_y_need_sign_to_unsign;
            mul_sel_Reg_Reg <= mul_sel_Reg;
        end
    end
    
    assign answer = {32'b0,mul_part_Reg[0]} + {16'b0,mul_part_Reg[1],16'b0} + {16'b0,mul_part_Reg[2],16'b0} + {mul_part_Reg[3],32'b0};
    assign answer_complement = (~answer) + 1'b1;
    assign out = ((i_y_mul_Reg_Reg_31 & data_y_need_sign_to_unsign_Reg) ^ (i_x_mul_Reg_Reg_31 & data_x_need_sign_to_unsign_Reg))? answer_complement : answer;
    
    
    always_comb begin
        case(mul_sel_Reg_Reg)
            0:begin
                o_mul = out[31:0];
            end
            1:begin
                o_mul = out[63:32];
            end
            2:begin
                o_mul = out[63:32];
            end
            3:begin
                o_mul = out[63:32];
            end  
            default:begin
                o_mul = 32'd0;
            end 
        endcase
    end
    
    
endmodule:MUL_IP;
