
module Butterfly #(
    parameter   INT_WIDTH = 16,
    parameter   FRA_WIDTH = 16
)(
    input   signed  [INT_WIDTH+FRA_WIDTH-1:0] x0_re,  
    input   signed  [INT_WIDTH+FRA_WIDTH-1:0] x0_im,  
    input   signed  [INT_WIDTH+FRA_WIDTH-1:0] x1_re,  
    input   signed  [INT_WIDTH+FRA_WIDTH-1:0] x1_im,  
    output  signed  [INT_WIDTH+FRA_WIDTH-1:0] y0_re,  
    output  signed  [INT_WIDTH+FRA_WIDTH-1:0] y0_im,  
    output  signed  [INT_WIDTH+FRA_WIDTH-1:0] y1_re,  
    output  signed  [INT_WIDTH+FRA_WIDTH-1:0] y1_im   
);

wire signed [INT_WIDTH+FRA_WIDTH:0]   add_re, add_im, sub_re, sub_im;


assign  add_re = x0_re + x1_re;
assign  add_im = x0_im + x1_im;
assign  sub_re = x0_re - x1_re;
assign  sub_im = x0_im - x1_im;

assign  y0_re = (add_re[INT_WIDTH+FRA_WIDTH-1:0]) ;
assign  y0_im = (add_im[INT_WIDTH+FRA_WIDTH-1:0]) ;
assign  y1_re = (sub_re[INT_WIDTH+FRA_WIDTH-1:0]) ;
assign  y1_im = (sub_im[INT_WIDTH+FRA_WIDTH-1:0]) ;

endmodule