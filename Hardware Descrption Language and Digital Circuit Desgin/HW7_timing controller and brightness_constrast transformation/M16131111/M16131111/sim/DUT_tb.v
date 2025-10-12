`timescale 1ns/1ps

`include "BC.v"
`include "pass_img.v"
`include "timing_generator.v"
`include "image_capture.v"
`include "image_source.v"

module DUT_tb;


reg [10:0] v_total, v_size;
reg [9:0]  v_start, v_sync;
reg [11:0] h_total, h_size;
reg [10:0] h_start, h_sync;
reg [22:0] vs_reset; 
reg rst_n,clk;
wire [2:0] sync;
wire [26:0] DP,DP_r,DP_BC;
reg pass;
reg [7:0] Brig,Cont;

initial begin

/********** Timing parameter **********/

    #0  clk=0;
    #0  rst_n =1;

    h_size  = 640;
    h_total = 800;
    h_sync  = 96;
    h_start = 144;
    v_size  = 480;
    v_total = 525;
    v_sync  = 2;
    v_start = 35;
    vs_reset = 23'h7fffff;
    pass = 0;
    Brig = 255;
    Cont = 150;

	#10 rst_n =0;
	#10 rst_n =1;

#13000000
$finish;
end

always #(2.5) clk=~clk;

/********** Waveform output **********/

initial begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0);
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, "+mda");
    `endif
end


 
/********** Image source **********/
image_source image_source(
   .clk(clk),
   .rst_n(rst_n),
   .Synci(sync),
   .DPo(DP));
/********** Timing generator **********/
timing_generator timing_generator(
    .Synco(sync),
    .clk(clk),
    .rst_n(rst_n),
    .v_total(v_total),
    .v_sync(v_sync),
    .v_start(v_start),
    .v_size(v_size),
    .h_total(h_total),
    .h_sync(h_sync),
    .h_start(h_start),
    .h_size(h_size),
    .vs_reset(vs_reset)
);

/********** Function to be verified (DUT) **********/

`ifdef PASS_TEST
pass_img pass_img(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(DP),
    .DPo(DP_r)
);
`elsif NONE
BC bc(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(DP),
    .DPo(DP_BC),
    .pass(pass),
    .Brig(Brig),
    .Cont(Cont)
);
`endif

/********** Image capture (saved to BMP file) **********/
wire [26:0] DP_capture;
`ifdef PASS_TEST
    assign DP_capture = DP_r;
`elsif NONE
    assign DP_capture = DP_BC;
`endif

image_capture image_capture(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(DP_capture),
    .Hsize(h_size),
    .Vsize(v_size)
);

endmodule

