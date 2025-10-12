
module Multiply #(
    parameter   INT_WIDTH_in = 8,
    parameter   FRA_WIDTH_in = 8,
    parameter   INT_WIDTH_out = 8,
    parameter   FRA_WIDTH_out = 16
)(
    input   signed  [INT_WIDTH_in+FRA_WIDTH_in-1:0] a_re,
    input   signed  [INT_WIDTH_in+FRA_WIDTH_in-1:0] a_im,
    input   signed  [INT_WIDTH_in+FRA_WIDTH_in-1:0] b_re,
    input   signed  [INT_WIDTH_in+FRA_WIDTH_in-1:0] b_im,
    output  signed  [INT_WIDTH_out+FRA_WIDTH_out-1:0] m_re,
    output  signed  [INT_WIDTH_out+FRA_WIDTH_out-1:0] m_im
);

localparam IN_W   = INT_WIDTH_in  + FRA_WIDTH_in;
localparam OUT_W  = INT_WIDTH_out + FRA_WIDTH_out;
localparam PROD_W = IN_W * 2;                   
localparam FRA_OUT = 23;


wire signed [PROD_W-1:0]   arbr, arbi, aibr, aibi;

assign  arbr = a_re * b_re;
assign  arbi = a_re * b_im;
assign  aibr = a_im * b_re;
assign  aibi = a_im * b_im;



   
wire signed [PROD_W:0] re_tmp;
wire signed [24:0] re_temp_shift;
assign re_tmp = arbr - aibi;
assign re_temp_shift = re_tmp >>> 7;
assign m_re = re_temp_shift[23:0];          


wire signed [PROD_W:0] im_tmp;
wire signed [24:0] im_temp_shift;
assign im_tmp = arbi + aibr;
assign im_temp_shift = im_tmp >>> 7;
assign m_im = im_temp_shift[23:0];



endmodule