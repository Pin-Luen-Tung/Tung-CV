
`include "../src/MEM2048X24.v"

module BS(
    input clk1,
    input clk2,
    input rst_n,
    input [23:0] DPi,
    input [2:0] Sync_720p,
    input [2:0] Sync_1080p,
    output [26:0] DPo
);

wire vsync_720P;
wire hsync_720P;
wire den_720P;
reg den_720P_flag;
reg den_720P_r;
reg den_720P_r_r;
reg [10:0] h_cnt_720P;
reg [10:0] line_0_index;
reg [10:0] line_1_index;
reg [10:0] line_2_index;
reg [9:0] v_cnt_720P;
reg [1:0] line_buffer_read_select;
wire [49:0] sync_720P_data;
reg [49:0] sync_720P_data_d1T;
reg [49:0] sync_720P_data_d2T;
reg [49:0] sync_720P_data_d3T;
reg [23:0] shift_reg_line_0 [0:1];
wire [23:0] line_0_out;
reg [23:0] shift_reg_line_1 [0:1];
wire [23:0] line_1_out;
reg [23:0] shift_reg_line_2 [0:1];
wire [23:0] line_2_out;
wire vsync_1080P;
reg vsync_1080P_r;
wire hsync_1080P;
reg hsync_1080P_r;
wire den_1080P;
reg den_1080P_r;
reg den_1080P_r_r;
reg den_1080P_flag;

reg [33:0] h_cnt_1080P;
reg [33:0] h_cnt_1080P_r;
reg [33:0] h_cnt_1080P_r_r;
reg [33:0] h_cnt_1080P_plus_Sx;
reg [33:0] h_cnt_1080P_plus_Sx_r;
reg [33:0] v_cnt_1080P;
reg [33:0] v_cnt_1080P_r;
reg [33:0] v_cnt_1080P_r_r;
reg [33:0] v_cnt_1080P_r_r_r;
reg [33:0] v_cnt_1080P_plus_Sy;
reg [33:0] v_cnt_1080P_plus_Sy_r;
reg [1:0] v_select;
reg [1:0] v_select_r;
reg [1:0] v_select_r_r;
reg [1:0] v_select_r_r_r;
wire [33:0] Sx;
wire [33:0] Sy;
wire [21:0] X;
reg [21:0] X_r;
reg [21:0] X_r_r;
reg [21:0] X_r_r_r;
wire [21:0] Y;
reg [21:0] Y_r;
reg [21:0] Y_r_r;
reg [21:0] Y_r_r_r;
wire [22:0] one_minus_X;
reg [22:0] one_minus_X_r;
reg [22:0] one_minus_X_r_r;
reg [22:0] one_minus_X_r_r_r;
wire [22:0] one_minus_Y;
reg [22:0] one_minus_Y_r;
reg [22:0] one_minus_Y_r_r;
reg [22:0] one_minus_Y_r_r_r;
reg [23:0] pixel_1;
reg [23:0] pixel_2;
reg [23:0] pixel_3;
reg [23:0] pixel_4;
assign Sx = {12'd0,22'b1010_1010_1001_1111_0100_10};// 1279/1919
assign Sy = {12'd0,22'b1010_1010_1001_0110_0110_11};// 719/1079

assign vsync_720P = Sync_720p[2];
assign hsync_720P = Sync_720p[1];
assign den_720P = Sync_720p[0];

assign vsync_1080P = Sync_1080p[2];
assign hsync_1080P = Sync_1080p[1];
assign den_1080P = Sync_1080p[0];
reg [2:0] Sync_1080p_r;
reg [2:0] Sync_1080p_r_r;
reg [2:0] Sync_1080p_r_r_r;


assign sync_720P_data = {line_buffer_read_select,v_cnt_720P,h_cnt_720P,vsync_720P,hsync_720P,den_720P,DPi};


always @(posedge clk1 or negedge rst_n) begin
    if(~rst_n) begin
        h_cnt_720P <= 11'd0;
    end
    else if(hsync_720P)begin
        h_cnt_720P <= 11'd0;
    end
    else if(den_720P) begin
        h_cnt_720P <= h_cnt_720P + 11'd1;
    end
end

always @(posedge clk1 or negedge rst_n) begin
    if(~rst_n) begin
        den_720P_r <= 1'b0;
    end
    else begin
        den_720P_r <= den_720P;
    end
end 

always @(posedge clk1 or negedge rst_n) begin
    if(~rst_n) begin
        den_720P_r_r <= 1'b0;
    end
    else begin
        den_720P_r_r <= den_720P_r;
    end
end 

always @(posedge clk1 or negedge rst_n) begin
    if(~rst_n) begin
        v_cnt_720P <= 10'd0;
        line_buffer_read_select <= 2'd0;
    end
    else if(den_720P_flag) begin
        if(~den_720P&den_720P_r) begin
            v_cnt_720P <= (v_cnt_720P + 10'd1);
            line_buffer_read_select <= (line_buffer_read_select==2'd2)? 2'd0:line_buffer_read_select + 2'd1;
        end
    end
    else if(vsync_720P) begin
        v_cnt_720P <= 10'd0;
        line_buffer_read_select <= 2'd0;
    end
end


always @(posedge clk1 or negedge rst_n) begin
    if(~rst_n) begin
        den_720P_flag <= 1'b0;
    end
    else if(vsync_720P) begin
        den_720P_flag <= 1'b0;
    end
    else if(den_720P) begin
        den_720P_flag <= 1'b1;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        sync_720P_data_d1T <= 48'd0;
    end
    else if(sync_720P_data[24])begin
        sync_720P_data_d1T <= sync_720P_data;
    end
    else begin
        sync_720P_data_d1T <= 48'd0;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        sync_720P_data_d2T <= 48'd0;
    end
    else if(sync_720P_data_d1T[24])begin
        sync_720P_data_d2T <= sync_720P_data_d1T;
    end
    else begin
        sync_720P_data_d2T <= 48'd0;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        sync_720P_data_d3T <= 48'd0;
    end
    else if(sync_720P_data_d2T[24])begin
        sync_720P_data_d3T <= sync_720P_data_d2T;
    end
    else begin
        sync_720P_data_d3T <= 48'd0;
    end
end

always @(*) begin
    line_0_index = (~hsync_1080P)? h_cnt_1080P[33:22]+11'd1:11'd0;
    line_1_index = (~hsync_1080P)? h_cnt_1080P[33:22]+11'd1:11'd0;
    line_2_index = (~hsync_1080P)? h_cnt_1080P[33:22]+11'd1:11'd0;
end


MEM2048X24 u_line_0 (
    .CK(clk2),
    .CS(1'b1),
    .WEB((sync_720P_data_d3T[49:48]==2'd0)&&sync_720P_data_d3T[24]),
    .RE(1'b1),
    .R_ADDR(line_0_index),
    .W_ADDR(sync_720P_data_d3T[37:27]),
    .D_IN(sync_720P_data_d3T[23:0]),
    .D_OUT(line_0_out)
);

MEM2048X24 u_line_1 (
    .CK(clk2),
    .CS(1'b1),
    .WEB((sync_720P_data_d3T[49:48]==2'd1)&&sync_720P_data_d3T[24]),
    .RE(1'b1),
    .R_ADDR(line_1_index),
    .W_ADDR(sync_720P_data_d3T[37:27]),
    .D_IN(sync_720P_data_d3T[23:0]),
    .D_OUT(line_1_out)
);

MEM2048X24 u_line_2 (
    .CK(clk2),
    .CS(1'b1),
    .WEB((sync_720P_data_d3T[49:48]==2'd2)&&sync_720P_data_d3T[24]),
    .RE(1'b1),
    .R_ADDR(line_2_index),
    .W_ADDR(sync_720P_data_d3T[37:27]),
    .D_IN(sync_720P_data_d3T[23:0]),
    .D_OUT(line_2_out)
);

wire shift_line0_flag;
wire shift_line1_flag;
wire shift_line2_flag;
assign shift_line0_flag = (h_cnt_1080P_r_r[33:22]!=h_cnt_1080P_plus_Sx_r[33:22]);
assign shift_line1_flag = (h_cnt_1080P_r_r[33:22]!=h_cnt_1080P_plus_Sx_r[33:22]);
assign shift_line2_flag = (h_cnt_1080P_r_r[33:22]!=h_cnt_1080P_plus_Sx_r[33:22]);

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_0[0] <= 24'd0;
        shift_reg_line_0[1] <= 24'd0;
    end
    else if(hsync_1080P) begin
        shift_reg_line_0[0] <= 24'd0;
        shift_reg_line_0[1] <= line_0_out;
    end
    else if(h_cnt_1080P_r_r[33:0]==33'd0&&den_1080P_r_r) begin
        shift_reg_line_0[1] <= line_0_out;
        shift_reg_line_0[0] <= shift_reg_line_0[1];
    end
    else if(shift_line0_flag) begin
        shift_reg_line_0[1] <= line_0_out;
        shift_reg_line_0[0] <= shift_reg_line_0[1];
    end
end


always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_1[0] <= 24'd0;
        shift_reg_line_1[1] <= 24'd0;
    end
    else if(hsync_1080P) begin
        shift_reg_line_1[0] <= 24'd0;
        shift_reg_line_1[1] <= line_1_out;
    end
    else if(h_cnt_1080P_r_r[33:0]==33'd0&&den_1080P_r_r) begin
        shift_reg_line_1[1] <= line_1_out;
        shift_reg_line_1[0] <= shift_reg_line_1[1];
    end
    else if(shift_line1_flag) begin
        shift_reg_line_1[1] <= line_1_out;
        shift_reg_line_1[0] <= shift_reg_line_1[1];
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        shift_reg_line_2[0] <= 24'd0;
        shift_reg_line_2[1] <= 24'd0;
    end
    else if(hsync_1080P) begin
        shift_reg_line_2[0] <= 24'd0;
        shift_reg_line_2[1] <= line_2_out;
    end
    else if(h_cnt_1080P_r_r[33:0]==33'd0&&den_1080P_r_r) begin
        shift_reg_line_2[1] <= line_2_out;
        shift_reg_line_2[0] <= shift_reg_line_2[1];
    end
    else if(shift_line1_flag) begin
        shift_reg_line_2[1] <= line_2_out;
        shift_reg_line_2[0] <= shift_reg_line_2[1];
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        h_cnt_1080P <= 34'd0;
    end
    else if(hsync_1080P)begin
        h_cnt_1080P <= 34'd0;
    end
    else if(den_1080P) begin
        h_cnt_1080P <= h_cnt_1080P + Sx;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        den_1080P_flag <= 1'b0;
    end
    else if(vsync_1080P) begin
        den_1080P_flag <= 1'b0;
    end
    else if(den_1080P) begin
        den_1080P_flag <= 1'b1;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        den_1080P_r <= 1'b0;
        den_1080P_r_r <= 1'b0;
    end
    else begin
        den_1080P_r <= den_1080P;
        den_1080P_r_r <= den_1080P_r;
    end
end

wire v_change;
assign v_change = v_cnt_1080P_r_r[33:22]!=v_cnt_1080P_plus_Sy_r[33:22];

always @(posedge clk2 or negedge rst_n) begin
    if(~rst_n) begin
        v_cnt_1080P <= 34'd0;
        v_select <= 2'd0;
    end
    else if(den_1080P_flag) begin
        if(hsync_1080P&~hsync_1080P_r) begin
            v_cnt_1080P <= (v_cnt_1080P + Sy);
            if(v_change) begin
                v_select <= (v_select==2'd2)? 2'd0:v_select+2'd1;
            end
        end
    end
    else if(vsync_1080P) begin
        v_cnt_1080P <= 34'd0;
        v_select <= 2'd0;
    end
end

always @(posedge clk2 ) begin
    h_cnt_1080P_plus_Sx <= h_cnt_1080P + Sx;
    v_cnt_1080P_plus_Sy <= v_cnt_1080P + Sy;
    h_cnt_1080P_r <= h_cnt_1080P;
    h_cnt_1080P_r_r <= h_cnt_1080P_r;
    h_cnt_1080P_plus_Sx_r <= h_cnt_1080P_plus_Sx;
    v_cnt_1080P_plus_Sy_r <= v_cnt_1080P_plus_Sy;
end

assign X = h_cnt_1080P[21:0];
assign one_minus_X = {1'b1,22'd0}-{1'b0,X};
assign Y = v_cnt_1080P[21:0];
assign one_minus_Y = {1'b1,22'd0}-{1'b0,Y};

    reg [23:0] bilinear_interpolation;
    wire [22:0] X_in;
    wire [22:0] one_minus_X_in;
    wire [22:0] Y_in;
    wire [22:0] one_minus_Y_in;
    reg [55:0] sum_R_y0;
    reg [7:0] sat_R_y0;
    reg [55:0] sum_G_y0;
    reg [7:0] sat_G_y0;
    reg [55:0] sum_B_y0;
    reg [7:0] sat_B_y0;
    reg [55:0] sum_R_y1;
    reg [7:0] sat_R_y1;
    reg [55:0] sum_G_y1;
    reg [7:0] sat_G_y1;
    reg [55:0] sum_B_y1;
    reg [7:0] sat_B_y1;
    assign X_in = {1'b0,X_r_r_r};
    assign Y_in = {1'b0,Y_r_r_r};
    assign one_minus_X_in = one_minus_X_r_r_r;
    assign one_minus_Y_in = one_minus_Y_r_r_r;


    always @(*) begin
        sum_R_y0 = one_minus_X_in*one_minus_Y_in*pixel_1[23:16] + X_in*one_minus_Y_in*pixel_2[23:16] + one_minus_X_in*Y_in*pixel_3[23:16] + X_in*Y_in*pixel_4[23:16];
        sum_G_y0 = one_minus_X_in*one_minus_Y_in*pixel_1[15:8] + X_in*one_minus_Y_in*pixel_2[15:8] + one_minus_X_in*Y_in*pixel_3[15:8] + X_in*Y_in*pixel_4[15:8];
        sum_B_y0 = one_minus_X_in*one_minus_Y_in*pixel_1[7:0] + X_in*one_minus_Y_in*pixel_2[7:0] + one_minus_X_in*Y_in*pixel_3[7:0] + X_in*Y_in*pixel_4[7:0];
        sat_R_y0 = (sum_R_y0[55:52]>0)? 8'd255:(sum_R_y0[43:33]>1000)? sum_R_y0[51:44]+8'd1:sum_R_y0[51:44];
        sat_G_y0 = (sum_G_y0[55:52]>0)? 8'd255:(sum_G_y0[43:33]>1000)? sum_G_y0[51:44]+8'd1:sum_G_y0[51:44];
        sat_B_y0 = (sum_B_y0[55:52]>0)? 8'd255:(sum_B_y0[43:33]>1000)? sum_B_y0[51:44]+8'd1:sum_B_y0[51:44];
        bilinear_interpolation = {sat_R_y0,sat_G_y0,sat_B_y0};
    end


always @(posedge clk2) begin
    case (v_select_r_r_r)
        2'd0:begin
            pixel_1 = (h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_0[1]:shift_reg_line_0[0];
        end 
        2'd1:begin
            pixel_1 = (h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_1[1]:shift_reg_line_1[0];
        end
        default:begin
            pixel_1 = (h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_2[1]:shift_reg_line_2[0];
        end
    endcase
end

always @(posedge clk2) begin
    case (v_select_r_r_r)
        2'd0:begin
            pixel_2 = shift_reg_line_0[1];
        end 
        2'd1:begin
            pixel_2 = shift_reg_line_1[1];
        end
        default:begin
            pixel_2 = shift_reg_line_2[1];
        end
    endcase
end

always @(posedge clk2) begin
    case (v_select_r_r_r)
        2'd0:begin
            pixel_3 = (h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_1[1]:shift_reg_line_1[0];
        end 
        2'd1:begin
            pixel_3 = (h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_2[1]:shift_reg_line_2[0];
        end
        default:begin
            pixel_3 =(h_cnt_1080P_r_r[33:0]==34'd0)? shift_reg_line_0[1]:shift_reg_line_0[0];
        end
    endcase
end

always @(posedge clk2) begin
    case (v_select_r_r_r)
        2'd0:begin
            pixel_4 = shift_reg_line_1[1];
        end 
        2'd1:begin
            pixel_4 = shift_reg_line_2[1];
        end
        default:begin
            pixel_4 = shift_reg_line_0[1];
        end
    endcase
end



assign DPo = {Sync_1080p_r_r_r,bilinear_interpolation};

always @(posedge clk2 ) begin
    Sync_1080p_r <= Sync_1080p;
    Sync_1080p_r_r <= Sync_1080p_r;
    Sync_1080p_r_r_r <= Sync_1080p_r_r;
    X_r <= X;
    Y_r <= Y;
    one_minus_X_r <= one_minus_X;
    one_minus_Y_r <= one_minus_Y;
    X_r_r <= X_r;
    Y_r_r <= Y_r;
    one_minus_X_r_r <= one_minus_X_r;
    one_minus_Y_r_r <= one_minus_Y_r;
    X_r_r_r <= X_r_r;
    Y_r_r_r <= Y_r_r;
    one_minus_X_r_r_r <= one_minus_X_r_r;
    one_minus_Y_r_r_r <= one_minus_Y_r_r;
    v_select_r <= v_select;
    v_select_r_r <= v_select_r;
    v_select_r_r_r <= v_select_r_r;
    v_cnt_1080P_r <= v_cnt_1080P;
    v_cnt_1080P_r_r <= v_cnt_1080P_r;
    v_cnt_1080P_r_r_r <= v_cnt_1080P_r_r;
    hsync_1080P_r <= hsync_1080P;
end


endmodule