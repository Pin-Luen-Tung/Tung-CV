

module CPU(
    input clk,
    input rst,
    // for AXI Wrapper M0
    output logic O_Instruc_Addr_VALID,//to flag valid address
    input I_Instruc_data_hit,// to flag hit memory data
    // for AXI Wrapper M1
    output logic O_WRITE_Data_ENABLE,
    output logic O_READ_Data_ENABLE,
    input I_Data_hit,
    //Instruction memory
    
    //output logic Intrucion mem
    output logic o_Instruc_CEB,
    output logic o_Instruc_WEB,
    output logic [31:0] o_Instruc_BWEB,
    output logic [31:0] o_Instruc_DI,
    output logic [31:0] o_Instruc_Addr,
    input [31:0] i_Instruc_data,
    
    //output logic data mem
    output logic o_Data_CEB,
    output logic o_Data_WEB,
    output logic [3:0] o_Data_BWEB,
    output logic [31:0] o_Data_DI,
    output logic [31:0] o_Data_Addr,
    input [31:0] i_Data_data,
    //interrupt
    input i_timer_interrupt_rq,
    input i_external_interrupt_rq
);

logic waiting_DM_data_hit;
logic waiting_Instruc_data_hit;
logic pipe_freeze;



////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            hazard detection                                                                                                
//                                                                                
////////////////////////////////////////////////////////////////////////////////////
logic stall;
logic load;
logic fp_load_fuck;
logic fp_flag;
logic mul_flag;

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            IF ports                                                                                                 
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

logic [31:0] pc_IF;


////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            IF/ID Reg                                                                                                
//                                                                                
////////////////////////////////////////////////////////////////////////////////////
logic [31:0] Instruc_data_IF_before;
logic [31:0] Instruc_data_IF_to_ID_Reg;
logic [31:0] pc_IF_to_ID_Reg;

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            ID ports                                                                                                 
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

// controller 
logic [3:0] alu_sel_ID; // alu control              //\\\\ control in EXE
logic [2:0] imm_sel_ID; // imm gen control         //\\\\ control in ID stage
logic [2:0] alu_use_sel_1_ID; // alu use data sel 1       //\\\\ control in EXE
logic [1:0] alu_use_sel_2_ID; // alu use data sel 2     //\\\\ control in EXE
logic fp_sub_ID; // if = 1, fp sub       //\\\\ control in EXE
logic write_ID; // data write reg     //\\\\ control in WB
logic write_fp_ID; // fp data write fp reg    //\\\\ control in WB
logic [2:0] mem_to_wb_sel_ID; // mem to wb output sel //\\\\ control in WB
logic WEB_ID; // 1 = read, 0 = write (DATA SRAM control)  //\\\\ control in MEM
logic [1:0] BWEB_pre_ID; // 0 = that bit can write     //\\\\ control in MEM
logic fp_store_ID; // fp store to mem     //\\\\ control in MEM
logic jump_ID; // jump instruc        //\\\\ control in EXE 
logic branch_ID; // branch instruc    //\\\\ control in EXE

// immgen

logic [31:0] imm_data_ID;   //\\\\\ use in EXE
logic [1:0] csr_sel_ID;     

// Register file

logic [31:0] rs1_data_ID;
logic [31:0] rs2_data_ID;

// FP Register file

logic [31:0] rs1_fp_data_ID;
logic [31:0] rs2_fp_data_ID;

// write destination
logic [4:0] rd_ID;

// rs1 , rs2
logic [4:0] rs1_ID;
logic [4:0] rs2_ID;
// funct3
logic [2:0] funct3_ID;

logic [31:0] csr_out_ID;

// csr_addr
logic [11:0] csr_addr_ID;
logic csr_wen_ID;
logic cpu_MRET_ID;
logic cpu_WFI_ID;

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            ID/EXE Reg                                                                                                
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

// controller 
logic [3:0] alu_sel_ID_to_EX_Reg; // alu control              //\\\\ control in EXE
//logic [2:0] imm_sel_ID_to_EX_Reg; // imm gen control         //\\\\ control in ID stage
logic [2:0] alu_use_sel_1_ID_to_EX_Reg; // alu use data sel 1       //\\\\ control in EXE
logic [1:0] alu_use_sel_2_ID_to_EX_Reg; // alu use data sel 2     //\\\\ control in EXE
logic fp_sub_ID_to_EX_Reg; // if = 1, fp sub       //\\\\ control in EXE
logic write_ID_to_EX_Reg; // data write reg     //\\\\ control in WB
logic write_fp_ID_to_EX_Reg; // fp data write fp reg    //\\\\ control in WB
logic [2:0] mem_to_wb_sel_ID_to_EX_Reg; // mem to wb output sel //\\\\ control in WB
logic WEB_ID_to_EX_Reg; // 1 = read, 0 = write (DATA SRAM control)  //\\\\ control in MEM
logic [1:0] BWEB_pre_ID_to_EX_Reg; // 0 = that bit can write     //\\\\ control in MEM
logic fp_store_ID_to_EX_Reg; // fp store to mem     //\\\\ control in MEM
logic jump_ID_to_EX_Reg; // jump instruc        //\\\\ control in EXE 
logic branch_ID_to_EX_Reg; // branch instruc    //\\\\ control in EXE

// immgen

logic [31:0] imm_data_ID_to_EX_Reg;   //\\\\\ use in EXE
logic [1:0] csr_sel_ID_to_EX_Reg;     

// Register file

logic [31:0] rs1_data_ID_to_EX_Reg;
logic [31:0] rs2_data_ID_to_EX_Reg;

// FP Register file

logic [31:0] rs1_fp_data_ID_to_EX_Reg;
logic [31:0] rs2_fp_data_ID_to_EX_Reg;

// write destination 
logic [4:0] rd_ID_to_EX_Reg;

