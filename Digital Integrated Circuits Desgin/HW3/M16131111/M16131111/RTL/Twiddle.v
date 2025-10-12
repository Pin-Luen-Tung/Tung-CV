module Twiddle #(
    parameter   SEL = 1  
)(
    input           clk, 
    input   [3:0]   addr,   
    output  [15:0]  tw_re,  
    output  [15:0]  tw_im   
);

wire[15:0]  wn_re[0:15];   
wire[15:0]  wn_im[0:15];   
wire[15:0]  mx_re;        
wire[15:0]  mx_im;       
reg [15:0]  ff_re;    
reg [15:0]  ff_im;    

assign  mx_re = wn_re[addr];
assign  mx_im = wn_im[addr];

always @(posedge clk) begin
    ff_re <= mx_re;
    ff_im <= mx_im;
end

assign  tw_re = SEL ? ff_re : mx_re;
assign  tw_im = SEL ? ff_im : mx_im;

wire [15:0] haha;
assign haha = 16'd0;

//
//      wn_re = cos(-2pi*n/16)          wn_im = sin(-2pi*n/16)
assign  wn_re[ 0] = haha;   assign  wn_im[ 0] = haha;  
assign  wn_re[ 1] = 16'h7642;   assign  wn_im[ 1] = 16'hCF04; 
assign  wn_re[ 2] = 16'h5A82;   assign  wn_im[ 2] = 16'hA57E;   
assign  wn_re[ 3] = 16'h30FC;   assign  wn_im[ 3] = 16'h89BE;   
assign  wn_re[ 4] = haha;   assign  wn_im[ 4] = 16'h8000;  
assign  wn_re[ 5] = 16'hCF04;   assign  wn_im[ 5] = 16'h89BE;   
assign  wn_re[ 6] = 16'hA57E;   assign  wn_im[ 6] = 16'hA57E;  
assign  wn_re[ 7] = 16'h89BE;   assign  wn_im[ 7] = 16'hCF04;   
assign  wn_re[ 8] = haha;   assign  wn_im[ 8] = haha;   
assign  wn_re[ 9] = 16'h89BE;   assign  wn_im[ 9] = 16'h30FC;  
assign  wn_re[10] = haha;   assign  wn_im[10] = haha;   
assign  wn_re[11] = haha;   assign  wn_im[11] = haha;   
assign  wn_re[12] = haha;   assign  wn_im[12] = haha;  
assign  wn_re[13] = haha;   assign  wn_im[13] = haha;  
assign  wn_re[14] = haha;   assign  wn_im[14] = haha;   
assign  wn_re[15] = haha;   assign  wn_im[15] = haha;   



endmodule
