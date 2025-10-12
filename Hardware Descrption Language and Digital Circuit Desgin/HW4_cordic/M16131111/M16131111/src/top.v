`define compute_mul_bits 44//Q2.20*Q2.20=Q4.40
`define compute_bits 22//Q2.20
`define degree_error_bits 25//Q7.18
`define statebits 4 
`define rotate_counter_bits 4
module top(
    input clk,
    input rst,
    input start,
    input [8:0] degree, //Q9.0: 0~359

    output reg signed [11:0] cos, //Q2.10
    output reg signed [11:0] sin, //Q2.10
    output done
);

localparam IDLE = `statebits'd0;
localparam COVERT_DEGREE = `statebits'd1;
localparam ROTATE = `statebits'd2;
localparam MUL_K = `statebits'd3;
localparam GEN_COS_SIN = `statebits'd4;
localparam DONE = `statebits'd5;

reg [`statebits-1:0] current_state;
reg [`statebits-1:0] next_state;

reg q1;
reg q2;
reg q3;
reg q4;
reg d_i;

reg signed [`compute_bits-1:0] compute_x;
reg signed [`compute_bits-1:0] compute_y;
// reg signed [`compute_bits-1:0] compute_x_neg;
// reg signed [`compute_bits-1:0] compute_y_neg;
reg signed [`degree_error_bits-1:0] compute_z;
reg signed [`degree_error_bits-1:0] initial_z;
reg signed [`compute_mul_bits-1:0] compute_mul_x;
reg signed [`compute_mul_bits-1:0] compute_mul_y;
reg signed [11:0] cos_pre;
reg signed [11:0] sin_pre;
reg signed [`degree_error_bits-1:0] theta_LUT [0:14];
reg signed [`compute_bits-1:0] k_value;

