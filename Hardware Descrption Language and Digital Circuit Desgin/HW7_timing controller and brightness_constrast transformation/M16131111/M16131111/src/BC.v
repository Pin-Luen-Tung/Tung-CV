module BC(
    input clk,
    input rst_n,
    input [26:0] DPi,
    input pass,
    input [7:0] Brig,
    input [7:0] Cont,

    output reg [26:0] DPo
);

wire [7:0] R_in;
wire [7:0] G_in;
wire [7:0] B_in;
wire [15:0] R_mul;
wire [8:0] R_scaled;
wire [15:0] G_mul;
wire [8:0] G_scaled;
wire [15:0] B_mul;
wire [8:0] B_scaled;
wire [7:0] R_out;
wire [7:0] G_out;
wire [7:0] B_out;
wire signed [9:0] brightness;

wire signed [10:0] R_val;
wire signed [10:0] G_val;
wire signed [10:0] B_val;


assign R_in = DPi[23:16];
assign G_in = DPi[15:8];
assign B_in = DPi[7:0];



assign R_mul = R_in * Cont;
assign R_scaled = R_mul >> 7;
assign G_mul = G_in * Cont;
assign G_scaled = G_mul >> 7;
assign B_mul = B_in * Cont;
assign B_scaled = B_mul >> 7;

function  [7:0] saturation;
    input signed [10:0] val;
    begin
        if(val[10]) begin
            saturation = {8{1'b0}};
        end 
        else if(val > 10'd254) begin
            saturation = {8{1'b1}};
        end
        else begin
            saturation = val[7:0];
        end
    end
endfunction

assign brightness = (Brig[7])? -{3'b0, Brig[6:0]} : {3'b0, Brig[6:0]};

assign R_val = $signed({1'b0,R_scaled}) + brightness;
assign G_val = $signed({1'b0,G_scaled}) + brightness;
assign B_val = $signed({1'b0,B_scaled}) + brightness;

assign R_out = saturation(R_val);
assign G_out = saturation(G_val);
assign B_out = saturation(B_val);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        DPo <= 27'd0;
    end 
    else begin
        if (~pass) begin
            DPo <= {DPi[26:24], R_out, G_out, B_out};
        end
        else begin
            DPo <= DPi;
        end
    end
end



endmodule