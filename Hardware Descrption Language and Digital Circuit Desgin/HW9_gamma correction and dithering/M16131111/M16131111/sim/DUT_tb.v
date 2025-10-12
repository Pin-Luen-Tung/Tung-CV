`timescale 1ns/10ps

`include "../src/timing_generator.v"
`include "image_capture.v"
`include "image_source.v"
`include "GA_VAG.v"
`include "../src/GC.v"
`include "../src/DI.v"

`timescale 1ns/10ps

module DUT_tb;

reg clk;
reg rst_n;
reg start;

wire [26:0] DPi;
wire [32:0] DPo;
//TG
reg  [10:0] v_total, v_size;
reg  [9:0]  v_start, v_sync;
reg  [11:0] h_total, h_size;
reg  [10:0] h_start, h_sync;
reg  [22:0] vs_reset; 
wire [2:0] Synco;
//GA_VAG
wire	    gamma_en;
wire [9:0]  gamma_data;
wire [7:0]  gamma_addr;
wire	    finish;
//GC
reg pass;

//Dithering
wire [26:0] DPo_final;

initial begin
					
/********** Timing parameter **********/
h_size  = 640;
v_size  = 480;	
h_total = 800;
v_total = 525;
h_sync  = 96;
v_sync  = 2;
h_start = 144;
v_start = 35;
vs_reset = 23'd0;

`ifdef PASS_TEST
  pass = 1;
`elsif NONE
  pass = 0;
`endif

end		

always #2.5 clk = ~clk;

initial begin
   clk=1; 
   rst_n=0;
   start=0;
   # 200 rst_n=1; 
   # 200 start = 1;

   #4000000 $finish;	
				
end	


/********** Waveform output **********/
initial begin
   `ifdef FSDB
      $fsdbDumpfile("top.fsdb");
      $fsdbDumpvars;
    `elsif FSDB_ALL
      $fsdbDumpfile("top.fsdb");
      $fsdbDumpvars;
      $fsdbDumpMDA;
    `endif
end

/********** gamma value generator **********/
GA_VAG u_GA(
.clk(clk),
.rst_n(rst_n),
.start(start),
.gamma_en(gamma_en),
.gamma_data(gamma_data),
.gamma_addr(gamma_addr),
.finish(finish),
.Vsync(Synco[2]));
/********** Image source **********/
image_source image_source(
   .clk(clk),
   .rst_n(rst_n),
   .Synci(Synco),
   .DPo(DPi));
/********** Timing generator **********/
timing_generator timing_generator(
  .Synco(Synco),
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
  .vs_reset(vs_reset));

/********** Function to be verified (DUT) **********/
GC GC(
  .clk(clk),
  .rst_n(rst_n),
  .pass(pass),
  .gamma_en(gamma_en),
  .gamma_data(gamma_data),
  .gamma_addr(gamma_addr),
  .DPi(DPi),
  .DPo(DPo));

DI DI(
  .clk(clk),
  .rst_n(rst_n),
  .pass(pass),
  .DPi(DPo),
  .DPo(DPo_final));
/********** Image capture (saved to BMP file) **********/
image_capture image_capture(
  .clk(clk),
  .rst_n(rst_n & finish),
  .DPi(DPo_final),
  .Hsize(h_size),
  .Vsize(v_size));

endmodule
  

