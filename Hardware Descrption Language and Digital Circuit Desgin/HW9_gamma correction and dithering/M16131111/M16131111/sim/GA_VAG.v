/**********************************************************************/
//      COPYRIGHT (C)  National Chung-Cheng University
//
// MODULE:        the data of gamma correction module for ASIC lab
//
// FILE NAME:     GA_VAG.v
// VERSION:       1.0
// AUTHOR:        Chao-Yung Chang
// 
// CODE TYPE:     RTL model
//
// DESCRIPTION:       the gamma value generator     
/**********************************************************************/

`timescale 1ns/10ps

module GA_VAG(
  input        clk,
  input        rst_n,
  input        start,
  input		   Vsync,
  output reg        gamma_en,
  output reg [9:0]  gamma_data,
  output reg [7:0]  gamma_addr,
  output reg        finish    
);

reg [9:0] ga_buf [256:0];
reg [8:0] od_cnt;


initial begin
		`ifdef GAMMA05
  			$readmemh("../sim/LUT/gamma05.txt", ga_buf);
		`elsif GAMMA15
			$readmemh("../sim/LUT/gamma15.txt", ga_buf);
		`elsif GAMMA22
			$readmemh("../sim/LUT/gamma22.txt", ga_buf);
		`endif
		
      	ga_buf [256] = 10'b0; 
end

// output data counter 
always @(negedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    od_cnt <= 8'b0;
  end
  else begin
	if(Vsync==1'b1) begin
		if(od_cnt == 9'd256) od_cnt <= 9'd256;
		else if(start) od_cnt <= od_cnt + 8'b1;
		else od_cnt <= od_cnt;
	end
	else od_cnt <= od_cnt;
  end
end

// gamma output enable and finish signal
always @(negedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    gamma_en <= 1'b0;
    finish   <= 1'b0;
  end
  else begin
	if(Vsync==1'b1) begin
		if(od_cnt == 9'd256)begin
			gamma_en <= 1'b0;
			finish   <= 1'b1;    
		end
		else if(start)begin
			gamma_en <= 1'b1;
			finish   <= 1'b0;    
		end 
		else begin
			gamma_en <= 1'b1;
			finish   <= 1'b0; 
		end
	end
	else begin
		gamma_en <= gamma_en;
		finish   <= finish;
	end
  end
end 


// gamma output data and address
always @(negedge clk or negedge rst_n)
begin
  if (!rst_n) begin 
    gamma_data <= 10'b0;
    gamma_addr <=  8'b0;
  end
  else begin
	if(Vsync == 1'b1) begin
		gamma_data <= ga_buf[od_cnt];
		gamma_addr <= od_cnt;
    end
	else begin
		gamma_data <= gamma_data;
		gamma_addr <= gamma_data;
	end
  end
end       
   
   
endmodule
