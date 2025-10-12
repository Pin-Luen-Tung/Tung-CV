
//////////////////////////////////////////////////////////////////////////////////

//   opsel ={ funct7[5] , funct3[2:0] } = instruc[30] , instruc[14:12] }

/////////////////////////////////////////////////////////////////////////////////
module ALU_IP (
    input [31:0] i_x_alu,
    input [31:0] i_y_alu,
    input [3:0]  i_alu_sel,

    output logic [31:0] o_alu
);

logic [31:0] add_out;

assign add_out = (i_alu_sel[3]) ? (i_x_alu + ((~i_y_alu)+1)) : (i_x_alu + i_y_alu);

always_comb begin
    case (i_alu_sel)
        `ALU_ADD: begin
            o_alu = add_out;  // 加法操作
        end
        `ALU_SUB: begin
            o_alu = add_out;  // 減法操作
        end
        `ALU_SLL: begin
            o_alu = i_x_alu << i_y_alu[4:0];  // 邏輯左移操作
        end
        `ALU_SLT: begin
            o_alu = ($signed(i_x_alu) < $signed(i_y_alu)) ? 32'd1 : 32'd0;  // 有符號比較
        end
        `ALU_SLTU: begin
            o_alu = (i_x_alu < i_y_alu) ? 32'd1 : 32'd0;  // 無符號比較
        end
        `ALU_XOR: begin
            o_alu = i_x_alu ^ i_y_alu;  // XOR 操作
        end
        `ALU_SRL: begin
            o_alu = i_x_alu >> i_y_alu[4:0];  // 邏輯右移
        end
        `ALU_SRA: begin
            o_alu = $signed(i_x_alu) >>> i_y_alu[4:0];  // 算術右移
        end
        `ALU_OR: begin
            o_alu = i_x_alu | i_y_alu;  // OR 操作
        end
        `ALU_AND: begin
            o_alu = i_x_alu & i_y_alu;  // AND 操作
        end 
        default: begin
            o_alu = 32'd0;
        end
    endcase
end    


endmodule:ALU_IP;