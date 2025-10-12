
module CONTROLLER_IP (
    input [6:0] i_funct7,
    input [2:0] i_funct3,
    input [6:0] i_opcode,
    input [4:0] i_funct5,

    output logic [3:0] o_alu_sel,// alu control
    output logic [2:0] o_imm_sel,//imm gen control
    output logic [2:0] o_alu_use_sel_1,//alu use data sel 1
    output logic [1:0] o_alu_use_sel_2,//alu use data sel 2
    output logic o_fp_sub, // if = 1, fp sub
    output logic o_write,// data write reg
    output logic o_write_fp,// fp data write fp reg
    output logic [2:0] o_mem_to_wb_sel,//mem to wb output sel
    output logic o_WEB, // 1 = read , 0 = write (DATA SRAM control)
    output logic [1:0] o_BWEB_pre,//0 = that bit cab write
    output logic o_fp_store, //fp store to mem
    output logic o_jump, //jump instruc
    output logic o_branch //branch instruc
);

    always_comb begin
        case(i_opcode)
            `LOAD  :o_write = 1'b1;
            //`STORE 
            //`BRANCH
            `JALR  :o_write = 1'b1;
            `JAL   :o_write = 1'b1;
            `ARITHMETIC_IMM:o_write = 1'b1;
            `ARITHMETIC    :o_write = 1'b1;
            `AUIPC :o_write = 1'b1;
            `LUI   :o_write = 1'b1;
            `CSR   :o_write = 1'b1; 
            default:o_write = 1'b0;
        endcase
    end



// control DATA SRAM
    always_comb begin
        case(i_opcode)
        `LOAD: begin
            o_WEB = 1'b1;
        end
        `FP_LOAD: begin
            o_WEB = 1'b1;
        end
        `STORE: begin
            o_WEB = 1'b0;
        end
        `FP_STORE: begin
            o_WEB = 1'b0;
        end
        default:begin
            o_WEB = 1'b0;
        end
        endcase
    end
// if branch instruction
assign o_branch = (i_opcode == `BRANCH)? 1'b1:1'b0;
// if jump instrction
assign o_jump = (i_opcode == `JAL) || (i_opcode == `JALR);
// alu control
    always_comb begin
        case(i_opcode)
            `LOAD: begin
                o_alu_sel = `ALU_ADD;
            end
            `STORE: begin
                o_alu_sel = `ALU_ADD;
            end
            `BRANCH: begin
                o_alu_sel = `ALU_ADD;
            end
            `JALR: begin
                o_alu_sel = `ALU_ADD;
            end
            `JAL: begin
                o_alu_sel = `ALU_ADD;
            end
            `FP_LOAD: begin
                o_alu_sel = `ALU_ADD;
            end
            `FP_STORE: begin
                o_alu_sel = `ALU_ADD;
            end
            `ARITHMETIC:
            begin
                case({i_funct7[5], i_funct3})
                    `ALU_ADD: begin
                        o_alu_sel = `ALU_ADD;
                    end 
                    `ALU_SUB: begin
                        o_alu_sel = `ALU_SUB;
                    end
                    `ALU_SLL: begin
                        o_alu_sel = `ALU_SLL;
                    end
                    `ALU_SLT: begin
                        o_alu_sel = `ALU_SLT;
                    end
                    `ALU_SLTU: begin
                        o_alu_sel = `ALU_SLTU;
                    end
                    `ALU_XOR: begin
                        o_alu_sel = `ALU_XOR;
                    end
                    `ALU_SRL: begin
                        o_alu_sel = `ALU_SRL;
                    end
                    `ALU_SRA: begin
                        o_alu_sel = `ALU_SRA;
                    end
                    `ALU_OR: begin
                        o_alu_sel = `ALU_OR;
                    end
                    `ALU_AND: begin
                        o_alu_sel = `ALU_AND;
                    end
                    default: begin
                        o_alu_sel = 4'd0;
                    end
                endcase
            end
            `ARITHMETIC_IMM:
            begin
                case(i_funct3)
                    3'b000: begin
                        o_alu_sel = `ALU_ADD;
                    end 
                    3'b010: begin
                        o_alu_sel = `ALU_SLT;
                    end
                    3'b011: begin
                        o_alu_sel = `ALU_SLTU;
                    end
                    3'b100: begin
                        o_alu_sel = `ALU_XOR;
                    end
                    3'b110: begin
                        o_alu_sel = `ALU_OR;
                    end
                    3'b111: begin
                        o_alu_sel = `ALU_AND;
                    end
                    3'b001: begin
                        o_alu_sel = `ALU_SLL;
                    end
                    3'b101: begin
                        o_alu_sel = (i_funct7[5])? `ALU_SRA : `ALU_SRL ;
                    end
                    default  : o_alu_sel = 4'd0;
                endcase
            end
            `AUIPC: begin
                o_alu_sel = `ALU_ADD;
            end
            `LUI: begin
                o_alu_sel = `ALU_ADD;
            end
            default: begin
                o_alu_sel = 4'd0;
            end
        endcase
    end

// fp store
assign o_fp_store = (i_opcode == `FP_STORE)? 1'b1:1'b0;
// imm sel
    always_comb begin
        case(i_opcode)
            `LOAD: begin
                o_imm_sel = `I_type;
            end
            `STORE: begin
                o_imm_sel = `S_type;
            end
            `BRANCH: begin
                o_imm_sel = `B_type;
            end
            `JALR: begin
                o_imm_sel = `I_type;
            end
            `JAL: begin
                o_imm_sel = `J_type;
            end
            `ARITHMETIC_IMM: begin
                o_imm_sel = `I_type;
            end
            `AUIPC: begin
                o_imm_sel = `U_type;
            end
            `LUI: begin
                o_imm_sel = `U_type;
            end
            `FP_LOAD: begin
                o_imm_sel = `F_L_type;
            end
            `FP_STORE: begin
                o_imm_sel = `F_S_type;
            end
            default: begin
                o_imm_sel = 3'd0;
            end
        endcase
    end
