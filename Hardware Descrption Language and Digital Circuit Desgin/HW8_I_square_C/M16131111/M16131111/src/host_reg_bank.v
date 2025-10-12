/*********************************   host register bank  *************************************/
module host_reg_bank(
	input clk,
	input rst_n, 
	input wr,
	input rd,
	input [7:0]i2c_addr,
	input [7:0]i2c_dout,
	output [7:0] i2c_din
);
//write down your code//

reg [7:0] mem [0:255];
reg [7:0] din_r;          
assign i2c_din = din_r;

always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            din_r <= 8'h00;    
        end
        else begin
            if (wr) begin
                mem[i2c_addr] <= i2c_dout;
            end
            if (rd) begin
                din_r <= wr ? i2c_dout : mem[i2c_addr];
            end
        end
    end


endmodule
