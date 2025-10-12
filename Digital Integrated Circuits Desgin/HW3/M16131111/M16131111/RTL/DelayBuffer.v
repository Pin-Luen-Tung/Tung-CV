//----------------------------------------------------------------------
//  DelayBuffer: Generate Constant Delay
//----------------------------------------------------------------------
module DelayBuffer #(
    parameter   DEPTH = 32,
    parameter   INT_WIDTH = 8,
    parameter   FRA_WIDTH = 16
)(
    input               clk,  //  Master Clock
    input               stall,
    input   [INT_WIDTH+FRA_WIDTH-1:0] di_re,  //  Data Input (Real)
    input   [INT_WIDTH+FRA_WIDTH-1:0] di_im,  //  Data Input (Imag)
    output  [INT_WIDTH+FRA_WIDTH-1:0] do_re,  //  Data Output (Real)
    output  [INT_WIDTH+FRA_WIDTH-1:0] do_im   //  Data Output (Imag)
);

reg [INT_WIDTH+FRA_WIDTH-1:0] buf_re[0:DEPTH-1];
reg [INT_WIDTH+FRA_WIDTH-1:0] buf_im[0:DEPTH-1];
integer n;

//  Shift Buffer
always @(posedge clk) begin
    if(~stall) begin
        for (n = DEPTH-1; n > 0; n = n - 1) begin
        buf_re[n] <= buf_re[n-1];
        buf_im[n] <= buf_im[n-1];
        end
        buf_re[0] <= di_re;
        buf_im[0] <= di_im;
    end
end

assign  do_re = buf_re[DEPTH-1];
assign  do_im = buf_im[DEPTH-1];

endmodule