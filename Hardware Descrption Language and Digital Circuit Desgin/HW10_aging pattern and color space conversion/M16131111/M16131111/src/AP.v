`timescale 1ns/10ps
module AP(
    input clk,
    input rst_n,
    input [11:0] Tp_H,
    input [10:0] Tp_V,
    input enable,
    input [3:0] Mode,
    input [26:0] DPi,
    output reg [26:0] DPo
);

wire [8:0] SEG_W;
reg [8:0] SEG_cnt;
assign SEG_W = (Tp_H >> 3) - 9'd1;
wire [7:0] SEG_16_W;
reg [7:0] SEG_16_cnt;
assign SEG_16_W = (Tp_H >> 4) - 8'd1;
localparam FRAME_W = 12'd5;
localparam block_size_h = 12'd40 - 12'd1;
reg [5:0] h_block_cnt;
localparam block_size_v = 11'd40 - 11'd1;
reg [5:0] v_block_cnt;
reg h_parity;
reg v_parity;
reg [2:0] bar_idx;
reg [3:0] seg_16_idx;

wire [7:0] R_in,G_in,B_in;
wire vsync;
wire hsync;
reg hsync_r;
wire den;

reg [7:0] R_pat,G_pat,B_pat;
reg [8:0] R_16,G_16,B_16;

reg [11:0] h;
reg [10:0] v;

reg den_flag;

reg [2:0] px5_cnt;
reg [7:0] gray_lvl;

assign vsync = DPi[26];
assign hsync = DPi[25];
assign den = DPi[24];
assign R_in = DPi[23:16];
assign G_in = DPi[15:8];
assign B_in = DPi[7:0];


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        bar_idx <= 3'd0;
        SEG_cnt <= 9'd0;
    end
    else begin
        if(hsync) begin
            SEG_cnt <= 9'd0;
            bar_idx <= 3'd0;
        end
        else if(den) begin
            if(SEG_cnt==SEG_W) begin
                if (bar_idx == 3'd7) begin
                    bar_idx <= 3'd7;  
                end
                else begin
                    bar_idx <= bar_idx + 3'd1;
                end
                SEG_cnt <= 9'd0;
            end
            else begin
                SEG_cnt <= SEG_cnt + 9'd1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_parity <= 1'b0;
        h_block_cnt <= 6'd0;
    end
    else begin
        if(hsync) begin
            h_parity <= 1'b0;
            h_block_cnt <= 6'd0;
        end
        else if(den) begin
            if(h_block_cnt == block_size_h) begin
                h_block_cnt <= 6'd0;
                h_parity <= h_parity + 1'b1;
            end
            else begin
                h_block_cnt <= h_block_cnt + 6'd1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        v_parity <= 1'b0;
        v_block_cnt <= 6'd0;
    end
    else begin
        if(den_flag) begin
            if(hsync&~hsync_r) begin
                if(v_block_cnt == block_size_v) begin
                    v_block_cnt <= 6'd0;
                    v_parity <= v_parity + 1'b1;
                end
                else begin
                    v_block_cnt <= v_block_cnt + 6'd1;
                end
            end
        end
        else begin
            v_block_cnt <= 6'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            SEG_16_cnt  <= 8'd0;
            seg_16_idx  <= 4'd0;
        end
        else if (hsync) begin
            SEG_16_cnt <= 8'd0;
            seg_16_idx <= 4'd0;
        end
        else if (den) begin
            if (SEG_16_cnt == SEG_16_W) begin
                SEG_16_cnt  <= 8'd0;
                if (seg_16_idx == 4'd15) begin
                    seg_16_idx <= 4'd15;  
                end
                else begin
                    seg_16_idx <= seg_16_idx + 4'd1;
                end
            end
            else begin
                SEG_16_cnt <= SEG_16_cnt + 8'd1;
            end
        end
    end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h <= 12'd0;
    end
    else begin
        if(hsync) begin
            h <= 12'd0;
        end
        else if(den)begin
            h <= h + 12'd1;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        den_flag <= 1'b0;
    end
    else if(vsync) begin
        den_flag <= 1'b0;
    end
    else if(den) begin
        den_flag <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        v <= 11'd0;
    end
    else begin
        if(den_flag) begin
            if(hsync&~hsync_r) begin
                v <= v + 11'd1;
            end
        end
        else begin
            v <= 11'd0;
        end
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

always @(*) begin
    if(enable) begin
        case (Mode)
            4'd0 :begin
                {R_pat,G_pat,B_pat} = {gray_lvl, gray_lvl, gray_lvl};
            end 
            4'd1: begin
                 case (bar_idx)
                    3'd0: {R_pat,G_pat,B_pat} = 24'hFFFFFF; 
                    3'd1: {R_pat,G_pat,B_pat} = 24'h80FFFF; 
                    3'd2: {R_pat,G_pat,B_pat} = 24'hFFFF00; 
                    3'd3: {R_pat,G_pat,B_pat} = 24'h00FF00; 
                    3'd4: {R_pat,G_pat,B_pat} = 24'h800080; 
                    3'd5: {R_pat,G_pat,B_pat} = 24'h000080; 
                    3'd6: {R_pat,G_pat,B_pat} = 24'hFF0000; 
                    3'd7: {R_pat,G_pat,B_pat} = 24'h000000;
                endcase
            end
            4'd2: begin
                {R_pat,G_pat,B_pat} = 24'h000000;
            end
            4'd3: begin
                {R_pat,G_pat,B_pat} = 24'hFF0000;
            end
            4'd4: begin
                {R_pat,G_pat,B_pat} = 24'h00FF00;
            end
            4'd5: begin
                {R_pat,G_pat,B_pat} = 24'h0000FF;
            end
            4'd6: begin
                if (h < FRAME_W || h >= (Tp_H - FRAME_W) ||v < FRAME_W || v >= (Tp_V - FRAME_W)) begin
                    {R_pat,G_pat,B_pat} = 24'h000000;
                end
                else begin
                    {R_pat,G_pat,B_pat} = 24'hFFFFFF;
                end
            end
            4'd7: begin
                case ({v_parity,h_parity})
                    2'b00: begin
                        {R_pat,G_pat,B_pat} = 24'hFFFFFF;
                    end 
                    2'b01: begin
                        {R_pat,G_pat,B_pat} = 24'h000000;
                    end
                    2'b10: begin
                        {R_pat,G_pat,B_pat} = 24'h000000;
                    end
                    2'b11: begin
                        {R_pat,G_pat,B_pat} = 24'hFFFFFF;
                    end
                endcase
            end
            4'd8: begin
                {R_pat,G_pat,B_pat} = {saturation(R_16),saturation(G_16),saturation(B_16)};
            end
            4'd9: begin
                {R_pat,G_pat,B_pat} = {saturation(R_16),8'd0,8'd0};
            end
            4'd10: begin
                {R_pat,G_pat,B_pat} = {8'd0,saturation(G_16),8'd0};
            end
            4'd11: begin
                {R_pat,G_pat,B_pat} = {8'd0,8'd0,saturation(B_16)};
            end
            4'd12: begin
                {R_pat,G_pat,B_pat} = h[0] ? 24'hFFFFFF : 24'h000000;
             end
            4'd13: begin
                {R_pat,G_pat,B_pat} = h[1] ? 24'hFFFFFF : 24'h000000;
            end
            4'd14: begin
                {R_pat,G_pat,B_pat} = h[2] ? 24'hFFFFFF : 24'h000000;
            end
            4'd15: begin
                {R_pat,G_pat,B_pat} = (h[0]^v[0])? 24'hFFFFFF : 24'h000000;
            end
            default: begin
                {R_pat,G_pat,B_pat} = {R_in,G_in,B_in};
            end
        endcase
    end
    else begin
        R_pat = R_in;
        G_pat = G_in;
        B_pat = B_in;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        px5_cnt <= 3'd0;
        gray_lvl <= 8'd0;
    end
    else if (hsync) begin
        px5_cnt <= 3'd0;
        gray_lvl <= 8'd0;
    end
    else if(den) begin
        if(px5_cnt == 3'd4) begin
            px5_cnt <= 3'd0;
            gray_lvl <= (gray_lvl < 8'd254)? gray_lvl + 8'd2:gray_lvl;
        end
        else begin
            px5_cnt <= px5_cnt + 3'd1;
        end
    end
end

assign R_16 = (seg_16_idx << 4) + seg_16_idx;
assign G_16 = (seg_16_idx << 4) + seg_16_idx;
assign B_16 = (seg_16_idx << 4) + seg_16_idx;

function  [7:0] saturation;
    input signed [8:0] val;
    begin
        if(val > 9'd254) begin
            saturation = {8{1'b1}};
        end
        else begin
            saturation = val[7:0];
        end
    end
endfunction

always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            DPo <= 27'd0;
        end
        else begin
            DPo[26]     <= vsync;
            DPo[25]     <= hsync;
            DPo[24]     <= den;
            DPo[23:16]  <= R_pat;
            DPo[15:8]   <= G_pat;
            DPo[7:0]    <= B_pat;
        end
    end


endmodule