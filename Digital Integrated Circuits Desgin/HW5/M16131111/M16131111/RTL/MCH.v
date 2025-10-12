`define statebits 2
`define cal_area_statebits 3
module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,
    input       [ 7:0]  Y,
    output              Done,
    output      [16:0]  area
);
/////////////////////////////////
// Please write your code here //
/////////////////////////////////
localparam IDLE = `statebits'd0;
localparam RX_DATA = `statebits'd1;
localparam CAL_AREA = `statebits'd2;
localparam DONE = `statebits'd3;


localparam CAL_AREA_IDLE = `cal_area_statebits'd0;
localparam CAL_AREA_CAL_A_VECTOR = `cal_area_statebits'd1;
localparam CAL_AREA_CAL_B_VECTOR = `cal_area_statebits'd2;
localparam CAL_AREA_CAL_A_CROSS_B = `cal_area_statebits'd3;
localparam CAL_AREA_AREA_CAL = `cal_area_statebits'd4;
localparam CAL_AREA_FIND_PNEXT = `cal_area_statebits'd5;
localparam CAL_AREA_AREA_ACCUMULATE = `cal_area_statebits'd6;
localparam CAL_AREA_DONE = `cal_area_statebits'd7;

reg [`statebits-1:0] current_state;
reg [`statebits-1:0] next_state;
reg [`cal_area_statebits-1:0] cal_area_current_state;
reg [`cal_area_statebits-1:0] cal_area_next_state;
reg [7:0] point_x [0:19];
reg [7:0] point_y [0:19];

reg [7:0] X_r;
reg [7:0] Y_r;
reg signed [8:0] A_x;
reg signed [8:0] A_y;
reg signed [8:0] B_x;
reg signed [8:0] B_y;
reg [17:0] B_x_square;
reg [17:0] B_y_square;
wire [18:0] B_square;
wire signed [18:0] A_cross_B;

reg [7:0] minum_x;
reg [7:0] minum_y;
reg [4:0] minum_idx;
reg [7:0] pnext_x;
reg [7:0] pnext_y;
reg [4:0] pnext_idx;
reg [7:0] pcurr_x;
reg [7:0] pcurr_y;
reg [4:0] pcurr_idx;
reg [4:0] rx_cnt;

reg [7:0] sub_i_a_1;
reg [7:0] sub_i_b_1;
wire signed [8:0] sub_o_result_1;
reg [7:0] sub_i_a_2;
reg [7:0] sub_i_b_2;
wire signed [8:0] sub_o_result_2;
reg [4:0] find_next_first_cnt;
reg [19:0] convex_point;
reg signed [8:0] mul_i_a_1;
reg signed [8:0] mul_i_b_1;
wire signed [17:0] mul_o_result_1;
reg signed [8:0] mul_i_a_2;
reg signed [8:0] mul_i_b_2;
wire signed [17:0] mul_o_result_2;


reg [18:0] B_square_max;
reg [16:0] area_accum;

assign sub_o_result_1 = sub_i_a_1 - sub_i_b_1;
assign sub_o_result_2 = sub_i_a_2 - sub_i_b_2;
assign mul_o_result_1 = mul_i_a_1 * mul_i_b_1;
assign mul_o_result_2 = mul_i_a_2 * mul_i_b_2;
assign B_square = B_x_square + B_y_square;
assign A_cross_B = mul_o_result_2 - mul_o_result_1;

always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        mul_i_a_1 = sub_o_result_1;
    end
    else begin
        mul_i_a_1 = A_x;
    end
end

always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        mul_i_b_1 = sub_o_result_1;
    end
    else begin
        mul_i_b_1 = B_y;
    end
end

always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        mul_i_a_2 = sub_o_result_2;
    end
    else begin
        mul_i_a_2 = B_x;
    end
end

always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        mul_i_b_2 = sub_o_result_2;
    end
    else begin
        mul_i_b_2 = A_y;
    end
end


always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_A_VECTOR) begin
        sub_i_a_1 = pnext_x;
        sub_i_b_1 = pcurr_x;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        sub_i_a_1 = point_x[find_next_first_cnt];
        sub_i_b_1 = pcurr_x;
    end
    else if(cal_area_current_state==CAL_AREA_FIND_PNEXT) begin
        sub_i_a_1 = pcurr_x;
        sub_i_b_1 = minum_x;
    end
    else begin
        sub_i_a_1 = pnext_x;
        sub_i_b_1 = minum_x;
    end
end

