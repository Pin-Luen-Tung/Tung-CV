module FORWARD_IP (
    input [4:0] i_rs1_EX,
    input [4:0] i_rs2_EX,
    input i_write_fp_MEM,
    input i_write_fp_WB,
    input i_write_MEM,
    input i_write_WB,
    input [4:0] i_rd_MEM,
    input [4:0] i_rd_WB,
    input i_load_MEM,
    input i_load_fp_MEM,
    input i_fp_flag_MEM,
    input i_mul_flag_MEM,

    output logic [1:0] o_forward_sel_rs1,
    output logic [1:0] o_forward_sel_rs2,
    output logic [1:0] o_forward_sel_rs1_fp,
    output logic [1:0] o_forward_sel_rs2_fp
);
    
logic rs1_depend_MEM;
logic rs1_depend_WB;
logic rs2_depend_MEM;
logic rs2_depend_WB;
logic rs1_fp_depend_MEM;
logic rs1_fp_depend_WB;
logic rs2_fp_depend_MEM;
logic rs2_fp_depend_WB;
// 10 : From WB stage
// 01 : From MEM stage
// 00 : From EXE stage

    assign rs1_depend_MEM = (i_rs1_EX == i_rd_MEM) & (i_rd_MEM != 5'd0)&(i_load_MEM != 1)&(i_mul_flag_MEM != 1);
    assign rs1_depend_WB = (i_rs1_EX == i_rd_WB) & (i_rd_WB != 5'd0);

    assign rs2_depend_MEM = (i_rs2_EX == i_rd_MEM) & (i_rd_MEM != 5'd0)&(i_load_MEM != 1)&(i_mul_flag_MEM != 1);
    assign rs2_depend_WB = (i_rs2_EX == i_rd_WB) & (i_rd_WB != 5'd0);

    assign rs1_fp_depend_MEM = (i_rs1_EX == i_rd_MEM)&(i_load_fp_MEM != 1)&(i_fp_flag_MEM != 1); //可能有鬼因為FP RF0 能讀
    assign rs1_fp_depend_WB = (i_rs1_EX == i_rd_WB) ;

    assign rs2_fp_depend_MEM = (i_rs2_EX == i_rd_MEM)&(i_load_fp_MEM != 1)&(i_fp_flag_MEM != 1);
    assign rs2_fp_depend_WB = (i_rs2_EX == i_rd_WB) ;

    assign o_forward_sel_rs1 = (i_write_MEM & rs1_depend_MEM)? 2'b01 :
                               (i_write_WB  & rs1_depend_WB )? 2'b10 : 2'b00;

    assign o_forward_sel_rs2 = (i_write_MEM & rs2_depend_MEM)? 2'b01 :
                               (i_write_WB  & rs2_depend_WB )? 2'b10 : 2'b00;

    assign o_forward_sel_rs1_fp = (i_write_fp_MEM & rs1_fp_depend_MEM) ? 2'b01 :
                                  (i_write_fp_WB  & rs1_fp_depend_WB) ? 2'b10 : 2'b00;

    assign o_forward_sel_rs2_fp = (i_write_fp_MEM & rs2_fp_depend_MEM) ? 2'b01 :
                                  (i_write_fp_WB  & rs2_fp_depend_WB) ? 2'b10 : 2'b00;



endmodule