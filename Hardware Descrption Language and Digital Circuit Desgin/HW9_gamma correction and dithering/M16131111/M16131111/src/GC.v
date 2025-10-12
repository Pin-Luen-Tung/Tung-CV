`timescale 1ns/10ps
`include "../sim/SUMA180_256X10X1BM1.v"

module GC (
    input clk,
    input rst_n,
    input pass,
    input gamma_en,
    input [9:0] gamma_data,
    input [7:0] gamma_addr,
    input [26:0] DPi,
    output reg [32:0] DPo
);

reg [7:0] R_addres;
reg [7:0] G_addres;
reg [7:0] B_addres;

reg [9:0] R_out;
reg [9:0] G_out;
reg [9:0] B_out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        DPo <= 33'd0;
    end
    else begin
        if(pass) begin
            DPo <= {6'd0,DPi};
        end
        else begin
            DPo <= {DPi[26:24],R_out,G_out,B_out};
        end
    end
end

always @(*) begin
    if(gamma_en) begin
        R_addres = gamma_addr;
    end
    else begin
        R_addres = DPi[23:16];
    end
end

always @(*) begin
    if(gamma_en) begin
        G_addres = gamma_addr;
    end
    else begin
        G_addres = DPi[15:8];
    end
end

always @(*) begin
    if(gamma_en) begin
        B_addres = gamma_addr;
    end
    else begin
        B_addres = DPi[7:0];
    end
end

/********** SRAM **********/

SUMA180_256X10X1BM1 SRAM_R(
    .A0(R_addres[0]),
    .A1(R_addres[1]),
    .A2(R_addres[2]),
    .A3(R_addres[3]),
    .A4(R_addres[4]),
    .A5(R_addres[5]),
    .A6(R_addres[6]),
    .A7(R_addres[7]),
    .DO0(R_out[0]),
    .DO1(R_out[1]),
    .DO2(R_out[2]),
    .DO3(R_out[3]),
    .DO4(R_out[4]),
    .DO5(R_out[5]),
    .DO6(R_out[6]),
    .DO7(R_out[7]),
    .DO8(R_out[8]),
    .DO9(R_out[9]),
    .DI0(gamma_data[0]),
    .DI1(gamma_data[1]),
    .DI2(gamma_data[2]),
    .DI3(gamma_data[3]),
    .DI4(gamma_data[4]),
    .DI5(gamma_data[5]),
    .DI6(gamma_data[6]),
    .DI7(gamma_data[7]),
    .DI8(gamma_data[8]),
    .DI9(gamma_data[9]),
    .CK(clk),
    .WEB(~gamma_en),
    .OE(1'b1),
    .CS(1'b1)
);
SUMA180_256X10X1BM1 SRAM_G(
    .A0(G_addres[0]),
    .A1(G_addres[1]),
    .A2(G_addres[2]),
    .A3(G_addres[3]),
    .A4(G_addres[4]),
    .A5(G_addres[5]),
    .A6(G_addres[6]),
    .A7(G_addres[7]),
    .DO0(G_out[0]),
    .DO1(G_out[1]),
    .DO2(G_out[2]),
    .DO3(G_out[3]),
    .DO4(G_out[4]),
    .DO5(G_out[5]),
    .DO6(G_out[6]),
    .DO7(G_out[7]),
    .DO8(G_out[8]),
    .DO9(G_out[9]),
    .DI0(gamma_data[0]),
    .DI1(gamma_data[1]),
    .DI2(gamma_data[2]),
    .DI3(gamma_data[3]),
    .DI4(gamma_data[4]),
    .DI5(gamma_data[5]),
    .DI6(gamma_data[6]),
    .DI7(gamma_data[7]),
    .DI8(gamma_data[8]),
    .DI9(gamma_data[9]),
    .CK(clk),
    .WEB(~gamma_en),
    .OE(1'b1),
    .CS(1'b1)
);
SUMA180_256X10X1BM1 SRAM_B(
    .A0(B_addres[0]),
    .A1(B_addres[1]),
    .A2(B_addres[2]),
    .A3(B_addres[3]),
    .A4(B_addres[4]),
    .A5(B_addres[5]),
    .A6(B_addres[6]),
    .A7(B_addres[7]),
    .DO0(B_out[0]),
    .DO1(B_out[1]),
    .DO2(B_out[2]),
    .DO3(B_out[3]),
    .DO4(B_out[4]),
    .DO5(B_out[5]),
    .DO6(B_out[6]),
    .DO7(B_out[7]),
    .DO8(B_out[8]),
    .DO9(B_out[9]),
    .DI0(gamma_data[0]),
    .DI1(gamma_data[1]),
    .DI2(gamma_data[2]),
    .DI3(gamma_data[3]),
    .DI4(gamma_data[4]),
    .DI5(gamma_data[5]),
    .DI6(gamma_data[6]),
    .DI7(gamma_data[7]),
    .DI8(gamma_data[8]),
    .DI9(gamma_data[9]),
    .CK(clk),
    .WEB(~gamma_en),
    .OE(1'b1),
    .CS(1'b1)
);

/********** SRAM **********/

endmodule