// mem to wb data sel 
    always_comb begin
        case (i_opcode)
            `ARITHMETIC: begin
                o_mem_to_wb_sel = (i_funct7 == 7'b000_0001)? `MULOUT:`ALUOUT;
            end
            `ARITHMETIC_IMM: begin
                o_mem_to_wb_sel = `ALUOUT;
            end
            `LOAD: begin
                o_mem_to_wb_sel = `LOAD_DATA;
            end
            `AUIPC: begin
                o_mem_to_wb_sel = `ALUOUT;
            end
            `LUI: begin
                o_mem_to_wb_sel = `ALUOUT;
            end
            `JAL: begin 
                o_mem_to_wb_sel = `PC_PLUS_4;
            end
            `JALR: begin
                o_mem_to_wb_sel = `PC_PLUS_4;
            end
            `FP_LOAD: begin
                o_mem_to_wb_sel = `FP_LOAD_DATA;
            end
            `FP_ARITHMETIC: begin
                o_mem_to_wb_sel = `FPOUT;
            end
            `CSR: begin
                o_mem_to_wb_sel = `CSROUT;
            end
            default: begin
                o_mem_to_wb_sel = 3'd0;
            end
        endcase
    end
//data memory write back 2024 BWEB pre
    
assign o_BWEB_pre = ((i_opcode == `STORE) || (i_opcode == `FP_STORE))? (i_funct3[1])? 2'b11 : 
                    (i_funct3[0])? 2'b10 : 2'b01 : 2'b00;


// o_write_fp

    always_comb begin
        case (i_opcode)
            `FP_ARITHMETIC:begin
                o_write_fp = 1'b1;
            end
            `FP_LOAD: begin
                o_write_fp = 1'b1;
            end
            default : begin
                o_write_fp = 1'b0;
            end
        endcase
    end

// ALU data use sel 1
    // 0 from registerfile, 1 from pc, 2 from zero.

    always_comb begin
        case (i_opcode)
            `LOAD: begin
                o_alu_use_sel_1 = 2'd0;
            end 
            `FP_LOAD: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `STORE: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `FP_STORE: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `BRANCH: begin
                o_alu_use_sel_1 = 2'd1;
            end
            `JALR: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `JAL: begin
                o_alu_use_sel_1 = 2'd1;
            end
            `ARITHMETIC_IMM: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `ARITHMETIC: begin
                o_alu_use_sel_1 = 2'd0;
            end
            `AUIPC: begin
                o_alu_use_sel_1 = 2'd1;
            end
            `LUI: begin
                o_alu_use_sel_1 = 2'd2;
            end
            default: begin
                o_alu_use_sel_1 = 2'd0;
            end
        endcase
    end
 
// ALU data use sel 2

// 0 from registerfile, 1 from imm

    always_comb begin
        case (i_opcode)
            `LOAD: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `FP_LOAD: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `STORE: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `FP_STORE: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `BRANCH: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `JALR: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `JAL: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `ARITHMETIC_IMM: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `ARITHMETIC: begin
                o_alu_use_sel_2 = 1'b0;
            end
            `AUIPC: begin
                o_alu_use_sel_2 = 1'b1;
            end
            `LUI: begin
                o_alu_use_sel_2 = 1'b1;
            end
            default: begin
                o_alu_use_sel_2 = 1'b0;
            end
        endcase
    end



    
//o_fp_sub 
assign o_fp_sub = i_funct5[0];    
endmodule:CONTROLLER_IP;