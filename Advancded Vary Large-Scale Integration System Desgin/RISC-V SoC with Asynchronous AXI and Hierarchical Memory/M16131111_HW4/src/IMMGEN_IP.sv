
module IMMGEN_IP(
    input [31:0] i_imm_instruction,
    input [2:0] i_imm_sel,
    output logic [31:0] o_imm_data,
    output logic [1:0] o_csr_sel // csr output sel
);


    always_comb begin
        if(i_imm_instruction[6:0] == `CSR) begin
            case(i_imm_instruction[31:20])
            12'b1100_1000_0010: begin
                o_csr_sel = 2'b00;
            end
            12'b1100_0000_0010: begin
                o_csr_sel = 2'b01;
            end
            12'b1100_1000_0000: begin
                o_csr_sel = 2'b10;
            end   
            12'b1100_0000_0000: begin
                o_csr_sel = 2'b11;
            end   
            default: begin
                o_csr_sel = 2'd0;
            end    
            endcase
        end 
        else begin
            o_csr_sel = 2'd0;
        end
    end

    always_comb begin
        case(i_imm_sel)
        `I_type: begin
            o_imm_data = {{21{i_imm_instruction[31]}}, i_imm_instruction[30:25], i_imm_instruction[24:21], i_imm_instruction[20]};
        end
        `S_type: begin
            o_imm_data = {{21{i_imm_instruction[31]}}, i_imm_instruction[30:25], i_imm_instruction[11: 8], i_imm_instruction[ 7]};
        end
        `B_type: begin
            o_imm_data = {{20{i_imm_instruction[31]}}, i_imm_instruction[ 7], i_imm_instruction[30:25], i_imm_instruction[11: 8], 1'b0};
        end
        `U_type: begin
            o_imm_data = {i_imm_instruction[31], i_imm_instruction[30:20], i_imm_instruction[19:12], 12'b0};
        end
        `J_type: begin
            o_imm_data = {{12{i_imm_instruction[31]}}, i_imm_instruction[19:12], i_imm_instruction[20], i_imm_instruction[30:25], i_imm_instruction[24:21], 1'b0};
        end
        `F_L_type: begin
            o_imm_data = {{21{i_imm_instruction[31]}}, i_imm_instruction[30:25], i_imm_instruction[24:21], i_imm_instruction[20]};
        end
        `F_S_type: begin
            o_imm_data = {{21{i_imm_instruction[31]}}, i_imm_instruction[30:25], i_imm_instruction[11: 8], i_imm_instruction[ 7]};
        end
        default: begin
            o_imm_data = 32'd0;
        end
        endcase
    end
    
endmodule:IMMGEN_IP;