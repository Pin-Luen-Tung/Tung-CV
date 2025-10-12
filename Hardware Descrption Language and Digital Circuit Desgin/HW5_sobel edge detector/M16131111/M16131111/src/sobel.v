`define statebits 1
module sobel(
    input clk,
    input rst,
    input [7:0] pixel_in,
    output reg busy,
    output reg valid,
    output [7:0] pixel_out
);

wire stall;
reg [7:0] line_buffer_1 [0:127];
reg [7:0] line_buffer_2 [0:127];
reg [7:0] line_buffer_3 [0:127];
reg [7:0] line_buffer_4 [0:127];
reg [7:0] op_data [0:8];
reg signed [9:0] Gx;
wire [19:0] Gx_square;
reg signed [9:0] Gy;
wire [19:0] Gy_square;
wire [20:0]G_square;
wire left;
wire right;
wire top;
wire down;

reg line_2_valid;

reg [1:0] line_contorl;// 0 for line1 , 1 for line2 , 2 for line3 , 3 for line4
reg [6:0] line_counter;
reg [6:0] line_counter_r;
reg [1:0] op_control;

//    4  //    1  //    2  //    3 
// 0  1  // 1  2  // 2  3  // 3  4
//    2  //    3  //    4  //    1

reg [6:0] op_counter;
reg [6:0] op_line_counter;

always @(*) begin
    busy = stall;
end

assign stall = 1'b0;

assign Gx_square = Gx * Gx;
assign Gy_square = Gy * Gy;
assign G_square = Gx_square + Gy_square;
assign pixel_out = (G_square>21'd16127)? 8'd255:8'd0;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        line_contorl <= 2'd0;
    end
    else if(line_counter_r==7'd127) begin
        line_contorl <= line_contorl + 2'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        line_counter <= 7'd0;
    end
    else if(~stall) begin
        line_counter <= line_counter + 7'd1;
    end
end

integer i;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for (i = 0;i < 128;i = i + 1) begin
            line_buffer_1[i] <= 8'd0;
        end
    end
    else if(stall) begin
        ;
    end
    else if(line_contorl==2'b00) begin
        line_buffer_1[line_counter_r] <= pixel_in;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for (i = 0;i < 128;i = i + 1) begin
            line_buffer_2[i] <= 8'd0;
        end
    end
    else if(stall) begin
        ;
    end
    else if(line_contorl==2'b01) begin
        line_buffer_2[line_counter_r] <= pixel_in;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for (i = 0;i < 128;i = i + 1) begin
            line_buffer_3[i] <= 8'd0;
        end
    end
    else if(stall) begin
        ;
    end
    else if(line_contorl==2'b10) begin
        line_buffer_3[line_counter_r] <= pixel_in;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        line_counter_r <= 7'd0;
    end
    else begin
        line_counter_r <= line_counter;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for (i = 0;i < 128;i = i + 1) begin
            line_buffer_4[i] <= 8'd0;
        end
    end
    else if(stall) begin
        ;
    end
    else if(line_contorl==2'b11) begin
        line_buffer_4[line_counter_r] <= pixel_in;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_line_counter <= 7'd0;
    end
    else if(stall) begin
        ;
    end
    else if(op_counter==7'd127)begin
        op_line_counter <= op_line_counter + 7'd1;
    end
end

assign top = (op_line_counter==7'd0);
assign down = (op_line_counter==7'd127);
assign right = (op_counter==7'd127);
assign left = (op_counter==7'd0);

wire signed [9:0] x_0;
wire signed [9:0] x_3;
wire signed [9:0] x_6;
wire signed [9:0] y_0;
wire signed [9:0] y_1;
wire signed [9:0] y_2;
assign x_0 = -op_data[0];
assign x_3 = -2*op_data[3];
assign x_6 = -op_data[6];
assign y_0 = -op_data[0];
assign y_1 = -2*op_data[1];
assign y_2 = -op_data[2];
always @(posedge clk or posedge rst) begin
    if(rst) begin
        Gx <= 10'd0;
    end
    else if(stall) begin
        ;
    end
    else begin
        Gx <= $signed(x_0 + x_3 + x_6 + op_data[2] + op_data[5]*7'd2 + op_data[8]);
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        Gy <= 10'd0;
    end
    else if(stall) begin
        ;
    end
    else begin
        Gy <= $signed(y_0 + y_1 + y_2 + op_data[6] + op_data[7]*7'd2 + op_data[8]);
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_counter <= 7'd0;
    end
    else if(stall) begin
        ;
    end
    else if(line_2_valid)begin
        op_counter <= op_counter + 7'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_control <= 2'd0;
    end
    else if(stall) begin
        ;
    end
    else if(op_counter==7'd127) begin
        op_control <= op_control + 2'd1;
    end
end

always @(*) begin
    case (op_control)
        2'b00: begin
            if(left)begin
                op_data[0] = (top)? line_buffer_1[0]:line_buffer_4[0];
                op_data[3] = line_buffer_1[0];
                op_data[6] = line_buffer_2[0];
                op_data[1] = (top)? line_buffer_1[0]:line_buffer_4[0];
                op_data[4] = line_buffer_1[0];
                op_data[7] = line_buffer_2[0];
                op_data[2] = (top)? line_buffer_1[1]:line_buffer_4[1];
                op_data[5] = line_buffer_1[1];
                op_data[8] = line_buffer_2[1];
            end
            else if(right) begin
                op_data[0] = (top)? line_buffer_1[126]:line_buffer_4[126];
                op_data[3] = line_buffer_1[126];
                op_data[6] = line_buffer_2[126];
                op_data[1] = (top)? line_buffer_1[127]:line_buffer_4[127];
                op_data[4] = line_buffer_1[127];
                op_data[7] = line_buffer_2[127];
                op_data[2] = (top)? line_buffer_1[127]:line_buffer_4[127];
                op_data[5] = line_buffer_1[127];
                op_data[8] = line_buffer_2[127];
            end
            else begin
                op_data[0] = (top)? line_buffer_1[op_counter-7'd1]:line_buffer_4[op_counter-7'd1];
                op_data[3] = line_buffer_1[op_counter-7'd1];
                op_data[6] = line_buffer_2[op_counter-7'd1];
                op_data[1] = (top)? line_buffer_1[op_counter]:line_buffer_4[op_counter];
                op_data[4] = line_buffer_1[op_counter];
                op_data[7] = line_buffer_2[op_counter];
                op_data[2] = (top)? line_buffer_1[op_counter+7'd1]:line_buffer_4[op_counter+7'd1];
                op_data[5] = line_buffer_1[op_counter+7'd1];
                op_data[8] = line_buffer_2[op_counter+7'd1];
            end
        end
        2'b01: begin
            if(left) begin
                op_data[0] = line_buffer_1[0];
                op_data[3] = line_buffer_2[0];
                op_data[6] = line_buffer_3[0];
                op_data[1] = line_buffer_1[0];
                op_data[4] = line_buffer_2[0];
                op_data[7] = line_buffer_3[0];
                op_data[2] = line_buffer_1[1];
                op_data[5] = line_buffer_2[1];
                op_data[8] = line_buffer_3[1];
            end
            else if(right) begin
                op_data[0] = line_buffer_1[126];
                op_data[3] = line_buffer_2[126];
                op_data[6] = line_buffer_3[126];
                op_data[1] = line_buffer_1[127];
                op_data[4] = line_buffer_2[127];
                op_data[7] = line_buffer_3[127];
                op_data[2] = line_buffer_1[127];
                op_data[5] = line_buffer_2[127];
                op_data[8] = line_buffer_3[127];
            end
            else begin
                op_data[0] = line_buffer_1[op_counter-7'd1];
                op_data[3] = line_buffer_2[op_counter-7'd1];
                op_data[6] = line_buffer_3[op_counter-7'd1];
                op_data[1] = line_buffer_1[op_counter];
                op_data[4] = line_buffer_2[op_counter];
                op_data[7] = line_buffer_3[op_counter];
                op_data[2] = line_buffer_1[op_counter+7'd1];
                op_data[5] = line_buffer_2[op_counter+7'd1];
                op_data[8] = line_buffer_3[op_counter+7'd1];
            end
        end
        2'b10: begin
            if(left) begin
                op_data[0] = line_buffer_2[0];
                op_data[3] = line_buffer_3[0];
                op_data[6] = line_buffer_4[0];
                op_data[1] = line_buffer_2[0];
                op_data[4] = line_buffer_3[0];
                op_data[7] = line_buffer_4[0];
                op_data[2] = line_buffer_2[1];
                op_data[5] = line_buffer_3[1];
                op_data[8] = line_buffer_4[1];
            end
            else if(right) begin
                op_data[0] = line_buffer_2[126];
                op_data[3] = line_buffer_3[126];
                op_data[6] = line_buffer_4[126];
                op_data[1] = line_buffer_2[127];
                op_data[4] = line_buffer_3[127];
                op_data[7] = line_buffer_4[127];
                op_data[2] = line_buffer_2[127];
                op_data[5] = line_buffer_3[127];
                op_data[8] = line_buffer_4[127];
            end
            else begin
                op_data[0] = line_buffer_2[op_counter-7'd1];
                op_data[3] = line_buffer_3[op_counter-7'd1];
                op_data[6] = line_buffer_4[op_counter-7'd1];
                op_data[1] = line_buffer_2[op_counter];
                op_data[4] = line_buffer_3[op_counter];
                op_data[7] = line_buffer_4[op_counter];
                op_data[2] = line_buffer_2[op_counter+7'd1];
                op_data[5] = line_buffer_3[op_counter+7'd1];
                op_data[8] = line_buffer_4[op_counter+7'd1];
            end
        end
        2'b11: begin
            if(left) begin
                op_data[0] = line_buffer_3[0];
                op_data[3] = line_buffer_4[0];
                op_data[6] = (down)? line_buffer_4[0]:line_buffer_1[0];
                op_data[1] = line_buffer_3[0];
                op_data[4] = line_buffer_4[0];
                op_data[7] = (down)? line_buffer_4[0]:line_buffer_1[0];
                op_data[2] = line_buffer_3[1];
                op_data[5] = line_buffer_4[1];
                op_data[8] = (down)? line_buffer_4[1]:line_buffer_1[1];
            end
            else if(right) begin
                op_data[0] = line_buffer_3[126];
                op_data[3] = line_buffer_4[126];
                op_data[6] = (down)? line_buffer_4[126]:line_buffer_1[126];
                op_data[1] = line_buffer_3[127];
                op_data[4] = line_buffer_4[127];
                op_data[7] = (down)? line_buffer_4[127]:line_buffer_1[127];
                op_data[2] = line_buffer_3[127];
                op_data[5] = line_buffer_4[127];
                op_data[8] = (down)? line_buffer_4[127]:line_buffer_1[127];
            end
            else begin
                op_data[0] = line_buffer_3[op_counter-7'd1];
                op_data[3] = line_buffer_4[op_counter-7'd1];
                op_data[6] = (down)? line_buffer_4[op_counter-7'd1]:line_buffer_1[op_counter-7'd1];
                op_data[1] = line_buffer_3[op_counter];
                op_data[4] = line_buffer_4[op_counter];
                op_data[7] = (down)? line_buffer_4[op_counter]:line_buffer_1[op_counter];
                op_data[2] = line_buffer_3[op_counter+7'd1];
                op_data[5] = line_buffer_4[op_counter+7'd1];
                op_data[8] = (down)? line_buffer_4[op_counter+7'd1]:line_buffer_1[op_counter+7'd1];
            end
        end
        default: begin
            ;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        valid <= 1'b0;
    end
    else begin
        valid <= line_2_valid;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        line_2_valid <= 1'b0;
    end
    else if(line_counter_r==7'd127&&line_contorl==2'd1)begin
        line_2_valid <= 1'b1;
    end
end
endmodule