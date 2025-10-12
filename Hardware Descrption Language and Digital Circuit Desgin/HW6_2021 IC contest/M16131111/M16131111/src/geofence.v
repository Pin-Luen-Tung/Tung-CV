`define statebits 3
module geofence (clk,reset,X,Y,valid,is_inside);
input			clk;
input			reset;
input	[10:0]	X;
input	[10:0]	Y;
output			valid;
output			is_inside;


reg [`statebits - 1:0] current_state;
reg [`statebits - 1:0] next_state;
reg [10:0] X_reg;
reg [10:0] Y_reg;

always @(posedge clk ) begin
    X_reg <= X;
    Y_reg <= Y;
end

reg signed [10:0] X_TEST;
reg signed [10:0] Y_TEST;
reg signed [10:0] X_PENTAGON [0:4];
reg signed [10:0] Y_PENTAGON [0:4];
reg signed [10:0] X_SORT [0:4];
reg signed [10:0] Y_SORT [0:4];
reg signed [11:0] vector_x [0:3];
reg signed [11:0] vector_y [0:3];
reg signed [11:0] vector_x_test [0:4];
reg signed [11:0] vector_y_test [0:4];
reg signed [11:0] vector_x_sort [0:4];
reg signed [11:0] vector_y_sort [0:4];
reg [4:0] postive;
reg [4:0] negative;
reg [2:0] rx_counter;
reg [2:0] vector_counter;
reg signed [10:0] sub_i_a_x;
reg signed [10:0] sub_i_b_x;
wire signed [11:0] sub_o_result_x;
reg signed [10:0] sub_i_a_y;
reg signed[10:0] sub_i_b_y;
wire signed [11:0] sub_o_result_y;
reg signed [11:0] mul_i_a;
reg signed [11:0] mul_i_b;
reg signed [22:0] mul_o_result;
reg signed [22:0] AxBy;
reg signed [22:0] BxAy;
reg [2:0] sort_index;
reg [1:0] cross_counter;
reg [2:0] cross_less_zero;
reg [2:0] accumlate_counter;
reg [2:0] b_index;
reg [2:0] vector_sort_counter;
reg [2:0] test_counter;

localparam IDLE = `statebits'd0;
localparam RX_DATA = `statebits'd1;
localparam CAL_VECTOR = `statebits'd2;
localparam SORT = `statebits'd3;
localparam CAL_SORT_VECTOR = `statebits'd4;
localparam TEST = `statebits'd5;
localparam DONE = `statebits'd6;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

assign valid = (current_state==DONE);
assign is_inside = &postive | &negative;

always @(*) begin
    case (current_state)
        IDLE: next_state = RX_DATA;
        RX_DATA: next_state = (rx_counter==3'd6)? CAL_VECTOR:RX_DATA;    
        CAL_VECTOR: next_state = (vector_counter==3'd4)? SORT:CAL_VECTOR;
        SORT: next_state = (sort_index==3'd4)? CAL_SORT_VECTOR:SORT;
        CAL_SORT_VECTOR: next_state = (vector_sort_counter==3'd5)? TEST:CAL_SORT_VECTOR;
        TEST: next_state = (test_counter==3'd5)? DONE:TEST;
        DONE: next_state = IDLE;
        default: next_state = RX_DATA;
    endcase
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        rx_counter <= 3'd0;
    end
    else if(current_state==RX_DATA)begin
        rx_counter <= rx_counter + 3'd1;
    end
    else begin
        rx_counter <= 3'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        vector_counter <= 3'd0;
    end
    else if(current_state==CAL_VECTOR) begin
        vector_counter <= vector_counter + 3'd1;
    end
    else begin
        vector_counter <= 3'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        test_counter <= 3'd0;
    end
    else if(current_state==TEST) begin
        test_counter <= (cross_counter==2'd2)? (test_counter + 3'd1):test_counter;
    end
    else begin
        test_counter <= 3'd0;
    end
end 

always @(posedge clk or posedge reset) begin
    if(reset) begin
        vector_sort_counter <= 3'd0;
    end
    else if(current_state==CAL_SORT_VECTOR) begin
        vector_sort_counter <= vector_sort_counter + 3'd1;
    end
    else begin
        vector_sort_counter <= 3'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        X_TEST <= 11'd0;
        Y_TEST <= 11'd0;
    end
    else if(current_state==RX_DATA) begin
        if(rx_counter==3'd0) begin
            X_TEST <= X_reg;
            Y_TEST <= Y_reg;
        end
        else begin
            X_PENTAGON[rx_counter-3'd1] <= X_reg;
            Y_PENTAGON[rx_counter-3'd1] <= Y_reg;
        end
    end 
    else if(current_state==SORT) begin
            X_SORT[0] <= X_PENTAGON[0];
            Y_SORT[0] <= Y_PENTAGON[0];
        if(accumlate_counter==3'd3) begin
            X_SORT[cross_less_zero+3'd1] <= X_PENTAGON[sort_index+3'd1];
            Y_SORT[cross_less_zero+3'd1] <= Y_PENTAGON[sort_index+3'd1];
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(current_state==CAL_VECTOR) begin
        vector_x[vector_counter] <= sub_o_result_x;
        vector_y[vector_counter] <= sub_o_result_y;
    end
end

always @(*) begin
    if(current_state==CAL_VECTOR) begin
        sub_i_b_x = X_PENTAGON[0];
        sub_i_b_y = Y_PENTAGON[0];
    end
    else if(current_state==SORT) begin
        sub_i_b_x = X_TEST;
        sub_i_b_y = Y_TEST;
    end
    else if(current_state==CAL_SORT_VECTOR) begin
        sub_i_b_x = X_SORT[vector_sort_counter];
        sub_i_b_y = Y_SORT[vector_sort_counter];
    end
    else begin
        sub_i_b_x = 12'd0;
        sub_i_b_y = 12'd0;
    end
end

always @(*) begin
    if(current_state==CAL_VECTOR) begin
        sub_i_a_x = X_PENTAGON[vector_counter+3'd1];
        sub_i_a_y = Y_PENTAGON[vector_counter+3'd1];
    end
    else if(current_state==SORT) begin
        if(accumlate_counter==3'd3) begin
            sub_i_a_x = X_PENTAGON[sort_index+3'd1];
            sub_i_a_y = Y_PENTAGON[sort_index+3'd1];
        end
        else begin
            sub_i_a_x = X_PENTAGON[0];
            sub_i_a_y = Y_PENTAGON[0];
        end
    end
    else if(current_state==CAL_SORT_VECTOR) begin
        if(vector_sort_counter==3'd4) begin
            sub_i_a_x = X_SORT[0];
            sub_i_a_y = Y_SORT[0];
        end
        else begin
            sub_i_a_x = X_SORT[vector_sort_counter+3'd1];
            sub_i_a_y = Y_SORT[vector_sort_counter+3'd1];
        end
    end
    else begin
        sub_i_a_x = 12'd0;
        sub_i_a_y = 12'd0;
    end
end

always @(*) begin
    b_index = ((sort_index+accumlate_counter)>3'd2)? (sort_index+accumlate_counter-3'd3):(sort_index+accumlate_counter+3'd1);
end

always @(*) begin
    if(current_state==SORT) begin
        if(cross_counter==2'd0) begin
            mul_i_a = vector_x[sort_index];
            mul_i_b = vector_y[b_index];
        end
        else begin
            mul_i_a = vector_x[b_index];
            mul_i_b = vector_y[sort_index];
        end
    end
    else begin
        if(cross_counter==2'd0) begin
            mul_i_a = vector_x_test[test_counter];
            mul_i_b = vector_y_sort[test_counter];
        end
        else begin
            mul_i_a = vector_x_sort[test_counter];
            mul_i_b = vector_y_test[test_counter];
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        postive <= 6'd0;
    end
    else if(current_state==TEST) begin
        if(cross_counter==2'd2) begin
            postive[test_counter] <= (AxBy>BxAy);
        end
    end
    else if(current_state==RX_DATA) begin
        postive <= 6'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        negative <= 6'd0;
    end
    else if(current_state==TEST) begin
        if(cross_counter==2'd2) begin
            negative[test_counter] <= (AxBy<BxAy);
        end
    end
    else if(current_state==RX_DATA) begin
        negative <= 6'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        AxBy <= 23'd0;
    end
    else if(cross_counter==2'd0) begin
        AxBy <= mul_o_result;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        BxAy <= 23'd0;
    end
    else if(cross_counter==2'd1) begin
        BxAy <= mul_o_result;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        cross_counter <= 2'd0;
    end
    else if(current_state==SORT) begin
        if(accumlate_counter==3'd3) begin
            cross_counter <= 2'd0;
        end
        else begin
            cross_counter <= (cross_counter==2'd2)? 2'd0:(cross_counter+2'd1);
        end
    end
    else if(current_state==TEST) begin
        cross_counter <= (cross_counter==2'd2)? 2'd0:(cross_counter+2'd1);
    end
    else begin
        cross_counter <= 2'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(current_state==SORT) begin
        if(accumlate_counter==3'd3) begin
            vector_x_test[cross_less_zero+3'd1] <= sub_o_result_x;
            vector_y_test[cross_less_zero+3'd1] <= sub_o_result_y;
        end
        else begin
            vector_x_test[0] <= sub_o_result_x;
            vector_y_test[0] <= sub_o_result_y;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(current_state==CAL_SORT_VECTOR) begin
        vector_x_sort[vector_sort_counter] <= sub_o_result_x;
        vector_y_sort[vector_sort_counter] <= sub_o_result_y;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        accumlate_counter <= 3'd0;
    end
    else if(current_state==SORT) begin
        if(cross_counter==2'd2) begin
            accumlate_counter <= accumlate_counter + 3'd1;
        end
        else if(accumlate_counter==3'd3) begin
            accumlate_counter <= 3'd0;
        end
    end
    else begin
        accumlate_counter <= 3'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        sort_index <= 3'd0;
    end
    else if(current_state==SORT) begin
        if(accumlate_counter==3'd3) begin
            sort_index <= sort_index + 3'd1;
        end
    end
    else begin
        sort_index <= 3'd0;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        cross_less_zero <= 3'd0;
    end
    else if(cross_counter==2'd2)begin
        cross_less_zero <= (AxBy<BxAy)? (cross_less_zero+3'd1):cross_less_zero;
    end
    else if(accumlate_counter==3'd3) begin
        cross_less_zero <= 3'd0;
    end
    else if(current_state==RX_DATA) begin
        cross_less_zero <= 3'd0;
    end
end

assign sub_o_result_x = sub_i_a_x - sub_i_b_x;
assign sub_o_result_y = sub_i_a_y - sub_i_b_y;
assign mul_o_result = mul_i_a * mul_i_b;
endmodule