always @(*) begin
    if(cal_area_current_state==CAL_AREA_CAL_A_VECTOR) begin
        sub_i_a_2 = pnext_y;
        sub_i_b_2 = pcurr_y;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        sub_i_a_2 = point_y[find_next_first_cnt];
        sub_i_b_2 = pcurr_y;
    end
    else if(cal_area_current_state==CAL_AREA_FIND_PNEXT) begin
        sub_i_a_2 = pcurr_y;
        sub_i_b_2 = minum_y;
    end
    else begin
        sub_i_a_2 = pnext_y;
        sub_i_b_2 = minum_y;
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE:begin
            next_state = RX_DATA;
        end 
        RX_DATA:begin
            next_state = (rx_cnt==5'd19)? CAL_AREA:RX_DATA;
        end
        CAL_AREA:begin
            next_state = (cal_area_current_state==CAL_AREA_DONE)? DONE:CAL_AREA;
        end
        DONE:begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        cal_area_current_state <= IDLE;
    end
    else begin
        cal_area_current_state <= cal_area_next_state;
    end
end

always @(*) begin
    case (cal_area_current_state)
        CAL_AREA_IDLE:begin
            cal_area_next_state = (current_state==CAL_AREA)? CAL_AREA_CAL_A_VECTOR:CAL_AREA_IDLE;
        end
        CAL_AREA_CAL_A_VECTOR:begin
            cal_area_next_state = (pnext_idx==minum_idx)? CAL_AREA_DONE:CAL_AREA_CAL_B_VECTOR;
        end
        CAL_AREA_CAL_B_VECTOR:begin
            cal_area_next_state = (find_next_first_cnt==5'd19&&convex_point[find_next_first_cnt])? CAL_AREA_AREA_CAL:(convex_point[find_next_first_cnt])? CAL_AREA_CAL_B_VECTOR:CAL_AREA_CAL_A_CROSS_B;
        end
        CAL_AREA_CAL_A_CROSS_B:begin
            cal_area_next_state = (find_next_first_cnt==5'd19)? CAL_AREA_AREA_CAL:CAL_AREA_CAL_B_VECTOR;
        end
        CAL_AREA_AREA_CAL:begin
            cal_area_next_state = CAL_AREA_FIND_PNEXT;
        end
        CAL_AREA_FIND_PNEXT:begin
            cal_area_next_state = CAL_AREA_AREA_ACCUMULATE;
        end
        CAL_AREA_AREA_ACCUMULATE:begin
            cal_area_next_state = CAL_AREA_CAL_A_VECTOR;
        end
        default:begin
            cal_area_next_state = IDLE;
        end
    endcase
end

always @(posedge clk) begin
    if((cal_area_current_state==CAL_AREA_CAL_A_VECTOR)) begin
        A_x <= 8'd0;
        A_y <= 8'd0;
    end
    else if((cal_area_current_state==CAL_AREA_FIND_PNEXT))begin
        A_x <= sub_o_result_1;
        A_y <= sub_o_result_2;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_CROSS_B) begin
        if(mul_o_result_1>mul_o_result_2) begin
            A_x <= B_x;
            A_y <= B_y;
        end
        else if((mul_o_result_1==mul_o_result_2)&&(B_square>B_square_max)) begin
            A_x <= B_x;
            A_y <= B_y;
        end
    end
end

always @(posedge clk) begin
    if((cal_area_current_state==CAL_AREA_CAL_B_VECTOR)||(cal_area_current_state==CAL_AREA_AREA_CAL)) begin
        B_x <= sub_o_result_1;
        B_y <= sub_o_result_2;
        B_x_square <= mul_o_result_1;
        B_y_square <= mul_o_result_2;
    end
end



always @(posedge clk) begin
    X_r <= X;
    Y_r <= Y;
end


always @(posedge clk) begin
    if(current_state==IDLE) begin
        minum_x <= 8'hff;
        minum_y <= 8'hff;
        minum_idx <= 5'd0;
    end
    else if(current_state==RX_DATA)begin
        if(X_r<minum_x) begin
            minum_x <= X_r;
            minum_y <= Y_r;
            minum_idx <= rx_cnt;
        end
        else if((X_r==minum_x)&&(Y_r<minum_y)) begin
            minum_x <= X_r;
            minum_y <= Y_r;
            minum_idx <= rx_cnt;
        end
    end
end



always @(posedge clk) begin
    if(current_state==IDLE) begin
        B_square_max <= 19'd0;
        pnext_idx <= 5'd21;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_CROSS_B)begin
        if(mul_o_result_1>mul_o_result_2) begin
            B_square_max <= B_square;
            pnext_x <= point_x[find_next_first_cnt];
            pnext_y <= point_y[find_next_first_cnt];
            pnext_idx <= find_next_first_cnt;
        end
        else if((A_cross_B==0)&&(B_square>B_square_max)) begin
            B_square_max <= B_square;
            pnext_x <= point_x[find_next_first_cnt];
            pnext_y <= point_y[find_next_first_cnt];
            pnext_idx <= find_next_first_cnt;
        end
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_VECTOR)begin
        B_square_max <= 19'd0;
    end
end

always @(posedge clk) begin
    if(cal_area_current_state==CAL_AREA_IDLE) begin
        pcurr_x <= minum_x;
        pcurr_y <= minum_y;
        pcurr_idx <= minum_idx;
    end
    else if(cal_area_current_state==CAL_AREA_FIND_PNEXT) begin
        pcurr_x <= pnext_x;
        pcurr_y <= pnext_y;
        pcurr_idx <= pnext_idx;
    end
end



always @(posedge clk or posedge reset) begin
    if(reset) begin
        rx_cnt <= 5'd0;
    end
    else if(current_state==IDLE) begin
        rx_cnt <= 5'd0;
    end
    else if(current_state==RX_DATA) begin
        rx_cnt <= rx_cnt + 5'd1;
    end
end

always @(posedge clk) begin
    point_x[rx_cnt] <= X_r;
    point_y[rx_cnt] <= Y_r;
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        find_next_first_cnt <= 5'd0;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_VECTOR) begin
        find_next_first_cnt <= 5'd0;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_CROSS_B) begin
        find_next_first_cnt <= find_next_first_cnt + 5'd1;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_B_VECTOR) begin
        if(convex_point[find_next_first_cnt]) begin
            find_next_first_cnt <= find_next_first_cnt + 5'd1;
        end
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        convex_point <= 20'd0;
    end
    else if(current_state==IDLE) begin
        convex_point <= 20'd0;
    end
    else if(cal_area_current_state==CAL_AREA_CAL_A_VECTOR) begin
        convex_point[pnext_idx] <= 1'b1;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        area_accum <= 17'd0;
    end
    else if(cal_area_current_state==CAL_AREA_AREA_ACCUMULATE)begin
        area_accum <= area_accum + A_cross_B;
    end
end

assign area = area_accum;
assign Done = (current_state==DONE);

endmodule