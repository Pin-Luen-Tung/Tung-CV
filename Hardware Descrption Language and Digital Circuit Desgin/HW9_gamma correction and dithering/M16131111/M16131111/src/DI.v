`timescale 1ns/10ps

module DI
(
    input clk,
    input rst_n,
    input pass,
    input [32:0] DPi,
    output [26:0] DPo
);

reg [26:0] out;
reg h_sync_pos_edge;
reg h_sync_r;

reg v_parity;
reg h_parity;

reg [2:0] threshold_value;

wire [7:0] R_di;
wire [7:0] G_di;
wire [7:0] B_di;

assign DPo = out;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_sync_r <= 1'b0;
    end
    else begin
        h_sync_r <= DPi[31];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out <= 27'd0;
    end
    else if(pass) begin
        out <= DPi[26:0];
    end
    else begin
        out <= {DPi[32:30],R_di,G_di,B_di};
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        v_parity <= 1'b0;
    end
    else if(DPi[32]) begin
        v_parity <= 1'b0;
    end
    else if(DPi[31]&~h_sync_r)begin
        v_parity <= v_parity + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        h_parity <= 1'b0;
    end
    else if(DPi[31]) begin
        h_parity <= 1'b0;
    end
    else begin
        h_parity <= h_parity + 1'b1;
    end
end

always @(*) begin
    case ({v_parity,h_parity})
        2'b11: threshold_value = 2'd0;
        2'b10: threshold_value = 2'd2;
        2'b01: threshold_value = 2'd3;
        2'b00: threshold_value = 2'd1;
    endcase
end

function  [7:0] dithering;
    input [9:0] val;
    begin
        if(val[1:0]>threshold_value) begin
            if(val[9:2]==8'd255) begin
                dithering = 8'd255;
            end
            else begin
                dithering = val[9:2]+8'd1;
            end
        end 
        else begin
            dithering = val[9:2];
        end
    end
endfunction

assign R_di = dithering(DPi[29:20]);
assign G_di = dithering(DPi[19:10]);
assign B_di = dithering(DPi[9:0]);


endmodule