module fetch_fifo_checker #(
    parameter WIDTH = 64,         // 指令數據寬度
    parameter PC_WIDTH = 32,      // 程序計數器總寬度
    parameter CHECK_PC_WIDTH = 29, // 驗證的 PC 位寬
    parameter MAX_PENDING = 2    // 最大掛起數據量
) (
    input  logic                   clk_i,
    input  logic                   rst_i,
    input  logic                   push_w,
    input  logic [WIDTH-1:0]       data_in_i,
    input  logic [PC_WIDTH-1:0]    pc_in_i,
    input  logic                   pop_complete_w,
    input  logic [WIDTH/2-1:0]     data0_out_o, // 下半段指令數據
    input  logic [WIDTH/2-1:0]     data1_out_o, // 上半段指令數據
    input  logic [PC_WIDTH-1:0]    pc0_out_o
);

    // 截取需要驗證的 PC 高 29 位
    wire [CHECK_PC_WIDTH-1:0] pc_in_check = pc_in_i[PC_WIDTH-1:PC_WIDTH-CHECK_PC_WIDTH];
    wire [CHECK_PC_WIDTH-1:0] pc0_out_check = pc0_out_o[PC_WIDTH-1:PC_WIDTH-CHECK_PC_WIDTH];

    // 實例化 jasper_scoreboard_3
    jasper_scoreboard_3 #(
        .CHUNK_WIDTH(WIDTH + CHECK_PC_WIDTH), // 組合數據寬度 (完整指令 + 檢查用 PC)
        .IN_CHUNKS(1),                        // 單次輸入塊數量
        .OUT_CHUNKS(1),                       // 單次輸出塊數量
        .ORDERING(`JS3_IN_ORDER),             // 按順序驗證
        .MAX_PENDING(MAX_PENDING),            // 最大掛起數據量
        .SINGLE_CLOCK(1)                      // 單時鐘域設計
    ) u_scoreboard (
        .rstN(~rst_i),                        // Reset 信號
        .clk(clk_i),                          // Clock 信號
        .incoming_vld(push_w),                // 輸入有效信號
        .incoming_data({data_in_i, pc_in_check}),  // 輸入數據 (完整指令 + 截取後 PC)
        .outgoing_vld(pop_complete_w),        // 使用 pop_complete_w 作為輸出有效信號
        .outgoing_data({{data1_out_o, data0_out_o}, pc0_out_check}) // 拼接輸出指令和截取後 PC
    );

endmodule



//Bind the verification module to the DUV
bind fetch_fifo fetch_fifo_checker fetch_fifo_checker_i (.*);