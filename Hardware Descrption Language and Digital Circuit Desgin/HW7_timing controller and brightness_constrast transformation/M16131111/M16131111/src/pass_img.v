module pass_img(
    input clk,
    input rst_n,
    input [26:0] DPi,
  
    output reg [26:0] DPo
);

always @(posedge clk) begin
    if(!rst_n)
        DPo <= 27'd0;
    else
        DPo <= DPi;
end

endmodule