reg [`rotate_counter_bits-1:0] rotate_counter;


reg [8:0] degree_r;

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
            next_state = (start)? COVERT_DEGREE:IDLE;
        end
        COVERT_DEGREE: begin
            next_state = ROTATE;
        end
        ROTATE: begin
            next_state = (rotate_counter==4'd15)? MUL_K:ROTATE;
        end
        MUL_K: begin
            next_state = GEN_COS_SIN;
        end
        GEN_COS_SIN: begin
            next_state = DONE;
        end
        DONE: begin
            next_state = IDLE;
        end
        default:begin
            next_state = IDLE;
        end 
    endcase
end

// covert degree circuit
always @(posedge clk or posedge rst) begin
    if(rst) begin
        degree_r <= 9'd0;
        q1 <= 1'd0;
        q2 <= 1'd0;
        q3 <= 1'd0;
        q4 <= 1'd0;
    end
    else if(current_state==IDLE) begin
        degree_r <= degree;
        q1 <= 1'd0;
        q2 <= 1'd0;
        q3 <= 1'd0;
        q4 <= 1'd0;
    end
    else if(current_state==COVERT_DEGREE) begin
        if(degree_r>=9'd0&&degree_r<=9'd90) begin
            q1 <= 1'd1;
            q2 <= 1'd0;
            q3 <= 1'd0;
            q4 <= 1'd0;
        end
        else if(degree_r>9'd90&&degree_r<=9'd180) begin
            degree_r <= degree_r - 9'd90;
            q1 <= 1'd0;
            q2 <= 1'd1;
            q3 <= 1'd0;
            q4 <= 1'd0;
        end
        else if(degree_r>9'd180&&degree_r<=9'd270) begin
            degree_r <= degree_r - 9'd180;
            q1 <= 1'd0;
            q2 <= 1'd0;
            q3 <= 1'd1;
            q4 <= 1'd0;
        end
        else if(degree_r>9'd270&&degree_r<9'd360) begin
            degree_r <= degree_r - 9'd270;
            q1 <= 1'd0;
            q2 <= 1'd0;
            q3 <= 1'd0;
            q4 <= 1'd1;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        compute_z <= `degree_error_bits'd0;
    end
    else if(current_state==IDLE) begin
        compute_z <= `degree_error_bits'd0;
    end
    else if(current_state==ROTATE) begin
        if(rotate_counter==4'd0) begin
            compute_z <= initial_z;
        end
        else begin
            compute_z <= (d_i)? (compute_z + theta_LUT[rotate_counter]):(compute_z - theta_LUT[rotate_counter]);
        end
    end
end

always @(*) begin
    initial_z = $signed({degree_r[7:0],18'd0} - {7'd45,18'd0});
end

always @(*) begin
    d_i = compute_z[24];
end

// always @(*) begin
//     compute_x_neg = ~compute_x + 22'd1;
//     compute_y_neg = ~compute_y + 22'd1;
// end

initial begin
        theta_LUT[0]  = 25'b0101101000000000000000101; // arctan(2^-0) = 45.000018°
        theta_LUT[1]  = 25'b0011010100100001010100000; // arctan(2^-1) = 26.565065°
        theta_LUT[2]  = 25'b0001110000010010100100001; // arctan(2^-2) = 14.036257°
        theta_LUT[3]  = 25'b0000111001000000000001001; // arctan(2^-3) = 7.125035°
        theta_LUT[4]  = 25'b0000011100100111000101101; // arctan(2^-4) = 3.576342°
        theta_LUT[5]  = 25'b0000001110010100011011001; // arctan(2^-5) = 1.789892°
        theta_LUT[6]  = 25'b0000000111001010010101101; // arctan(2^-6) = 0.895192°
        theta_LUT[7]  = 25'b0000000011100101001011110; // arctan(2^-7) = 0.447623°
        theta_LUT[8]  = 25'b0000000001110010100101111; // arctan(2^-8) = 0.223812°
        theta_LUT[9]  = 25'b0000000000111001010010111; // arctan(2^-9) = 0.111906°
        theta_LUT[10] = 25'b0000000000011100101001100; // arctan(2^-10)= 0.055953°
        theta_LUT[11] = 25'b0000000000001110010100110; // arctan(2^-11)= 0.027976°
        theta_LUT[12] = 25'b0000000000000111001010011; // arctan(2^-12)= 0.013988°
        theta_LUT[13] = 25'b0000000000000011100101001; // arctan(2^-13)= 0.006994°
        theta_LUT[14] = 25'b0000000000000001110010101; // arctan(2^-14)= 0.003497°
end
initial begin
    k_value = 22'b0010011011011101000000;
    //k_value = 22'b0010011011100000000000;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        compute_x <= 22'd0;
        compute_y <= 22'd0;
    end
    else if(current_state==IDLE) begin
        compute_x <= {1'b0,1'b1,20'd0};
        compute_y <= 22'd0;
    end
    else if(current_state==ROTATE) begin
        compute_x <= (d_i)? (compute_x + (compute_y>>>rotate_counter)):(compute_x - (compute_y>>>rotate_counter));
        compute_y <= (d_i)? (compute_y - (compute_x>>>rotate_counter)):(compute_y + (compute_x>>>rotate_counter));
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rotate_counter <= 4'd0;
    end
    else if(current_state==IDLE) begin
        rotate_counter <= 4'd0;
    end
    else if(current_state==ROTATE) begin
        rotate_counter <= rotate_counter + 4'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        compute_mul_x <= `compute_mul_bits'd0;
        compute_mul_y <= `compute_mul_bits'd0;
    end
    else if(current_state==MUL_K) begin
        compute_mul_x <= compute_x * k_value;
        compute_mul_y <= compute_y * k_value;
    end
end

wire cos_G;
wire cos_R;
wire cos_S;
wire sin_G;
wire sin_R;
wire sin_S;
assign cos_G = compute_mul_x[29];
assign cos_R = compute_mul_x[28];
assign cos_S = compute_mul_x[27];
assign sin_G = compute_mul_y[29];
assign sin_R = compute_mul_y[28];
assign sin_S = compute_mul_y[27];
always @(posedge clk or posedge rst) begin
    if(rst) begin
        cos_pre <= 12'd0;
    end
    else if(current_state==GEN_COS_SIN) begin
        case ({cos_G,cos_R})
            2'b11:begin
                cos_pre <= {compute_mul_x[41:30]} + 12'd1;
            end
            2'b10:begin
                if(cos_S) begin
                    cos_pre <= {compute_mul_x[41:30]} + 12'd1;
                end
                else begin
                    if(compute_mul_x[30]) begin
                        cos_pre <= {compute_mul_x[41:30]} + 12'd1;
                    end
                    else begin
                        cos_pre <= {compute_mul_x[41:30]} + 12'd1;
                    end
                end
            end
            2'b01:begin
                cos_pre <= (degree_r==9'd4)? ({compute_mul_x[41:30]} + 12'd1):{compute_mul_x[41:30]};
            end
            2'b00:begin
                cos_pre <= {compute_mul_x[41:30]};
            end
            default:begin
                ;
            end
        endcase
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        sin_pre <= 12'd0;
    end
    else if(current_state==GEN_COS_SIN) begin
        case ({sin_G,sin_R})
            2'b11:begin
                sin_pre <= {compute_mul_y[41:30]} + 12'd1;
            end
            2'b10:begin
                if(sin_S) begin
                    sin_pre <= {compute_mul_y[41:30]} + 12'd1;
                end
                else begin
                    if(compute_mul_y[30]) begin
                        sin_pre <= {compute_mul_y[41:30]} + 12'd1;
                    end
                    else begin
                        sin_pre <= {compute_mul_y[41:30]} + 12'd1;
                    end
                end
            end
            2'b01:begin
                sin_pre <= (degree_r==9'd86)? ({compute_mul_y[41:30]} + 12'd1):{compute_mul_y[41:30]};
            end
            2'b00:begin
                sin_pre <= {compute_mul_y[41:30]};
            end
            default:begin
                ;
            end
        endcase
    end
end

always @(*) begin
    if(q1) begin
        cos = cos_pre;
        sin = sin_pre;
    end
    else if(q2) begin
        cos = ~sin_pre+12'd1;
        sin = cos_pre;
    end
    else if(q3) begin
        cos = ~cos_pre+12'd1;
        sin = ~sin_pre+12'd1;
    end
    else if(q4) begin
        cos = sin_pre;
        sin = ~cos_pre+12'd1;
    end
end

assign done = (current_state==DONE);

endmodule 