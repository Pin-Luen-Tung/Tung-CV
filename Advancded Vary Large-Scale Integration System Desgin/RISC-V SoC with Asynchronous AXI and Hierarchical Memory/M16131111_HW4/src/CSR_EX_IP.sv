module CSR_EXE_IP(
    input clk,
    input rst,
    input [11:0] i_csr_addr,  // read this csr and write this csr if wen
    output logic [31:0] o_csr_rdata,
    // csr write need i_funct3, i_rs1_data, i_rs1_addr, o_csr_rdata
    input [ 2:0] i_funct3,
    input [31:0] i_rs1_data,
    input [ 4:0] i_rs1_addr,
    input        i_csr_wen,
    input        i_stall,
	input        i_start_EX,
	input        i_wfi_EX,
	

    input i_MTIP,
    input i_MEIP,
    input i_MRET,

    input [31:0] i_w_epc,
    input        i_ex_pc_valid,
    output logic[31:0] o_MEPC, // CSR reg
    output logic[31:0] o_MTVEC,

    output o_interrupt,
	output o_wfi_disable
    );
    // machiine level CSR 
    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mtvec;
    logic [31:0] mepc;
    logic [31:0] mip;
	logic [63:0] mcycle;
	logic [63:0] minstret;

    logic [31:0] csr_wdata;
    

    assign o_MEPC = mepc;
    assign o_MTVEC = mtvec;

    always_comb begin
        case(i_funct3)
            3'b001:  csr_wdata =  i_rs1_data;                   // CSRRW
            3'b010:  csr_wdata =  i_rs1_data | o_csr_rdata;       // CSRRS
            3'b011:  csr_wdata =  ~i_rs1_data & o_csr_rdata;      // CSRRC
            3'b101:  csr_wdata =  {27'b0, i_rs1_addr};             // CSRRWI
            3'b110:  csr_wdata =  {27'b0, i_rs1_addr} | o_csr_rdata; // CSRRSI
            3'b111:  csr_wdata = ~{27'b0, i_rs1_addr} & o_csr_rdata; // CSRRCI
            default: csr_wdata = 32'b0;
        endcase
    end

// mstatus
always_ff@(posedge clk or posedge rst)begin
    if(rst) mstatus <= 32'd0;
    else if((o_interrupt|(i_wfi_EX & o_wfi_disable)) & ~i_stall & i_ex_pc_valid) mstatus <= {19'd0, 2'b11, 3'd0, mstatus[3], 3'd0, 1'd0, 3'd0};
    else if(i_MRET & ~i_stall) mstatus <= {19'd0, 2'b11, 3'd0, 1'b1, 3'd0, mstatus[7], 3'd0};
    else if((i_csr_addr == 12'h300) & i_csr_wen & ~i_stall)  mstatus <=  {19'd0, csr_wdata[12:11], 3'd0, csr_wdata[7], 3'd0, csr_wdata[3], 3'd0};
end
// mcycle
always_ff @(posedge clk or posedge rst)begin
	if(rst) mcycle <= 64'd0;
	else if(i_start_EX) mcycle <= mcycle + 64'd1;
end	
// minstret:wrong 
always_ff @(posedge clk or posedge rst)begin
	if(rst) minstret <= 64'd0;
	else if(i_ex_pc_valid & ~i_stall) minstret <= minstret + 64'd1;
end	
// mip RO
always_ff @(posedge clk or posedge rst)begin
    if(rst) mip <= 32'd0;
    else mip <= {20'd0,i_MEIP,3'd0,i_MTIP,7'd0};
end
// mie 
always_ff @(posedge clk or posedge rst)begin
    if(rst) mie <= 32'd0;
    else if((i_csr_addr == 12'h304) & i_csr_wen & ~i_stall) mie <= {20'd0, csr_wdata[11], 3'd0, csr_wdata[7], 7'd0}; // need modify
end
// mtvec RO
always_ff @(posedge clk or posedge rst)begin
    if(rst) mtvec <= 32'd0;
    else mtvec <= 32'h0001_0000;
end
// mepc
always_ff @(posedge clk or posedge rst)begin
    if(rst) mepc <= 32'h0000_0000;
    else if (o_interrupt|(i_wfi_EX & o_wfi_disable) & ~i_stall & i_ex_pc_valid) mepc <= i_w_epc;
    else if((i_csr_addr == 12'h341) & i_csr_wen & ~i_stall) mepc <= csr_wdata; // cpu write
end
always_comb begin
    case(i_csr_addr)
		12'hb00: o_csr_rdata = mcycle[31:0];
		12'hb80: o_csr_rdata = mcycle[63:32];
		12'hb02: o_csr_rdata = minstret[31:0];
		12'hb82: o_csr_rdata = minstret[63:32];
        12'h300: o_csr_rdata = mstatus;
        12'h304: o_csr_rdata = mie; 
        12'h305: o_csr_rdata = mtvec; // read only
        12'h341: o_csr_rdata = mepc;
        12'h344: o_csr_rdata = mip;   // read only
        default: o_csr_rdata = 32'hffffffff;
    endcase
end

assign o_interrupt = ((mip[7] & mstatus[3] & mie[7]) | (mip[11] & mstatus[3] & mie[11])) & i_ex_pc_valid;
assign o_wfi_disable = ((mip[7] & mie[7]) | (mip[11] & mie[11]));
endmodule