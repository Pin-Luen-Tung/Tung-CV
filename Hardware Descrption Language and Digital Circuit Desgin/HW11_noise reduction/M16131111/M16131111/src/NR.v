
`include "../src/MEM1024X24.v"


module NR(
    input clk,
    input rst_n,
    input [26:0] DPi,
    input A_M,
    output reg [23:0] DPo
);

reg den_flag;
reg cnt;
reg [9:0] h_cnt;
reg [9:0] h_cnt_r;
reg [9:0] h_cnt_r_r;
reg [8:0] v_cnt;
reg [23:0] shift_reg_line_0 [0:2];
wire [23:0] line_0_in;
reg [23:0] shift_reg_line_1 [0:2];
wire [23:0] line_1_in;
reg [23:0] shift_reg_line_2 [0:2];
wire [23:0] line_2_in;

reg [23:0] k_0;
reg [23:0] k_1;
reg [23:0] k_2;
reg [23:0] k_3;
reg [23:0] k_4;
reg [23:0] k_5;
reg [23:0] k_6;
reg [23:0] k_7;
reg [23:0] k_8;


wire vsync;
wire hsync;
reg hsync_r;
wire den_fuck;
reg den;
reg den_r;
reg den_r_r;
reg [9:0] hsync_cnt;
reg [23:0] buffer_in;



always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        den <= 1'b0;
    end
    else if(hsync_cnt>10'd101&&hsync_cnt<10'd742) begin
        den <= 1'b1;
    end
    else begin
        den <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hsync_cnt <= 10'd0;
    end
    else if(~hsync_r&hsync)begin
        hsync_cnt <= 10'd0;
    end
    else begin
        hsync_cnt <= hsync_cnt + 10'd1;
    end
end

assign vsync = DPi[26];
assign hsync = DPi[25];
assign den_fuck = DPi[24];

function [7:0] mean_filter;
    input [7:0] k0;
    input [7:0] k1;
    input [7:0] k2;
    input [7:0] k3;
    input [7:0] k4;
    input [7:0] k5;
    input [7:0] k6;
    input [7:0] k7;
    input [7:0] k8;
    begin
        mean_filter = (k0 + k1 + k2 + k3 + k4 + k5 + k6 + k7 + k8)*3641 >> 15;
    end
endfunction


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        den_r <= 1'b0;
    end
    else begin
        den_r <= den;
    end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        den_r_r <= 1'b0;
    end
    else begin
        den_r_r <= den_r;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        den_flag <= 1'b0;
    end
    else if(vsync) begin
        den_flag <= 1'b0;
    end
    else if(den_fuck) begin
        den_flag <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        v_cnt <= 9'd0;
    end
    else if(den_flag) begin
        if(~den&den_r) begin
            v_cnt <= (v_cnt + 9'd1);
        end
    end
    else if(vsync) begin
        v_cnt <= 9'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cnt <= 1'd0;
    end
    else if(vsync) begin
        cnt <= 1'd0;
    end
    else if(~hsync&hsync_r) begin
        cnt <= cnt + 1'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_cnt <= 10'd0;
    end
    else if(hsync)begin
        h_cnt <= 10'd0;
    end
    else if(den) begin
        h_cnt <= h_cnt + 10'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hsync_r <= 1'b0;
    end
    else begin
        hsync_r <= hsync;
    end
end

wire [9:0] line_0_index;
wire [9:0] line_1_index;

assign line_0_index = (den)? h_cnt+10'd1:10'd0; 
assign line_1_index = (den)? h_cnt+10'd1:10'd0; 

MEM1024X24 u_line_0 (
    .CK(clk),
    .CS(1'b1),
    .WEB((cnt==1'd0)&den_r_r),
    .RE(1'b1),
    .R_ADDR(line_0_index),
    .W_ADDR(h_cnt_r_r),
    .D_IN(buffer_in),
    .D_OUT(line_0_in)
);

MEM1024X24 u_line_1 (
    .CK(clk),
    .CS(1'b1),
    .WEB((cnt==1'd1)&den_r_r),
    .RE(1'b1),
    .R_ADDR(line_1_index),
    .W_ADDR(h_cnt_r_r),
    .D_IN(buffer_in),
    .D_OUT(line_1_in)
);

//line 0 kernal

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_0[0] <= 24'd0;
        shift_reg_line_0[1] <= 24'd0;
        shift_reg_line_0[2] <= 24'd0;
    end
    else if(hsync) begin
        shift_reg_line_0[0] <= 24'd0;
        shift_reg_line_0[1] <= 24'd0;
        shift_reg_line_0[2] <= 24'd0;
    end
    else if(h_cnt==10'd0) begin
        shift_reg_line_0[1] <= line_0_in;
    end
    else if(h_cnt==10'd1) begin
        shift_reg_line_0[2] <= line_0_in;
    end
    else begin
        shift_reg_line_0[2] <= line_0_in;
        shift_reg_line_0[1] <= shift_reg_line_0[2];
        shift_reg_line_0[0] <= shift_reg_line_0[1];
    end
end

//line 1 kernal

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_1[0] <= 24'd0;
        shift_reg_line_1[1] <= 24'd0;
        shift_reg_line_1[2] <= 24'd0;
    end
    else if(hsync) begin
        shift_reg_line_1[0] <= 24'd0;
        shift_reg_line_1[1] <= 24'd0;
        shift_reg_line_1[2] <= 24'd0;
    end
    else if(h_cnt==10'd0) begin
        shift_reg_line_1[1] <= line_1_in;
    end
    else if(h_cnt==10'd1) begin
        shift_reg_line_1[2] <= line_1_in;
    end
    else begin
        shift_reg_line_1[2] <= line_1_in;
        shift_reg_line_1[1] <= shift_reg_line_1[2];
        shift_reg_line_1[0] <= shift_reg_line_1[1];
    end
end

assign line_2_in = DPi[23:0];

//line 2 kernal 

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_2[0] <= 24'd0;
        shift_reg_line_2[1] <= 24'd0;
        shift_reg_line_2[2] <= 24'd0;
    end
    else if(hsync) begin
        shift_reg_line_2[0] <= 24'd0;
        shift_reg_line_2[1] <= 24'd0;
        shift_reg_line_2[2] <= 24'd0;
    end
    else if(h_cnt==10'd0) begin
        shift_reg_line_2[1] <= line_2_in;
    end
    else if(h_cnt==10'd1) begin
        shift_reg_line_2[2] <= line_2_in;
    end
    else begin
        shift_reg_line_2[2] <= line_2_in;
        shift_reg_line_2[1] <= shift_reg_line_2[2];
        shift_reg_line_2[0] <= shift_reg_line_2[1];
    end
end

always @(*) begin
    if(v_cnt==9'd1) begin
        if(h_cnt==10'd1) begin
            k_0 = 24'd0;
            k_1 = 24'd0;
            k_2 = 24'd0;
            k_3 = 24'd0;
            k_4 = shift_reg_line_1[1];
            k_5 = shift_reg_line_1[2];
            k_6 = 24'd0;
            k_7 = shift_reg_line_2[1];
            k_8 = shift_reg_line_2[2];
        end
        else if(h_cnt==10'd481) begin
            k_0 = 24'd0;
            k_1 = 24'd0;
            k_2 = 24'd0;
            k_3 = shift_reg_line_1[0];
            k_4 = shift_reg_line_1[1];
            k_5 = 24'd0;
            k_6 = shift_reg_line_2[0];
            k_7 = shift_reg_line_2[1];
            k_8 = 24'd0;
        end
        else begin
            k_0 = 24'd0;
            k_1 = shift_reg_line_0[1];
            k_2 = shift_reg_line_0[2];
            k_3 = 24'd0;
            k_4 = shift_reg_line_1[1];
            k_5 = shift_reg_line_1[2];
            k_6 = 24'd0;
            k_7 = shift_reg_line_2[1];
            k_8 = shift_reg_line_2[2];
        end
    end
    else if(v_cnt==9'd480)begin
        if(h_cnt==10'd1) begin
            k_0 = 24'd0;
            k_1 = shift_reg_line_0[1];
            k_2 = shift_reg_line_0[2];
            k_4 = shift_reg_line_1[1];
            k_5 = shift_reg_line_1[2];
            k_7 = 24'd0;
            k_8 = 24'd0;
            k_3 = 24'd0;
            k_6 = 24'd0;
        end
        else if(h_cnt==10'd481) begin
            k_0 = shift_reg_line_0[0];
            k_1 = shift_reg_line_0[1];
            k_3 = shift_reg_line_1[0];
            k_4 = shift_reg_line_1[1];
            k_6 = 24'd0;
            k_7 = 24'd0;
            k_2 = 24'd0;
            k_5 = 24'd0;
            k_8 = 24'd0;
        end
        else begin
            k_0 = shift_reg_line_0[0];
            k_1 = shift_reg_line_0[1];
            k_2 = 24'd0;
            k_3 = shift_reg_line_1[0];
            k_4 = shift_reg_line_1[1];
            k_5 = 24'd0;
            k_6 = shift_reg_line_2[0];
            k_7 = shift_reg_line_2[1];
            k_8 = 24'd0;
        end
    end
    else begin
        k_0 = shift_reg_line_0[0];
        k_1 = shift_reg_line_0[1];
        k_2 = shift_reg_line_0[2];
        k_3 = shift_reg_line_1[0];
        k_4 = shift_reg_line_1[1];
        k_5 = shift_reg_line_1[2];
        k_6 = shift_reg_line_2[0];
        k_7 = shift_reg_line_2[1];
        k_8 = shift_reg_line_2[2];
    end
end

always @(*) begin
    if(~A_M) begin
        DPo = {mean_filter(k_0[23:16],k_1[23:16],k_2[23:16],k_3[23:16],k_4[23:16],k_5[23:16],k_6[23:16],k_7[23:16],k_8[23:16]),mean_filter(k_0[15:8],k_1[15:8],k_2[15:8],k_3[15:8],k_4[15:8],k_5[15:8],k_6[15:8],k_7[15:8],k_8[15:8]),mean_filter(k_0[7:0],k_1[7:0],k_2[7:0],k_3[7:0],k_4[7:0],k_5[7:0],k_6[7:0],k_7[7:0],k_8[7:0])};
    end
    else begin
        DPo = {median9(k_0[23:16],k_1[23:16],k_2[23:16],k_3[23:16],k_4[23:16],k_5[23:16],k_6[23:16],k_7[23:16],k_8[23:16]),median9(k_0[15:8],k_1[15:8],k_2[15:8],k_3[15:8],k_4[15:8],k_5[15:8],k_6[15:8],k_7[15:8],k_8[15:8]),median9(k_0[7:0],k_1[7:0],k_2[7:0],k_3[7:0],k_4[7:0],k_5[7:0],k_6[7:0],k_7[7:0],k_8[7:0])};
    end
end
reg [23:0] line_2_in_r;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        buffer_in <= 24'd0;
        line_2_in_r <= 24'd0;
    end
    else begin
        line_2_in_r <= line_2_in;
        buffer_in <= line_2_in_r;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_cnt_r <= 10'd0;
    end
    else begin
        h_cnt_r <= h_cnt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_cnt_r_r <= 10'd0;
    end
    else begin
        h_cnt_r_r <= h_cnt_r;
    end
end


function  [15:0] cmp;
        input [7:0] a, b;
        begin
            if (a < b) cmp = {a,b};
            else       cmp = {b,a};
        end
endfunction

function [7:0] median9;
    input [7:0] k0, k1, k2, k3, k4, k5, k6, k7, k8;

    // 暫存變數
    reg [7:0] v0, v1, v2, v3, v4, v5, v6, v7, v8;
    reg [15:0] t;       // cmp() 回傳的小大值

begin
    // 初值
    v0 = k0;  v1 = k1;  v2 = k2;  v3 = k3;  v4 = k4;
    v5 = k5;  v6 = k6;  v7 = k7;  v8 = k8;

    //--------------------------------------------------------
    // 28 組 compare-exchange：完全排序後取 v4 即中值
    //--------------------------------------------------------
    t = cmp(v0, v8);  v0 = t[15:8]; v8 = t[7:0];
    t = cmp(v2, v7);  v2 = t[15:8]; v7 = t[7:0];
    t = cmp(v3, v5);  v3 = t[15:8]; v5 = t[7:0];
    t = cmp(v4, v6);  v4 = t[15:8]; v6 = t[7:0];

    t = cmp(v0, v2);  v0 = t[15:8]; v2 = t[7:0];
    t = cmp(v1, v4);  v1 = t[15:8]; v4 = t[7:0];
    t = cmp(v5, v8);  v5 = t[15:8]; v8 = t[7:0];
    t = cmp(v7, v8);  v7 = t[15:8]; v8 = t[7:0];

    t = cmp(v0, v3);  v0 = t[15:8]; v3 = t[7:0];
    t = cmp(v2, v4);  v2 = t[15:8]; v4 = t[7:0];
    t = cmp(v5, v7);  v5 = t[15:8]; v7 = t[7:0];
    t = cmp(v6, v8);  v6 = t[15:8]; v8 = t[7:0];

    t = cmp(v0, v1);  v0 = t[15:8]; v1 = t[7:0];
    t = cmp(v3, v6);  v3 = t[15:8]; v6 = t[7:0];
    t = cmp(v7, v8);  v7 = t[15:8]; v8 = t[7:0];

    t = cmp(v1, v5);  v1 = t[15:8]; v5 = t[7:0];
    t = cmp(v2, v3);  v2 = t[15:8]; v3 = t[7:0];
    t = cmp(v4, v8);  v4 = t[15:8]; v8 = t[7:0];
    t = cmp(v6, v7);  v6 = t[15:8]; v7 = t[7:0];

    t = cmp(v1, v2);  v1 = t[15:8]; v2 = t[7:0];
    t = cmp(v3, v5);  v3 = t[15:8]; v5 = t[7:0];
    t = cmp(v4, v6);  v4 = t[15:8]; v6 = t[7:0];
    t = cmp(v7, v8);  v7 = t[15:8]; v8 = t[7:0];

    t = cmp(v2, v3);  v2 = t[15:8]; v3 = t[7:0];
    t = cmp(v4, v5);  v4 = t[15:8]; v5 = t[7:0];
    t = cmp(v6, v7);  v6 = t[15:8]; v7 = t[7:0];

    t = cmp(v3, v4);  v3 = t[15:8]; v4 = t[7:0];
    t = cmp(v5, v6);  v5 = t[15:8]; v6 = t[7:0];

    // 排序完成，v4 即第 5 小 → 9 點中值
    median9 = v4;
end
endfunction

endmodule