// rs1 , rs2
logic [4:0] rs1_ID_to_EX_Reg;
logic [4:0] rs2_ID_to_EX_Reg;
// funct3
logic [2:0] funct3_ID_to_EX_Reg;
//pc
logic [31:0] pc_ID_to_EX_Reg;


logic [11:0] csr_addr_ID_to_EX_Reg;
logic csr_wen_ID_to_EX_Reg;
logic cpu_MRET_ID_to_EX_Reg;
logic cpu_WFI_ID_to_EX_Reg;
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                                       EX ports                                                                                                
//                                                                                
////////////////////////////////////////////////////////////////////////////////////



/////////   forward rs1/rs2 and forward fp rs1/rs2
logic [31:0] forward_alu_rs1_data_EX;
logic [31:0] forward_alu_rs2_data_EX;
logic [31:0] forward_fp_rs1_data_EX;
logic [31:0] forward_fp_rs2_data_EX;
logic [1:0] forward_sel_rs1_EX;
logic [1:0] forward_sel_rs2_EX;
logic [1:0] forward_sel_rs1_fp_EX;
logic [1:0] forward_sel_rs2_fp_EX;



logic [31:0] alu_rs1_data_use_EX;
logic [31:0] alu_rs2_data_use_EX;
logic [31:0] alu_out_EX;
logic [31:0] mul_out_EX;
logic [31:0] fp_out_EX;
logic [31:0] csr_out_ID_to_EX_Reg;
logic branch_decision_EX;
logic branch_EX;

logic interrupt_EX;
logic wfi_disable_EX;
logic [31:0] MTVEC_EX;
logic [31:0] MEPC_EX;
logic [31:0] wepc;
logic pc_valid_EX;
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            EX/MEM Reg                                                                                                
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

logic [31:0] pc_EX_to_MEM_Reg;
logic [4:0] rd_EX_to_MEM_Reg;
logic [31:0] alu_out_EX_to_MEM_Reg;
logic [31:0] mul_out_EX_to_MEM_Reg;
logic [31:0] fp_out_EX_to_MEM_Reg;
logic [31:0] csr_out_EX_to_MEM_Reg;
logic [31:0] forward_alu_rs2_data_EX_to_MEM_Reg;
logic [31:0] forward_fp_rs2_data_EX_to_MEM_Reg;
logic [2:0] funct3_EX_to_MEM_Reg;
logic fp_store_EX_to_MEM_Reg;
logic [1:0] BWEB_pre_EX_to_MEM_Reg;
logic WEB_EX_to_MEM_Reg;
logic write_EX_to_MEM_Reg; // data write reg     //\\\\ control in WB
logic write_fp_EX_to_MEM_Reg; // fp data write fp reg    //\\\\ control in WB
logic [2:0] mem_to_wb_sel_EX_to_MEM_Reg;

logic branch_EX_to_MEM_Reg;
logic stall_EX_to_MEM_Reg;
logic csr_wen_EX_to_MEM_Reg;
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            MEM   ports                                                                                            
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

logic [31:0] write_data_MEM;
logic load_flag_MEM;
logic load_fp_flag_MEM;
logic fp_flag_MEM;
logic mul_flag_MEM;
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            MEM / WB Reg                                                                                           
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

logic [31:0] write_data_MEM_to_WB_Reg;
logic write_MEM_to_WB_Reg;
logic write_fp_MEM_to_WB_Reg;
logic [2:0] funct3_MEM_to_WB_Reg;
logic [4:0] rd_MEM_to_WB_Reg;
logic load_flag_MEM_to_WB_Reg;
logic load_flag_fp_MEM_to_WB_Reg;
logic fp_flag_MEM_to_WB_Reg;
logic mul_flag_MEM_to_WB_Reg;
//logic [31:0] Data_mem_MEM;
logic [31:0] fp_out_MEM_to_WB_Reg;
logic [31:0] mul_out_MEM_to_WB_Reg;


////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            WB ports                                                                                          
//                                                                                
////////////////////////////////////////////////////////////////////////////////////


logic [31:0] DATA_MEM_WB;
logic [31:0] writedata_WB;
logic [31:0] lwdata_WB;
logic [31:0] fp_writedata_WB;


////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            Fuck                                                                                        
//                                                                                
////////////////////////////////////////////////////////////////////////////////////
logic start;
logic start1;
logic start2;
logic start3;
logic start4;
logic start5;
logic start6;
logic start7;
logic start8;
logic start9;
logic start10;



assign pipe_freeze = ~(waiting_Instruc_data_hit&I_Instruc_data_hit) | waiting_DM_data_hit | (cpu_WFI_ID_to_EX_Reg & ~wfi_disable_EX);
////////////////////////////////////////////////////////////
//
// 
//                  waiting IM hit
//
//
////////////////////////////////////////////////////////////////
    always_ff @(posedge clk or posedge rst)begin
        if(rst) waiting_Instruc_data_hit <= 1'b0;
        else if(~waiting_Instruc_data_hit)  waiting_Instruc_data_hit <= (start9 & O_Instruc_Addr_VALID)? 1'b1 : 1'b0;
        else if(waiting_Instruc_data_hit) waiting_Instruc_data_hit <= (I_Instruc_data_hit)? 1'b0: 1'b1;
    end
    
