module REGISTERFILE_FP_IP(
    input rst,
    input clk,
    input [4:0] i_rs1_fp_addr,
    input [4:0] i_rs2_fp_addr,
    output logic [31:0] o_rs1_fp_data,
    output logic [31:0] o_rs2_fp_data,


    input i_write_fp,
    input [4:0] i_write_fp_fp_addr,
    input [31:0] i_write_fp_fp_data
);

logic [31:0] registerfile_fp_mem [0:31] ;
integer i;
always_ff @( posedge clk or posedge rst ) begin
    
    if(rst)begin
        for(i=0 ; i<32 ; i=i+1)begin
            registerfile_fp_mem[i] <= 32'd0;
        end
    end
    else begin
        if((i_write_fp == 1'b1))begin
            registerfile_fp_mem[i_write_fp_fp_addr] <= i_write_fp_fp_data;
        end
    end
    
end



always_comb begin
    if((i_rs1_fp_addr == i_write_fp_fp_addr) && i_write_fp == 1'b1)begin
        o_rs1_fp_data = i_write_fp_fp_data;
    end
    else begin
        o_rs1_fp_data = registerfile_fp_mem[i_rs1_fp_addr];
    end
end

always_comb begin
    if((i_rs2_fp_addr == i_write_fp_fp_addr) && i_write_fp == 1'b1)begin
        o_rs2_fp_data = i_write_fp_fp_data;
    end
    else begin
        o_rs2_fp_data = registerfile_fp_mem[i_rs2_fp_addr];
    end
end
endmodule : REGISTERFILE_FP_IP;