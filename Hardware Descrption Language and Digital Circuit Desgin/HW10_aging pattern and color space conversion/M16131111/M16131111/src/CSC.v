`timescale 1ns/10ps
module CSC(
    input clk,
    input rst_n,
    input [1:0] Mode,
    input [26:0] DPi,
    output reg [26:0] DPo
);

wire [7:0] Y_in,U_in,V_in;

wire signed [19:0] V2R_mul_result;
wire signed [19:0] V2G_mul_result;
wire signed [19:0] U2B_mul_result;
wire signed [19:0] U2G_mul_result;

wire signed [21:0] R_ini,G_ini,B_ini;
wire signed [7:0]  R_out,G_out,B_out;

wire signed [8:0] v_minus_128;
wire signed [8:0] u_minus_128;

wire signed [10:0] V2R = 11'b00100100100;
wire signed [10:0] V2G = 11'b11101101011;
wire signed [10:0] U2G = 11'b11110011011;
wire signed [10:0] U2B = 11'b01000001000;

wire signed [9:0] R2Y = 10'b0001001101;  //  0.299  → round(0.299*256)=   77  →  10'h04D  (0001001101₂)
wire signed [9:0] G2Y = 10'b0010010110;  //  0.587  → round(0.587*256)=  150  →  10'h096  (0010010110₂)
wire signed [9:0] B2Y = 10'b0000011101;  //  0.114  → round(0.114*256)=   29  →  10'h01D  (0000011101₂)

wire signed [9:0] R2U = 10'b1111010101;  // -0.169  → round(-0.169*256)=  -43  →  10'h3D5  (1111010101₂)
wire signed [9:0] G2U = 10'b1110101011;  // -0.331  → round(-0.331*256)=  -85  →  10'h3AB  (1110101011₂)
wire signed [9:0] B2U = 10'b0010000000;  //  0.500  → round(0.500*256)=  128  →  10'h080  (0010000000₂)

wire signed [9:0] R2V = 10'b0010000000;  //  0.500  → round(0.500*256)=  128  →  10'h080  (0010000000₂)
wire signed [9:0] G2V = 10'b1110010101;  // -0.419  → round(-0.419*256)= -107  →  10'h395  (1110010101₂)
wire signed [9:0] B2V = 10'b1111101011;  // -0.081  → round(-0.081*256)=  -21  →  10'h3EB  (1111101011₂)

wire [7:0] R_in,G_in,B_in;
wire [7:0] Y,U,V;
reg  [7:0] Y_r,U_r,V_r;
wire vsync;
wire hsync;
wire den;

reg vsync_r;
reg hsync_r;
reg den_r;

always @(posedge clk ) begin
    vsync_r <= vsync;
    hsync_r <= hsync;
    den_r <= den;
end

wire signed [18:0] R2Y_mul_result;
wire signed [18:0] G2Y_mul_result;
wire signed [18:0] B2Y_mul_result;


wire  signed [20:0] Y_ini;

wire signed [18:0] R2U_mul_result;
wire signed [18:0] G2U_mul_result;
wire signed [18:0] B2U_mul_result;

wire  signed [20:0] U_ini;
wire  signed [20:0] U_fuck;

wire signed [18:0] R2V_mul_result;
wire signed [18:0] G2V_mul_result;
wire signed [18:0] B2V_mul_result;

wire  signed [20:0] V_ini;
wire  signed [20:0] V_fuck;

assign vsync = DPi[26];
assign hsync = DPi[25];
assign den = DPi[24];
assign R_in = DPi[23:16];
assign G_in = DPi[15:8];
assign B_in = DPi[7:0];



assign R2Y_mul_result = {1'b0,R_in} * R2Y;
assign G2Y_mul_result = {1'b0,G_in} * G2Y;
assign B2Y_mul_result = {1'b0,B_in} * B2Y;

assign R2U_mul_result = $signed({1'b0,R_in}) * R2U;
assign G2U_mul_result = $signed({1'b0,G_in}) * G2U;
assign B2U_mul_result = {1'b0,B_in} * B2U;

assign R2V_mul_result = {1'b0,R_in} * R2V;
assign G2V_mul_result = $signed({1'b0,G_in}) * G2V;
assign B2V_mul_result = $signed({1'b0,B_in}) * B2V;

assign Y_ini = R2Y_mul_result + G2Y_mul_result + B2Y_mul_result;
assign U_ini = R2U_mul_result + G2U_mul_result + B2U_mul_result;
assign U_fuck = U_ini + {12'd128,8'd0};
assign V_ini = R2V_mul_result + G2V_mul_result + B2V_mul_result;
assign V_fuck = V_ini + {12'd128,8'd0};

assign Y = saturation(Y_ini);
assign U = saturation(U_fuck);
assign V = saturation(V_fuck);

assign Y_in = (Mode==2'b10)? Y_r:DPi[23:16];
assign U_in = (Mode==2'b10)? U_r:DPi[15:8];
assign V_in = (Mode==2'b10)? V_r:DPi[7:0];

always @(posedge clk) begin
    Y_r <= Y;
    U_r <= U;
    V_r <= V;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        DPo <= 27'd0;
    end
    else begin
        case (Mode)
            2'b00: begin
                DPo <= {vsync,hsync,den,Y,U,V};
            end 
            2'b01: begin
                DPo <= {vsync,hsync,den,R_out,G_out,B_out};
            end
            default: begin
                DPo <= {vsync_r,hsync_r,den_r,R_out,G_out,B_out};
            end
        endcase
    end
end

function  [7:0] saturation;
    input signed [20:0] val;
    begin
        if(val[20]) begin
            saturation = {8{1'b0}};
        end
        else if(val[20:8]>13'd254) begin
            saturation = {8{1'b1}};
        end 
        else if(val[7]) begin
            saturation = val[15:8] + 8'd1;
        end
        else begin
            saturation = val[15:8];
        end
    end
endfunction


assign v_minus_128 =  $signed({1'd0,V_in}) - $signed({1'd0,8'd128});
assign u_minus_128 =  $signed({1'd0,U_in}) - $signed({1'd0,8'd128});

assign V2G_mul_result = v_minus_128 * V2G;
assign V2R_mul_result = v_minus_128 * V2R;
assign U2G_mul_result = u_minus_128 * U2G;
assign U2B_mul_result = u_minus_128 * U2B;

assign R_ini = V2R_mul_result + $signed({1'd0,Y_in,8'd0});
assign G_ini = V2G_mul_result + $signed({1'd0,Y_in,8'd0}) + U2G_mul_result;
assign B_ini = U2B_mul_result + $signed({1'd0,Y_in,8'd0});

function  [7:0] saturation_RGB;
    input signed [21:0] val;
    begin
        if(val[21]) begin
            saturation_RGB = {8{1'b0}};
        end
        else if(val[21:8]>14'd254) begin
            saturation_RGB = {8{1'b1}};
        end 
        else if(val[7]) begin
            saturation_RGB = val[15:8] + 8'd1;
        end
        else begin
            saturation_RGB = val[15:8];
        end
    end
endfunction

assign R_out = saturation_RGB(R_ini);
assign G_out = saturation_RGB(G_ini);
assign B_out = saturation_RGB(B_ini);

endmodule