////////////////////////////////////////////////////////////
//
// 
//                  waiting DM hit
//
//
////////////////////////////////////////////////////////////////
    always_ff @(posedge clk or posedge rst)begin
        if(rst) waiting_DM_data_hit <= 1'b0;
        else if(~waiting_DM_data_hit)  waiting_DM_data_hit <= (~pipe_freeze & ((mem_to_wb_sel_ID_to_EX_Reg == 3'b110) | (mem_to_wb_sel_ID_to_EX_Reg == 3'b001) | (BWEB_pre_ID_to_EX_Reg != 2'b00) | (fp_store_ID_to_EX_Reg == 1)))? 1'b1 : 1'b0;
        else if(waiting_DM_data_hit) waiting_DM_data_hit <= (I_Data_hit)? 1'b0: 1'b1;
    end

///////////////////////////////////////////////////////////
//
// 
//                 CPU interrupt
//
//
////////////////////////////////////////////////////////////////
    
logic cpu_interrupt;
logic cpu_interrupt_reg;
assign cpu_interrupt = interrupt_EX | (cpu_WFI_ID_to_EX_Reg & wfi_disable_EX);
always_ff @(posedge clk) begin
       if(rst) begin
            cpu_interrupt_reg <= 1'b0;
       end
       else if(~pipe_freeze) begin
            cpu_interrupt_reg <= cpu_interrupt;
       end 
end










always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start <= 1'b0;
    end else begin
        start <= 1'b1;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start1 <= 1'b0;
    end else begin
        start1 <= start;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start2 <= 1'b0;
    end else begin
        start2 <= start1;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start3 <= 1'b0;
    end else begin
        start3 <= start2;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start4 <= 1'b0;
    end else begin
        start4 <= start3;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start5 <= 1'b0;
    end else begin
        start5 <= start4;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start6 <= 1'b0;
    end else begin
        start6 <= start5;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start7 <= 1'b0;
    end else begin
        start7 <= start6;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start8 <= 1'b0;
    end else begin
        start8 <= start7;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start9 <= 1'b0;
    end else begin
        start9 <= start8;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start10 <= 1'b0;
    end else begin
        start10 <= start9;
    end
end




////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            Instruction Fetch                                                                                       
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

// program counter 
    PC_IP PC(
        .start(start9),
        .start_r(start10),
        .IM_hit(I_Instruc_data_hit),
        .waiting_DM_data_hit(waiting_DM_data_hit),
        .clk(clk),
        .rst(rst),
        .i_branch_decision(branch_EX),
        .i_branch(branch_ID_to_EX_Reg),
        .i_jump(jump_ID_to_EX_Reg),
        .i_branch_addr(alu_out_EX),
        .i_stall(stall),
        .i_MRET_EX(cpu_MRET_ID_to_EX_Reg),
        .i_MEPC_EX(MEPC_EX),
        .i_cpu_interrupt(cpu_interrupt),
        .i_MTVEC_EX(MTVEC_EX),
        .o_pc(pc_IF)
    );

//  SRAM Control 
    assign o_Instruc_CEB = 1'b0;
    assign o_Instruc_WEB = 1'b0;
    assign o_Instruc_BWEB = ~(32'd0);
    always_ff @(posedge clk) o_Instruc_Addr <= (I_Instruc_data_hit & (~waiting_DM_data_hit))?pc_IF : pc_IF_to_ID_Reg;
    assign Instruc_data_IF_to_ID_Reg = (branch_EX_to_MEM_Reg | cpu_interrupt_reg)? 32'b0:(stall_EX_to_MEM_Reg)? Instruc_data_IF_before:(I_Instruc_data_hit)? i_Instruc_data : 32'b0;
    always_ff @(posedge clk) begin
        if(rst) O_Instruc_Addr_VALID <= 1'b0;
        else O_Instruc_Addr_VALID <= ((~O_Instruc_Addr_VALID)|(O_Instruc_Addr_VALID&I_Instruc_data_hit)) & ~waiting_Instruc_data_hit & ~waiting_DM_data_hit;
    end
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//              Instruction Fetch / Instrucion Decode Pipeline Reg                                                                          
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            Instruc_data_IF_before <= 0;
            pc_IF_to_ID_Reg <= 0;
        end
        else if((branch_EX | cpu_interrupt) & ~pipe_freeze) begin
            Instruc_data_IF_before<= 0;
            pc_IF_to_ID_Reg <= 0;
        end
        else begin
            Instruc_data_IF_before <= (~pipe_freeze)? i_Instruc_data : Instruc_data_IF_before;
            pc_IF_to_ID_Reg <= (stall | pipe_freeze)? pc_IF_to_ID_Reg : pc_IF;
        end
    end
   //因SRAM 本來就有dealy

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                            Instruction Decode                                                                                       
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    CONTROLLER_IP CONTROLLER(
        .i_funct7(Instruc_data_IF_to_ID_Reg[31:25]),
        .i_funct3(Instruc_data_IF_to_ID_Reg[14:12]),
        .i_opcode(Instruc_data_IF_to_ID_Reg[6:0]),
        .i_funct5(Instruc_data_IF_to_ID_Reg[31:27]),

        .o_alu_sel(alu_sel_ID),
        .o_imm_sel(imm_sel_ID),
        .o_alu_use_sel_1(alu_use_sel_1_ID),
        .o_alu_use_sel_2(alu_use_sel_2_ID),
        .o_fp_sub(fp_sub_ID),
        .o_write(write_ID),
        .o_write_fp(write_fp_ID),
        .o_mem_to_wb_sel(mem_to_wb_sel_ID),
        .o_WEB(WEB_ID),
        .o_BWEB_pre(BWEB_pre_ID),
        .o_fp_store(fp_store_ID),
        .o_jump(jump_ID),
        .o_branch(branch_ID)

    );

    IMMGEN_IP IMMGEN(
        .i_imm_instruction(Instruc_data_IF_to_ID_Reg),
        .i_imm_sel(imm_sel_ID),
        .o_imm_data(imm_data_ID),
        .o_csr_sel(csr_sel_ID)
    );

    REGISTERFILE_IP REGISTERFILE(
        .rst(rst),
        .clk(clk),
        .i_rs1_addr(Instruc_data_IF_to_ID_Reg[19:15]),
        .i_rs2_addr(Instruc_data_IF_to_ID_Reg[24:20]),
        .o_rs1_data(rs1_data_ID),
        .o_rs2_data(rs2_data_ID),
        //WB
        .i_write(write_MEM_to_WB_Reg),
        .i_write_addr(rd_MEM_to_WB_Reg),
        .i_write_data(writedata_WB)
    );
 
    REGISTERFILE_FP_IP REGISTERFILE_FP(
        .rst(rst),
        .clk(clk),
        .i_rs1_fp_addr(Instruc_data_IF_to_ID_Reg[19:15]),
        .i_rs2_fp_addr(Instruc_data_IF_to_ID_Reg[24:20]),
        .o_rs1_fp_data(rs1_fp_data_ID),
        .o_rs2_fp_data(rs2_fp_data_ID),
        //WB
        .i_write_fp(write_fp_MEM_to_WB_Reg),
        .i_write_fp_fp_addr(rd_MEM_to_WB_Reg),
        .i_write_fp_fp_data(fp_writedata_WB)
    );
    
    CSR_IP CSR(
            .pipe_freeze(pipe_freeze),
            .clk(clk),
            .rst(rst),
            .i_csr_barnch_exe(branch_EX),
            .i_csr_sel(csr_sel_ID),
            .i_csr_stall(stall),
            .o_csr_data(csr_out_ID)
    );
    
    assign rd_ID = Instruc_data_IF_to_ID_Reg[11:7];
    assign rs1_ID = Instruc_data_IF_to_ID_Reg[19:15];
    assign rs2_ID = Instruc_data_IF_to_ID_Reg[24:20];
    assign funct3_ID = Instruc_data_IF_to_ID_Reg[14:12];
    assign csr_addr_ID = Instruc_data_IF_to_ID_Reg[31:20];

    assign csr_wen_ID = (funct3_ID[1:0] == 2'b01)? (Instruc_data_IF_to_ID_Reg[6:0] == `CSR) : (Instruc_data_IF_to_ID_Reg[6:0] == `CSR) & (rs1_ID != 5'd0);
    assign cpu_MRET_ID = (Instruc_data_IF_to_ID_Reg[6:0] == `CSR) & (csr_addr_ID == 12'h302);
    assign cpu_WFI_ID = (Instruc_data_IF_to_ID_Reg[6:0] == `CSR) & (csr_addr_ID == 12'h105);
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//              Instruction Decode / Excute operation  Pipeline Reg                                                                          
//                                                                                
////////////////////////////////////////////////////////////////////////////////////
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            alu_sel_ID_to_EX_Reg <= 4'b0;
            //imm_sel_ID_to_EX_Reg <= 3'b0;
            alu_use_sel_1_ID_to_EX_Reg <= 3'b0;
            alu_use_sel_2_ID_to_EX_Reg <= 2'b0;
            fp_sub_ID_to_EX_Reg <= 1'b0;
            write_ID_to_EX_Reg <= 1'b0;
            write_fp_ID_to_EX_Reg <= 1'b0;
            mem_to_wb_sel_ID_to_EX_Reg <= 3'b0;
            WEB_ID_to_EX_Reg <= 1'b0;
            BWEB_pre_ID_to_EX_Reg <= 2'b0;
            fp_store_ID_to_EX_Reg <= 1'b0;
            jump_ID_to_EX_Reg <= 1'b0;
            branch_ID_to_EX_Reg <= 1'b0;
            imm_data_ID_to_EX_Reg <= 32'b0;
            csr_sel_ID_to_EX_Reg <= 1'b0;
            rs1_data_ID_to_EX_Reg <= 32'b0;
            rs2_data_ID_to_EX_Reg <= 32'b0;
            rs1_fp_data_ID_to_EX_Reg <= 32'b0;
            rs2_fp_data_ID_to_EX_Reg <= 32'b0;
            rd_ID_to_EX_Reg <= 5'b0;
            rs1_ID_to_EX_Reg <= 5'b0;
            rs2_ID_to_EX_Reg <= 5'b0;
            funct3_ID_to_EX_Reg <= 3'b0;
            pc_ID_to_EX_Reg <= 32'b0;
            csr_out_ID_to_EX_Reg <= 32'b0;
            csr_addr_ID_to_EX_Reg <= 12'b0;
            csr_wen_ID_to_EX_Reg <= 1'b0;
            cpu_MRET_ID_to_EX_Reg <= 1'b0;
            cpu_WFI_ID_to_EX_Reg <= 1'b0;
        end 
        else if((branch_EX || stall || cpu_interrupt) & ~pipe_freeze)begin
            alu_sel_ID_to_EX_Reg <= 4'b0;
            //imm_sel_ID_to_EX_Reg <= 3'b0;
            alu_use_sel_1_ID_to_EX_Reg <= 3'b0;
            alu_use_sel_2_ID_to_EX_Reg <= 2'b0;
            fp_sub_ID_to_EX_Reg <= 1'b0;
            write_ID_to_EX_Reg <= 1'b0;
            write_fp_ID_to_EX_Reg <= 1'b0;
            mem_to_wb_sel_ID_to_EX_Reg <= 3'b0;
            WEB_ID_to_EX_Reg <= 1'b0;
            BWEB_pre_ID_to_EX_Reg <= 2'b0;
            fp_store_ID_to_EX_Reg <= 1'b0;
            jump_ID_to_EX_Reg <= 1'b0;
            branch_ID_to_EX_Reg <= 1'b0;
            imm_data_ID_to_EX_Reg <= 32'b0;
            csr_sel_ID_to_EX_Reg <= 1'b0;
            rs1_data_ID_to_EX_Reg <= 32'b0;
            rs2_data_ID_to_EX_Reg <= 32'b0;
            rs1_fp_data_ID_to_EX_Reg <= 32'b0;
            rs2_fp_data_ID_to_EX_Reg <= 32'b0;
            rd_ID_to_EX_Reg <= 5'b0;
            rs1_ID_to_EX_Reg <= 5'b0;
            rs2_ID_to_EX_Reg <= 5'b0;
            funct3_ID_to_EX_Reg <= 3'b0;
            pc_ID_to_EX_Reg <= 32'b0;
            csr_out_ID_to_EX_Reg <= 32'b0;
            csr_addr_ID_to_EX_Reg <= 12'b0;
            csr_wen_ID_to_EX_Reg <= 1'b0;
            cpu_MRET_ID_to_EX_Reg <= 1'b0;
            cpu_WFI_ID_to_EX_Reg <= 1'b0;
        end
        else if (start10 & ~pipe_freeze)begin 
            alu_sel_ID_to_EX_Reg <= alu_sel_ID;
            //imm_sel_ID_to_EX_Reg <= imm_sel_ID;
            alu_use_sel_1_ID_to_EX_Reg <= alu_use_sel_1_ID;
            alu_use_sel_2_ID_to_EX_Reg <= alu_use_sel_2_ID;
            fp_sub_ID_to_EX_Reg <= fp_sub_ID;
            write_ID_to_EX_Reg <= write_ID;
            write_fp_ID_to_EX_Reg <= write_fp_ID;
            mem_to_wb_sel_ID_to_EX_Reg <= mem_to_wb_sel_ID;
            WEB_ID_to_EX_Reg <= WEB_ID;
            BWEB_pre_ID_to_EX_Reg <= BWEB_pre_ID;
            fp_store_ID_to_EX_Reg <= fp_store_ID;
            jump_ID_to_EX_Reg <= jump_ID;
            branch_ID_to_EX_Reg <= branch_ID;
            imm_data_ID_to_EX_Reg <= imm_data_ID;
            csr_sel_ID_to_EX_Reg <= csr_sel_ID;
            rs1_data_ID_to_EX_Reg <= rs1_data_ID;
            rs2_data_ID_to_EX_Reg <= rs2_data_ID;
            rs1_fp_data_ID_to_EX_Reg <= rs1_fp_data_ID;
            rs2_fp_data_ID_to_EX_Reg <= rs2_fp_data_ID;
            rd_ID_to_EX_Reg <= rd_ID;
            rs1_ID_to_EX_Reg <= rs1_ID;
            rs2_ID_to_EX_Reg <= rs2_ID;
            funct3_ID_to_EX_Reg <= funct3_ID;
            pc_ID_to_EX_Reg <= pc_IF_to_ID_Reg;
            csr_out_ID_to_EX_Reg <= csr_out_ID;
            csr_addr_ID_to_EX_Reg <= csr_addr_ID;
            csr_wen_ID_to_EX_Reg <= csr_wen_ID;
            cpu_MRET_ID_to_EX_Reg <= cpu_MRET_ID;
            cpu_WFI_ID_to_EX_Reg <= cpu_WFI_ID;
        end
    end





    
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                    Excute operation or calculate address                                                                                       
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    assign branch_EX = (branch_decision_EX&&branch_ID_to_EX_Reg) || (jump_ID_to_EX_Reg) || (cpu_MRET_ID_to_EX_Reg);

    assign forward_alu_rs1_data_EX =    (forward_sel_rs1_EX == 2'b10)? writedata_WB :
                                        (forward_sel_rs1_EX == 2'b01)? write_data_MEM : rs1_data_ID_to_EX_Reg;

    assign forward_alu_rs2_data_EX =    (forward_sel_rs2_EX == 2'b10)? writedata_WB :
                                        (forward_sel_rs2_EX == 2'b01)? write_data_MEM : rs2_data_ID_to_EX_Reg;

    assign forward_fp_rs1_data_EX =     (forward_sel_rs1_fp_EX== 2'b10)? fp_writedata_WB :
                                        (forward_sel_rs1_fp_EX == 2'b01)? write_data_MEM : rs1_fp_data_ID_to_EX_Reg;

    assign forward_fp_rs2_data_EX =     (forward_sel_rs2_fp_EX== 2'b10)? fp_writedata_WB :
                                        (forward_sel_rs2_fp_EX == 2'b01)? write_data_MEM : rs2_fp_data_ID_to_EX_Reg;


    assign alu_rs1_data_use_EX =    (alu_use_sel_1_ID_to_EX_Reg == 2'd0)? forward_alu_rs1_data_EX :
                                    (alu_use_sel_1_ID_to_EX_Reg == 2'd1)? pc_ID_to_EX_Reg   :
                                    (alu_use_sel_1_ID_to_EX_Reg == 2'd2)? 32'b0 : 32'd0;
    
    assign alu_rs2_data_use_EX = (alu_use_sel_2_ID_to_EX_Reg== 1'b0)? forward_alu_rs2_data_EX : imm_data_ID_to_EX_Reg;
    
    BRANCH_DECISION_IP BRANCH_DECISION(
        .i_branch_data_1(forward_alu_rs1_data_EX),
        .i_branch_data_2(forward_alu_rs2_data_EX),
        .i_branch_funct3(funct3_ID_to_EX_Reg),
        .o_branch_decision(branch_decision_EX)
    );


    FP_IP FP(
        .pipe_freeze(pipe_freeze),
        .i_x_fp(forward_fp_rs1_data_EX),
        .i_y_fp(forward_fp_rs2_data_EX),
        .i_fp_sub(fp_sub_ID_to_EX_Reg),
        .clk(clk),
        .rst(rst),
        .o_fp(fp_out_MEM_to_WB_Reg)
    );

    MUL_IP MUL(
        .pipe_freeze(pipe_freeze),
        .i_x_mul(forward_alu_rs1_data_EX),
        .i_y_mul(forward_alu_rs2_data_EX),
        .mul_sel(funct3_ID_to_EX_Reg[1:0]),
        .clk(clk),
        .rst(rst),
        .o_mul(mul_out_MEM_to_WB_Reg)
    );


    ALU_IP ALU(
        .i_x_alu(alu_rs1_data_use_EX),
        .i_y_alu(alu_rs2_data_use_EX),
        .i_alu_sel(alu_sel_ID_to_EX_Reg),
        .o_alu(alu_out_EX)
    );

    logic csr_exe_flag;
    assign csr_exe_flag = ((csr_addr_ID_to_EX_Reg == 12'h300) | (csr_addr_ID_to_EX_Reg == 12'h304) | (csr_addr_ID_to_EX_Reg == 12'h305) | (csr_addr_ID_to_EX_Reg == 12'h341) | (csr_addr_ID_to_EX_Reg == 12'h344));

    logic [31:0] csr_rdata_EX;

    assign wepc = (cpu_WFI_ID_to_EX_Reg)? pc_IF_to_ID_Reg : pc_ID_to_EX_Reg;
    assign pc_valid_EX = pc_ID_to_EX_Reg != 32'b0;

    CSR_EXE_IP CSREXE(
        .clk(clk),
        .rst(rst),
        .i_csr_addr(csr_addr_ID_to_EX_Reg),
        .o_csr_rdata(csr_rdata_EX),
        .i_funct3(funct3_ID_to_EX_Reg),
        .i_rs1_data(forward_alu_rs1_data_EX),
        .i_rs1_addr(rs1_ID_to_EX_Reg),
        .i_csr_wen(csr_wen_ID_to_EX_Reg),
        .i_stall(pipe_freeze),
        .i_start_EX(start10),
        .i_wfi_EX(cpu_WFI_ID_to_EX_Reg),
        .i_MTIP(i_timer_interrupt_rq),
        .i_MEIP(i_external_interrupt_rq),
        .i_MRET(cpu_MRET_ID_to_EX_Reg),
        .i_w_epc(wepc),
        .i_ex_pc_valid(pc_valid_EX),
        .o_MEPC(MEPC_EX),
        .o_MTVEC(MTVEC_EX),
        .o_interrupt(interrupt_EX),
        .o_wfi_disable(wfi_disable_EX)
    );
   
    
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//              Excute operation or calculate address/ MEM Reg                                                                          
//                                                                                
////////////////////////////////////////////////////////////////////////////////////



    always_ff @( posedge clk or posedge rst ) begin
        if(rst) begin
            pc_EX_to_MEM_Reg <= 32'b0;
            rd_EX_to_MEM_Reg <= 5'b0;
            alu_out_EX_to_MEM_Reg <= 32'b0;
            //mul_out_EX_to_MEM_Reg <= 32'b0;
            //fp_out_EX_to_MEM_Reg <= 32'b0;
            csr_out_EX_to_MEM_Reg <= 32'b0;
            forward_alu_rs2_data_EX_to_MEM_Reg <= 32'b0;
            forward_fp_rs2_data_EX_to_MEM_Reg <= 32'b0;
            funct3_EX_to_MEM_Reg <= 3'b0;
            fp_store_EX_to_MEM_Reg <= 1'b0;
            BWEB_pre_EX_to_MEM_Reg <= 2'b0;
            WEB_EX_to_MEM_Reg <= 1'b0;
            write_EX_to_MEM_Reg <= 1'b0;
            write_fp_EX_to_MEM_Reg <= 1'b0;
            mem_to_wb_sel_EX_to_MEM_Reg <= 3'b0;
            branch_EX_to_MEM_Reg <= 1'b0;
            stall_EX_to_MEM_Reg <= 1'b0;
            csr_wen_EX_to_MEM_Reg <= 1'b0;
        end
        else if(~pipe_freeze & cpu_interrupt)begin
            pc_EX_to_MEM_Reg <= 32'b0;
            rd_EX_to_MEM_Reg <= 5'b0;
            alu_out_EX_to_MEM_Reg <= 32'b0;
            //mul_out_EX_to_MEM_Reg <= 32'b0;
            //fp_out_EX_to_MEM_Reg <= 32'b0;
            csr_out_EX_to_MEM_Reg <= 32'b0;
            forward_alu_rs2_data_EX_to_MEM_Reg <= 32'b0;
            forward_fp_rs2_data_EX_to_MEM_Reg <= 32'b0;
            funct3_EX_to_MEM_Reg <= 3'b0;
            fp_store_EX_to_MEM_Reg <= 1'b0;
            BWEB_pre_EX_to_MEM_Reg <= 2'b0;
            WEB_EX_to_MEM_Reg <= 1'b0;
            write_EX_to_MEM_Reg <= 1'b0;
            write_fp_EX_to_MEM_Reg <= 1'b0;
            mem_to_wb_sel_EX_to_MEM_Reg <= 3'b0;
            branch_EX_to_MEM_Reg <= 1'b0;
            stall_EX_to_MEM_Reg <= 1'b0;
            csr_wen_EX_to_MEM_Reg <= 1'b0; 
        end
        else if(~pipe_freeze) begin
            pc_EX_to_MEM_Reg <= (pc_ID_to_EX_Reg + 4);
            rd_EX_to_MEM_Reg <= rd_ID_to_EX_Reg;
            alu_out_EX_to_MEM_Reg <= alu_out_EX;
            //mul_out_EX_to_MEM_Reg <= mul_out_EX;
            //fp_out_EX_to_MEM_Reg <= fp_out_EX;
            csr_out_EX_to_MEM_Reg <= (csr_exe_flag)? csr_rdata_EX:csr_out_ID_to_EX_Reg;
            forward_alu_rs2_data_EX_to_MEM_Reg <= forward_alu_rs2_data_EX;
            forward_fp_rs2_data_EX_to_MEM_Reg <= forward_fp_rs2_data_EX;
            funct3_EX_to_MEM_Reg <= funct3_ID_to_EX_Reg;
            fp_store_EX_to_MEM_Reg <= fp_store_ID_to_EX_Reg;
            BWEB_pre_EX_to_MEM_Reg <= BWEB_pre_ID_to_EX_Reg;
            WEB_EX_to_MEM_Reg <= WEB_ID_to_EX_Reg;
            write_EX_to_MEM_Reg <= write_ID_to_EX_Reg;
            write_fp_EX_to_MEM_Reg <= write_fp_ID_to_EX_Reg;
            mem_to_wb_sel_EX_to_MEM_Reg <= mem_to_wb_sel_ID_to_EX_Reg;
            branch_EX_to_MEM_Reg <= branch_EX;
            stall_EX_to_MEM_Reg <= stall;
            csr_wen_EX_to_MEM_Reg <= csr_wen_ID_to_EX_Reg;
        end
    end

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//              MEM stage                                                                         
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        case(mem_to_wb_sel_EX_to_MEM_Reg)
            `ALUOUT: begin
                write_data_MEM = alu_out_EX_to_MEM_Reg;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
            `LOAD_DATA: begin
                write_data_MEM = 32'd0;
                load_flag_MEM = 1'b1;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
            `PC_PLUS_4: begin
                write_data_MEM = pc_EX_to_MEM_Reg;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
            `CSROUT: begin
                write_data_MEM = csr_out_EX_to_MEM_Reg;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
            `MULOUT: begin
                write_data_MEM = 32'd0;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b1;
                fp_flag_MEM = 1'b0;
            end
            `FPOUT: begin
                write_data_MEM = 32'd0;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b1;
            end
            `FP_LOAD_DATA: begin
                write_data_MEM = 32'd0;
                load_fp_flag_MEM = 1'b1;
                load_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
            default:begin
                write_data_MEM = 32'd0;
                load_flag_MEM = 1'b0;
                load_fp_flag_MEM = 1'b0;
                mul_flag_MEM = 1'b0;
                fp_flag_MEM = 1'b0;
            end
        endcase
    end


    assign o_Data_Addr = alu_out_EX_to_MEM_Reg;

    always_comb begin
        if (fp_store_EX_to_MEM_Reg) begin
            //o_Data_BWEB = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
            o_Data_BWEB = 4'b0000;
            o_Data_WEB = 1'b0;
        end
        else begin
            case(BWEB_pre_EX_to_MEM_Reg)
                2'b11: begin
                    //o_Data_BWEB = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
                    o_Data_BWEB = 4'b0000;
                    o_Data_WEB = 1'b0;
                end
                2'b10: begin
                    if (alu_out_EX_to_MEM_Reg[1]) begin
                        //o_Data_BWEB = 32'b0000_0000_0000_0000_1111_1111_1111_1111;
                        o_Data_BWEB = 4'b0011;
                        o_Data_WEB = 1'b0;
                    end 
                    else begin
                        //o_Data_BWEB = 32'b1111_1111_1111_1111_0000_0000_0000_0000;
                        o_Data_BWEB = 4'b1100;
                        o_Data_WEB = 1'b0;
                    end
                end
                2'b01: begin
                    case (alu_out_EX_to_MEM_Reg[1:0])
                        2'b00: begin
                            //o_Data_BWEB = 32'b1111_1111_1111_1111_1111_1111_0000_0000;
                            o_Data_BWEB = 4'b1110;
                            o_Data_WEB = 1'b0;
                        end
                        2'b01: begin
                            //o_Data_BWEB = 32'b1111_1111_1111_1111_0000_0000_1111_1111;
                            o_Data_BWEB = 4'b1101;
                            o_Data_WEB = 1'b0;
                        end
                        2'b10: begin
                            //o_Data_BWEB = 32'b1111_1111_0000_0000_1111_1111_1111_1111;
                            o_Data_BWEB = 4'b1011;
                            o_Data_WEB = 1'b0;
                        end
                        2'b11: begin
                            //o_Data_BWEB = 32'b0000_0000_1111_1111_1111_1111_1111_1111;
                            o_Data_BWEB = 4'b0111;
                            o_Data_WEB = 1'b0;
                        end
                        default: begin
                            o_Data_BWEB = 4'b1111;
                            o_Data_WEB = 1'b1;
                        end
                    endcase
                end
                2'b00: begin
                    //o_Data_BWEB = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
                    o_Data_BWEB = 4'b1111;
                    o_Data_WEB = 1'b1;
                end
            endcase
        end
    end
       
    assign O_WRITE_Data_ENABLE = waiting_DM_data_hit & ((BWEB_pre_EX_to_MEM_Reg != 2'b00) | (fp_store_EX_to_MEM_Reg == 1));
    assign O_READ_Data_ENABLE = (write_EX_to_MEM_Reg | write_fp_EX_to_MEM_Reg) & ((mem_to_wb_sel_EX_to_MEM_Reg == 3'b001) | (mem_to_wb_sel_EX_to_MEM_Reg == 3'b110)) & waiting_DM_data_hit;



    always_comb begin 
        if(fp_store_EX_to_MEM_Reg)begin
            o_Data_DI = forward_fp_rs2_data_EX_to_MEM_Reg;
        end
        else begin
        case (alu_out_EX_to_MEM_Reg[1:0])
            2'b00: begin
                o_Data_DI = forward_alu_rs2_data_EX_to_MEM_Reg;
            end
            2'b01: begin
                o_Data_DI = {forward_alu_rs2_data_EX_to_MEM_Reg [23:0] , 8'b0};
            end
            2'b10: begin
                o_Data_DI = {forward_alu_rs2_data_EX_to_MEM_Reg [15:0], 16'b0};
            end
            2'b11: begin
                o_Data_DI = {forward_alu_rs2_data_EX_to_MEM_Reg [7:0] , 24'b0};
            end
            default: begin
                o_Data_DI = 32'd0;
            end
        endcase
        end
    end

   

////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                       MEM/Write Back Reg                                                                        
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

logic [1:0] WB_Address;

    always_ff @( posedge clk or posedge rst ) begin
        if(rst) begin
            write_data_MEM_to_WB_Reg <= 32'b0;
            write_MEM_to_WB_Reg <= 1'b0;
            write_fp_MEM_to_WB_Reg <= 1'b0;
            funct3_MEM_to_WB_Reg <= 3'b0;
            rd_MEM_to_WB_Reg <= 5'b0;
            load_flag_MEM_to_WB_Reg <= 1'b0;
            load_flag_fp_MEM_to_WB_Reg <= 1'b0;
            fp_flag_MEM_to_WB_Reg <= 1'b0;
            mul_flag_MEM_to_WB_Reg <= 1'b0;
            DATA_MEM_WB <= 1'b0;

            WB_Address <= 2'b0;
        end
        else if (~pipe_freeze) begin
            write_data_MEM_to_WB_Reg <= write_data_MEM;
            write_MEM_to_WB_Reg <= write_EX_to_MEM_Reg;
            write_fp_MEM_to_WB_Reg <= write_fp_EX_to_MEM_Reg;
            funct3_MEM_to_WB_Reg <= funct3_EX_to_MEM_Reg;
            rd_MEM_to_WB_Reg <= rd_EX_to_MEM_Reg;
            load_flag_MEM_to_WB_Reg <= load_flag_MEM;
            load_flag_fp_MEM_to_WB_Reg <= load_fp_flag_MEM;
            fp_flag_MEM_to_WB_Reg <= fp_flag_MEM;
            mul_flag_MEM_to_WB_Reg <= mul_flag_MEM;
            DATA_MEM_WB <= i_Data_data;//肏你媽本來SRAM就有dealy

            WB_Address <= alu_out_EX_to_MEM_Reg[1:0];
        end
    end




////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                      Write Back  stage                                                                         
//                                                                                
////////////////////////////////////////////////////////////////////////////////////
logic [31:0] valid_Data_memory_data;
logic [31:0] valid_Data_memory_data_r;
logic [15:0] load_half_data;
logic [ 7:0] load_byte_data;

   assign load_half_data = (WB_Address[1])? valid_Data_memory_data_r[16+:16] : valid_Data_memory_data_r[0+:16];
   assign load_byte_data = (WB_Address == 2'b00)? valid_Data_memory_data_r[0+:8] :
                           (WB_Address == 2'b01)? valid_Data_memory_data_r[8+:8] :
                           (WB_Address == 2'b10)? valid_Data_memory_data_r[16+:8] :
                           (WB_Address == 2'b11)? valid_Data_memory_data_r[24+:8] : 8'b0;
    always_ff @( posedge clk or posedge rst ) begin
        if(rst) valid_Data_memory_data <= 32'b0;
        else if(waiting_DM_data_hit & I_Data_hit) valid_Data_memory_data <= i_Data_data;
    end
    
    always_ff @( posedge clk or posedge rst ) begin
        if(rst) valid_Data_memory_data_r <= 32'b0;
        else if(I_Instruc_data_hit) valid_Data_memory_data_r <= valid_Data_memory_data;
    end  

  assign lwdata_WB =    (funct3_MEM_to_WB_Reg[1])?  valid_Data_memory_data_r :
                        (funct3_MEM_to_WB_Reg[0])? (funct3_MEM_to_WB_Reg[2])? {16'b0,  load_half_data} : {{16{load_half_data[15]}}, load_half_data[15:0]} :
                        (funct3_MEM_to_WB_Reg[2])? {24'b0, load_byte_data[7:0]} : {{24{load_byte_data[7]}}, load_byte_data[7:0]};

  assign writedata_WB = (load_flag_MEM_to_WB_Reg)?  lwdata_WB :(mul_flag_MEM_to_WB_Reg)? mul_out_MEM_to_WB_Reg:write_data_MEM_to_WB_Reg;

  
  assign fp_writedata_WB = (load_flag_fp_MEM_to_WB_Reg)? valid_Data_memory_data_r :(fp_flag_MEM_to_WB_Reg)? fp_out_MEM_to_WB_Reg:32'd0;








////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                                  Forward                                                                                        
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    FORWARD_IP FORWARD(
        .i_rs1_EX(rs1_ID_to_EX_Reg),
        .i_rs2_EX(rs2_ID_to_EX_Reg),
        .i_write_fp_MEM(write_fp_EX_to_MEM_Reg),
        .i_write_fp_WB(write_fp_MEM_to_WB_Reg),
        .i_write_MEM(write_EX_to_MEM_Reg),
        .i_write_WB(write_MEM_to_WB_Reg),
        .i_rd_MEM(rd_EX_to_MEM_Reg),
        .i_rd_WB(rd_MEM_to_WB_Reg),
        .o_forward_sel_rs1(forward_sel_rs1_EX),
        .o_forward_sel_rs2(forward_sel_rs2_EX),
        .o_forward_sel_rs1_fp(forward_sel_rs1_fp_EX),
        .i_load_MEM(load_flag_MEM),//have critical path
        .i_load_fp_MEM(load_fp_flag_MEM),//have critical path
        .i_fp_flag_MEM(fp_flag_MEM),
        .i_mul_flag_MEM(mul_flag_MEM),
        .o_forward_sel_rs2_fp(forward_sel_rs2_fp_EX)
    );

    
////////////////////////////////////////////////////////////////////////////////////
//                                                                                
//                                  hazard detection                                                                                        
//                                                                                
////////////////////////////////////////////////////////////////////////////////////

    assign load = (mem_to_wb_sel_ID_to_EX_Reg == 3'b01);
    assign fp_load_fuck = (mem_to_wb_sel_ID_to_EX_Reg == 3'd6);
    assign fp_flag = (mem_to_wb_sel_ID_to_EX_Reg == 3'd5);
    assign mul_flag = (mem_to_wb_sel_ID_to_EX_Reg == 3'd4);
    always_comb begin
        if (load || fp_load_fuck || fp_flag || mul_flag) begin
                if ((Instruc_data_IF_to_ID_Reg[19:15] == rd_ID_to_EX_Reg) || (Instruc_data_IF_to_ID_Reg[24:20] == rd_ID_to_EX_Reg)) begin
                    stall = 1'b1;
                end 
                else begin
                    stall = 1'b0;
                end
        end
        else begin
                stall = 1'b0;
        end
    end

/// debug





endmodule
