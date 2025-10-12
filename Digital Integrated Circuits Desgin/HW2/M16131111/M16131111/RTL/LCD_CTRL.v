`define statebits 4
module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output 		  IROM_rd  , 
	output  [5:0] IROM_A   ,
	output 		  IRAM_ceb ,
	output 		  IRAM_web ,
	output  reg [7:0] IRAM_D   ,
	output  [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,//no use
	output 		  busy	   ,
	output 		  done
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg [`statebits - 1:0] current_state;
reg [`statebits - 1:0] next_state;

reg [3:0] cmd_r;
reg [7:0] pixel_reg;
reg [7:0] max_min_reg;
reg [11:0] average_reg;
reg [3:0] rx_counter;
reg [3:0] tx_counter;
reg [2:0] op_x;
reg [2:0] op_y;
reg cmd_valid_r;
wire [5:0] A_base;
reg  [5:0] ROM_A;
reg  [5:0] RAM_A;
reg rx_delay;
reg rx_delay_r;
localparam IDLE = `statebits'd0;
localparam TRANS_IN = `statebits'd1;
localparam TRANS_OUT = `statebits'd2;
localparam RX_CMD = `statebits'd3;
localparam DECODE_CMD = `statebits'd4;
localparam OP_SHIFT = `statebits'd5;
localparam RX_DATA = `statebits'd6;
localparam TX_DATA = `statebits'd7;
localparam OUT = `statebits'd8;

assign IROM_rd = (current_state==TRANS_IN);
assign IRAM_ceb = (current_state==TX_DATA||current_state==TRANS_OUT||current_state==RX_DATA);
assign IRAM_web = ~(current_state==TX_DATA||current_state==TRANS_OUT);
assign busy = ~(current_state==RX_CMD);
assign done = (current_state==OUT);

always @(posedge clk or posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

assign IROM_A = ROM_A;
assign IRAM_A = RAM_A;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pixel_reg <= 8'd0;
	end
	else if(current_state==RX_DATA) begin
		pixel_reg <= IRAM_Q;
	end
	else if(current_state==TRANS_IN) begin
		pixel_reg <= IROM_Q;
	end
end


always @(posedge clk or posedge rst) begin
	if(rst) begin
		max_min_reg <= 8'd0;
	end
	else begin
		if(cmd_r==4'd5) begin
			if(current_state==DECODE_CMD) begin
				max_min_reg <= 8'd0;
			end
			else if(rx_delay)begin
				max_min_reg <= (pixel_reg>max_min_reg)? pixel_reg:max_min_reg;
			end
		end
		else  begin
			if(current_state==DECODE_CMD) begin
				max_min_reg <= 8'hff;
			end
			else if(rx_delay)begin
				max_min_reg <= (pixel_reg<max_min_reg)? pixel_reg:max_min_reg;
			end
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		average_reg <= 12'd0;
	end
	else if(current_state==RX_DATA&&rx_delay_r)begin
		average_reg <= average_reg + {4'd0,pixel_reg};
	end
	else if(current_state==IDLE) begin
		average_reg <= 12'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		rx_delay_r <= 1'b0;
	end
	else begin
		rx_delay_r <= rx_delay;
	end
end
reg first;
reg [5:0] trans_counter;
reg trans_done;
reg rx_done;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		first <= 1'b0;
	end
	else if(current_state==TRANS_IN)begin
		first <= 1'b1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		trans_counter <= 6'd0;
	end
	else if(current_state==TRANS_OUT)begin
		trans_counter <= trans_counter + 6'd1;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		trans_done <= 1'b0;
	end
	else if(trans_counter==6'd63)begin
		trans_done <= 1'b1;
	end
end

always @(*) begin
	case (current_state)
		IDLE: begin
			next_state = (first)? RX_CMD:TRANS_IN;
		end
		TRANS_IN: begin
			next_state = (rx_delay)? TRANS_OUT:TRANS_IN;
		end
		TRANS_OUT:begin
			next_state = (trans_done)? RX_CMD:TRANS_IN;
		end
		RX_CMD: begin
			next_state = (cmd_valid)? DECODE_CMD:RX_CMD;
		end
		DECODE_CMD: begin
			case (cmd_r)
				4'd0:begin
					next_state = OUT;
				end
				4'd1:begin
					next_state = OP_SHIFT;
				end
				4'd2:begin
					next_state = OP_SHIFT;
				end
				4'd3:begin
					next_state = OP_SHIFT;
				end
				4'd4:begin
					next_state = OP_SHIFT;
				end
				default:begin
					next_state = RX_DATA;
				end
			endcase
		end
		OP_SHIFT:begin
			next_state = IDLE;
		end
		RX_DATA:begin
			next_state = (rx_done)? TX_DATA:RX_DATA; 
		end
		TX_DATA:begin
			next_state = (tx_counter==4'd15)? IDLE:TX_DATA;
		end
		OUT:begin
			next_state = IDLE;
		end
		default:begin
			next_state = IDLE;
		end
	endcase
end



always @(posedge clk or posedge rst) begin
	if(rst) begin
		cmd_r <= 4'd0;
	end
	else if(cmd_valid)begin
		cmd_r <= cmd;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		rx_delay <= 1'b0;
	end
	else if(current_state==RX_DATA)begin
		rx_delay <= 1'b1;
	end
	else if(current_state==TRANS_IN)begin
		rx_delay <= 1'b1;
	end
	else begin
		rx_delay <= 1'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		rx_counter <= 4'd0;
	end
	else if(current_state==RX_DATA)begin
		rx_counter <= (rx_delay)? rx_counter + 4'd1:rx_counter;
	end
	else if(current_state==IDLE) begin
		rx_counter <= 4'd0;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		rx_done <= 1'b0;
	end
	else begin
		if(rx_counter==4'd15) begin
			rx_done <= 1'b1;
		end
		else begin
			rx_done <= 1'b0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		tx_counter <= 4'd0;
	end
	else if(current_state==TX_DATA)begin
		tx_counter <= tx_counter + 4'd1;
	end
	else if(current_state==IDLE) begin
		tx_counter <= 4'd0;
	end
end
wire [5:0] y_bias;
wire [5:0] x_bias;
assign y_bias = (op_y-3'd2) <<3;
assign x_bias = (op_x-3'd2);
assign A_base = y_bias + x_bias;

always @(*) begin
	ROM_A = trans_counter;
end

always @(*) begin
	if(current_state==TX_DATA) begin
		if(tx_counter<4'd4) begin
			RAM_A = A_base + tx_counter;
		end
		else if(tx_counter<4'd8)begin
			RAM_A = A_base + tx_counter + 5'd4;
		end
		else if(tx_counter<4'd12) begin
			RAM_A = A_base + tx_counter + 5'd8;
		end
		else begin
			RAM_A = A_base + tx_counter + 5'd12;
		end
	end
	else if(current_state==RX_DATA) begin
		if(rx_counter<4'd4) begin
			RAM_A = A_base + rx_counter;
		end
		else if(rx_counter<4'd8)begin
			RAM_A = A_base + rx_counter + 5'd4;
		end
		else if(rx_counter<4'd12) begin
			RAM_A = A_base + rx_counter + 5'd8;
		end
		else begin
			RAM_A = A_base + rx_counter + 5'd12;
		end
		end
	else begin
		RAM_A = trans_counter;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		op_x <= 3'd4;
		op_y <= 3'd4;
	end
	else if(current_state==OP_SHIFT)begin
		case (cmd_r)
			4'd2:begin
				if(op_y>3'd5) begin
					op_y <= op_y;
				end
				else begin
					op_y <= op_y + 3'd1;
				end
			end
			4'd1:begin
				if(op_y<3'd3) begin
					op_y <= op_y;
				end
				else begin
					op_y <= op_y - 3'd1;
				end
			end
			4'd3:begin
				if(op_x<3'd3) begin
					op_x <= op_x;
				end
				else begin
					op_x <= op_x - 3'd1;
				end
			end
			4'd4:begin
				if(op_x>3'd5) begin
					op_x <= op_x;
				end
				else begin
					op_x <= op_x + 3'd1;
				end
			end   
		endcase
	end
end
 
always @(*) begin
	case (cmd_r)
		4'd5:IRAM_D = max_min_reg;
		4'd6:IRAM_D = max_min_reg;
		4'd7:IRAM_D = average_reg >> 4;
		default:begin
			IRAM_D = pixel_reg;
		end
	endcase
end
endmodule