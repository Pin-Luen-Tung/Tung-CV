`timescale 1ns/10ps
`define statebits 2
`define L0_statebits 3
module  ATCONV(
        input		clk       ,
        input		rst       ,
        output          ROM_rd    ,
        output [11:0]	iaddr     ,
        input  [15:0]	idata     ,
        output          layer0_ceb,
        output          layer0_web,   
        output reg [11:0]   layer0_A  ,
        output reg [15:0]   layer0_D  ,
        input  [15:0]   layer0_Q  ,
        output          layer1_ceb,
        output          layer1_web,
        output [11:0]   layer1_A  ,
        output [15:0]   layer1_D  ,
        input  [15:0]   layer1_Q  ,
        output          done        
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg [`statebits-1:0] current_state,next_state;
wire L0_done;
localparam IDLE = `statebits'd0;
localparam L0 = `statebits'd1;
localparam DONE = `statebits'd3;

reg [`L0_statebits - 1:0] L0_current_state,L0_next_state;
reg [5:0] op_x;
reg [5:0] op_y;
reg [4:0] op_max_pool_x;
reg [4:0] op_max_pool_y;
reg [5:0] rom_x;
reg [5:0] rom_y;
reg [1:0] op_control;
reg [15:0] max;
wire [15:0] max_plus_one;
reg [3:0] mul_add_counter;
reg signed [5:0] weights;
wire signed [21:0] mul_result;
reg signed [21:0] psum;
localparam L0_IDLE = `L0_statebits'd0;
localparam L0_MUL_ADD = `L0_statebits'd1;
localparam L0_WRITE = `L0_statebits'd2;
localparam L0_MAX_POOL = `L0_statebits'd3;
localparam L0_DONE = `L0_statebits'd4;


always @(posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            next_state = L0;
        end
        L0: begin
            next_state = (L0_done)? DONE:L0;
        end
        DONE: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        L0_current_state <= L0_IDLE;
    end
    else begin
        L0_current_state <= L0_next_state;
    end
end

always @(*) begin
    case (L0_current_state)
        L0_IDLE: begin
            L0_next_state = (current_state==L0)? L0_MUL_ADD:L0_IDLE;
        end
        L0_MUL_ADD: begin
            L0_next_state = (mul_add_counter==4'd8)? L0_WRITE:L0_MUL_ADD;
        end
        L0_WRITE: begin
            L0_next_state = (op_x==6'd63&&op_y==6'd62)? L0_DONE:(op_control==2'd3)? L0_MAX_POOL:L0_MUL_ADD;
        end
        L0_MAX_POOL: begin
            L0_next_state = L0_MUL_ADD;
        end
        L0_DONE: begin
            L0_next_state = L0_IDLE;
        end
    endcase
end



always @(*) begin
    case (mul_add_counter)
        4'd0,4'd3,4'd6:begin
            if(op_x>6'd1) begin
                rom_x = op_x - 6'd2;
            end
            else begin
                rom_x = 6'd0;
            end
        end
        4'd1,4'd4,4'd7:begin
            rom_x = op_x;
        end
        default: begin
            if(op_x>6'd61) begin
                rom_x = 6'd63;
            end
            else begin
                rom_x = op_x + 6'd2;
            end
        end
    endcase
end

always @(*) begin
    case (mul_add_counter)
        4'd0,4'd1,4'd2:begin
            if(op_y>6'd1) begin
                rom_y = op_y - 6'd2;
            end
            else begin
                rom_y = 6'd0;
            end
        end
        4'd3,4'd4,4'd5:begin
            rom_y = op_y;
        end
        default: begin
            if(op_y>6'd61) begin
                rom_y = 6'd63;
            end
            else begin
                rom_y = op_y + 6'd2;
            end
        end
    endcase
end

assign iaddr = {rom_y,rom_x};

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mul_add_counter <= 4'd0;
    end
    else if(L0_current_state==L0_MUL_ADD)begin
        if(mul_add_counter==4'd8) begin
            mul_add_counter <= 4'd0;
        end
        else begin
            mul_add_counter <= mul_add_counter + 4'd1;
        end
    end
end

always @(*) begin
    case (mul_add_counter)
        4'd0:weights= {2'b11,4'hf};
        4'd1:weights= {2'b11,4'he};
        4'd2:weights= {2'b11,4'hf};
        4'd3:weights= {2'b11,4'hc};
        4'd4:weights= {2'b01,4'h0};
        4'd5:weights= {2'b11,4'hc};
        4'd6:weights= {2'b11,4'hf};
        4'd7:weights= {2'b11,4'he};
        default:weights= {2'b11,4'hf};
    endcase
end

assign mul_result = $signed(idata) * weights;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        psum <= 22'd0;
    end
    else if(current_state==L0) begin
        if(L0_current_state==L0_MUL_ADD) begin
            psum <= psum + mul_result;
        end
        else begin
            psum <= 22'h3FFF40;
        end
    end
    else begin
        psum <= 22'h3FFF40;
    end
end

always @(*) begin
    if(psum[21]) begin
        layer0_D = 16'd0;
    end
    else begin
        layer0_D = {psum[19:4]};
    end
end

assign layer0_web = ~(L0_current_state==L0_WRITE);
assign layer0_ceb = 1'b1;
assign ROM_rd = (current_state==L0);
assign L0_done = (L0_current_state==L0_DONE);
assign done = (current_state==DONE);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_x <= 6'd0;
    end
    else if(current_state==L0)begin
        if(L0_current_state==L0_DONE) begin
            op_x <= 6'd0;
        end
        else if(L0_current_state==L0_WRITE) begin
            if(L0_next_state==L0_DONE) begin
                op_x <= op_x;
            end
            else begin
                case (op_control)
                    2'b01,2'b11: op_x <= op_x + 6'd1;
                endcase
            end
        end
    end
end 

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_y <= 6'd0;
    end
    else if(current_state==L0)begin
        if(L0_current_state==L0_DONE) begin
            op_y <= 6'd0;
        end
        else if(L0_current_state==L0_WRITE)begin
            if(L0_next_state==L0_DONE) begin
                op_y <= op_y;
            end
            else begin
                case (op_control)
                    2'b00:op_y <= (op_y + 6'd1);
                    2'b10:op_y <= (op_y - 6'd1); 
                    2'b11:op_y <= (op_x==6'd63)? (op_y + 6'd2) : op_y;
                endcase
            end
        end
    end
end 

always @(posedge clk or posedge rst) begin
    if(rst) begin
        layer0_A = 12'd0;
    end
    else if(L0_current_state==L0_MUL_ADD) begin
        layer0_A = {op_y,op_x};
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        op_control <= 2'd0;
    end
    else if(L0_current_state==L0_WRITE)begin
        op_control <= op_control + 2'd1;
    end
end



always @(posedge clk or posedge rst) begin
    if(rst) begin
        max <= 15'd0;
    end
    else if(L0_current_state==L0_WRITE) begin
        max <= (layer0_D>max)? layer0_D:max;
    end
    else if(L0_current_state==L0_MUL_ADD&&op_control==2'd0) begin
        max <= 15'd0;
    end
end



assign layer1_A = {2'b00,op_max_pool_y,op_max_pool_x};
assign layer1_ceb = 1'b1;
assign layer1_web = (~(L0_current_state==L0_MAX_POOL))&~(L0_current_state==L0_DONE);
assign layer1_D = (|max[3:0])? max_plus_one:max;
assign max_plus_one = {max[15:4],4'd0} + 5'b10000;


always @(posedge clk) begin
    if(L0_current_state==L0_WRITE) begin
        op_max_pool_x <= op_x[5:1];
        op_max_pool_y <= op_y[5:1];
    end
end


endmodule
