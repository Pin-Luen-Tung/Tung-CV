/////// test_bench  ////////////////

`timescale 1ns/10ps
`undef BIT0
`undef BIT1
`define BIT0  1'b0
`define BIT1  1'b1
`define	DELAY	300
`define timing cytime

`include "i2c_slave.v"
`include "host_reg_bank.v"

module ASIC_final_tb;

parameter cytime = 2000000;
parameter t_reg = 10;


  reg           clk;
  reg           rst_n;    
  reg           i2c_scl;  
  reg           sda_in;
 
  //SLAVE1
  wire        sda_out;
  wire        sda_o_en;
  wire        wr;
  wire        rd;
  wire  [7:0] addr;
  wire  [7:0] dout;   
  wire  [7:0] din;
  //SLAVE2
  wire	[7:0] din_a;
  wire   sda_o_out_a;
  wire   sda_o_en_a;
  wire   wr_a,rd_a;
  wire	[7:0] dout_a,addr_a;
  
  reg  work_flag;
  reg  slave_ack_flag;
  reg  master_ack_flag;
  
  wire  SDA;
  
  
  wire sda_en_final;
 
  reg  sda_out_final;

  // TSETBENCH REGISTER DECLARATION                                    

  reg          finish;
  reg   [7:0]  test;
  reg          i2c_dir;
  
  assign  sda_en_final =  (sda_o_en||sda_o_en_a);
 
	always@(*)begin
		if(sda_o_en==1)
			sda_out_final<=sda_out;
		else if(sda_o_en_a==1)
			sda_out_final<=sda_o_out_a;
		else
			sda_out_final<=0;
	end
	
 
  assign SDA = (i2c_dir)? sda_in : sda_out_final;
                   
/*********initial setting********/

initial begin
   clk   = 0;
   rst_n    = 0; 
   sda_in  = 1;
   i2c_scl  = 1;
   i2c_dir  = 1;
   finish = 0;
   test =0;
   
   #4000 rst_n = 1;
  
end 

   always@(*)begin
		if(sda_o_en==1)
		test = din;
		else if(sda_o_en_a==1)
		test = din_a;
		else
		test = test;
   end
   
/**********setting clock ***************/
   
always  #t_reg  clk = ~ clk;


i2c_slave #(.SLAVE_ADDR(7'b1111_010))
	i2c_u1 
(
	.clk(clk),
	.rst_n(rst_n),
	.scl(i2c_scl),
	.sda_i(sda_in),
	.i2c_din(din),
	.sda_o(sda_out),
	.sda_o_en(sda_o_en),
	.wr(wr),
	.rd(rd),
	.i2c_addr(addr),
	.i2c_dout(dout)
);

i2c_slave #(.SLAVE_ADDR(7'b1111_101))
	i2c_u2 
(
	.clk(clk),
	.rst_n(rst_n),
	.scl(i2c_scl),
	.sda_i(sda_in),
	.i2c_din(din_a),
	.sda_o(sda_o_out_a),
	.sda_o_en(sda_o_en_a),
	.wr(wr_a),
	.rd(rd_a),
	.i2c_addr(addr_a),
	.i2c_dout(dout_a)
);

host_reg_bank reg_u2
(
	.clk(clk),
	.rst_n(rst_n),
	.wr(wr_a),
	.rd(rd_a),
	.i2c_addr(addr_a),
	.i2c_dout(dout_a),
	.i2c_din(din_a)
);

host_reg_bank reg_u1
(
	.clk(clk),
	.rst_n(rst_n),
	.wr(wr),
	.rd(rd),
	.i2c_addr(addr),
	.i2c_dout(dout),
	.i2c_din(din)
);


/************output waveform********************/

initial begin
	`ifdef NORMAL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0);
	`elsif ARRAY
	$fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, "+mda");
	`endif
end

`include "./task_i2c.v"

/*********** test pattern **************/
initial
	begin
        #4100
        $display ( "*********************************************");
        $display ( "        Set ASIC Video Register              ");
        $display ( "*********************************************");

		
		$display ( "\n....Set value:1c to address:0........");
		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
	    	I2C_WRITE_SUBADDR(8'h00);
		I2C_WRITE_BYTE(8'h1c);
		I2C_STOP;
		
		$display ( "\n....Set value:2b to address:1........");
		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
	    	I2C_WRITE_SUBADDR(8'h01);
		I2C_WRITE_BYTE(8'h2b);
		I2C_STOP;
		
		$display ( "\n....Set value:2a to address:1........");
		I2C_START;
		I2C_WRITE_DEVICE(8'hFA);
	    	I2C_WRITE_SUBADDR(8'h01);
		I2C_WRITE_BYTE(8'h2a);
		I2C_STOP;
		
		$display ( "\n....Read data from address 1....... ");	    
		I2C_START;
		I2C_WRITE_DEVICE(8'hFA);
            	I2C_WRITE_SUBADDR(8'h01);
		I2C_START;
		I2C_WRITE_DEVICE(8'hFB);
		I2C_READ_BYTE(test);
		if(test === 8'h2a)  $display ("....i2c read ok!!.....");
		else               $display ("....i2c read fail!!.....");
		I2C_STOP;
		
		$display ( "\n....Read data from address 0....... ");	    
		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
            	I2C_WRITE_SUBADDR(8'h00);
		I2C_START;
		I2C_WRITE_DEVICE(8'hF5);
		I2C_READ_BYTE(test);
		if(test === 8'h1c)  $display ("....i2c read ok!!.....");
		else               $display ("....i2c read fail!!.....");
		I2C_STOP;
		
		$display ( "\n....Read data from address 1....... ");		
		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
	    	I2C_WRITE_SUBADDR(8'h01);
		I2C_START;
		I2C_WRITE_DEVICE(8'hF5);
		I2C_READ_BYTE(test);
		if(test == 8'h2b)  $display ("....i2c read ok!!.....");
		else               $display ("....i2c read fail!!.....");
		I2C_STOP;
		
		$display ( "\n....Set value:3a to address:0........");
		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
	    	I2C_WRITE_SUBADDR(8'h00);
		I2C_WRITE_BYTE(8'h3a);
		I2C_STOP;	
			 
        	$display ( "\n....Read data from address 0....... ");		

		I2C_START;
		I2C_WRITE_DEVICE(8'hF4);
	    	I2C_WRITE_SUBADDR(8'h00);
		I2C_START;
		I2C_WRITE_DEVICE(8'hF5);
		I2C_READ_BYTE(test);
		if(test === 8'h3a)  $display ("....i2c read ok!!.....");
		else               $display ("....i2c read fail!!.....");
		I2C_STOP;  
		
		finish = 1'b1;		   
		$finish; 
	 end
 		  
endmodule
