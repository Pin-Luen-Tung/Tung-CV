module REGISTERFILE_IP(
    input rst,
    input clk,
    input [4:0] i_rs1_addr,
    input [4:0] i_rs2_addr,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,


    input i_write,
    input [4:0] i_write_addr,
    input [31:0] i_write_data
);

logic [31:0] registerfile_mem [0:31] ;
integer i;
always_ff @( posedge clk or posedge rst ) begin
    
    if(rst)begin
        for(i=0 ; i<32 ; i=i+1)begin
            registerfile_mem[i] <= 32'd0;
        end
    end
    else begin
        if((i_write == 1'b1) && (i_write_addr != 5'd0))begin
            registerfile_mem[i_write_addr] <= i_write_data;
        end
    end
    
end



always_comb begin
    if((i_rs1_addr == i_write_addr) && (i_write == 1'b1) && (i_rs1_addr != 0) )begin
        o_rs1_data = i_write_data;
    end
    else begin
        o_rs1_data = registerfile_mem[i_rs1_addr];
    end
end

always_comb begin
    if((i_rs2_addr == i_write_addr) && (i_write == 1'b1) && (i_rs2_addr != 0))begin
        o_rs2_data = i_write_data;
    end
    else begin
        o_rs2_data = registerfile_mem[i_rs2_addr];
    end
end
endmodule : REGISTERFILE_IP;