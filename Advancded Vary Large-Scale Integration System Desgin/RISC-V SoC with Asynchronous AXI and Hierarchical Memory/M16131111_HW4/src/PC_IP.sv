module PC_IP(
    input IM_hit,
    input waiting_DM_data_hit,
    input start,
    input start_r,
    input clk,
    input rst,
    input i_branch_decision,
    input i_branch,
    input i_jump,
    input i_stall,
    input [31:0] i_branch_addr,
    input [31:0] i_MEPC_EX,
    input i_MRET_EX,
    input [31:0] i_MTVEC_EX,
    input i_cpu_interrupt,
    output logic [31:0] o_pc
    
);
logic [31:0] pc;
logic [31:0] pc_next;

always_ff @(posedge clk or posedge rst)begin
        if(rst) pc <= 32'd0;
        else if(start) pc <= (((~i_stall) & IM_hit & ~waiting_DM_data_hit) | (start ^ start_r))? pc_next : pc;
    end

assign pc_next = (i_cpu_interrupt)? i_MTVEC_EX : (i_branch_decision)? (i_MRET_EX)? i_MEPC_EX : i_branch_addr : (pc + 32'd4);
assign o_pc = pc;
endmodule