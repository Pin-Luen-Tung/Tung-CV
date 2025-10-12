`define statebiits 2
module top (
                input clk,
                input rst,
                input [4:0] in_data,
                input in_valid,
                output reg [4:0] out_data,
                output reg out_valid
);

localparam IDLE = `statebiits'd0;
localparam RX_ZERO = `statebiits'd1;
localparam RX_LEVEL = `statebiits'd2;
localparam OUT = `statebiits'd3;

reg [4:0] in_data_r;
reg [4:0] OUT_buffer [0:127];
reg [4:0] r_zero_counter;
reg [4:0] r_zero_counter_r;

reg [6:0] out_counter;

reg [2:0] cycle_counter;
reg [6:0] output_counter;

reg [2:0] seven_counter;

reg [`statebiits - 1 : 0] current_state;
reg [`statebiits - 1 : 0] next_state;

wire non_zero;
wire flag_out;
reg flag_out_r;

integer i;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<128;i=i+1) begin
            OUT_buffer[i] <= 5'd0;
        end
        out_counter <= 7'd0;
        seven_counter <= 3'd0;
    end
    else if(current_state==RX_ZERO&&next_state==RX_LEVEL)begin
        OUT_buffer[out_counter] <= r_zero_counter;
        out_counter <= out_counter + 7'd1;
        if(seven_counter==3'd5) begin
            seven_counter <= 3'd0;
        end
        else begin
            seven_counter <= seven_counter + 3'd1;
        end
    end
    else if(current_state==RX_LEVEL&&next_state==RX_ZERO)begin
        OUT_buffer[out_counter] <= in_data_r;
        out_counter <= out_counter + 7'd1;
        if(seven_counter==3'd5) begin
            seven_counter <= 3'd0;
        end
        else begin
            seven_counter <= seven_counter + 3'd1;
        end
    end
    else if(current_state==RX_ZERO&&next_state==RX_ZERO)begin
        if(r_zero_counter==5'd31) begin
            OUT_buffer[out_counter] <= 5'd31;
            OUT_buffer[out_counter+1] <= 5'd0;
            out_counter <= out_counter + 7'd2;
            if(seven_counter==3'd4) begin
                seven_counter <= 3'd0;
            end
            else begin
                seven_counter <= seven_counter + 3'd2;
            end
        end
    end
    else if(current_state==RX_LEVEL&&next_state==RX_LEVEL)begin
        OUT_buffer[out_counter] <= in_data_r;
        OUT_buffer[out_counter+1] <= 5'd0;
        out_counter <= out_counter + 7'd2;
        if(seven_counter==3'd4) begin
            seven_counter <= 3'd0;
        end
        else begin
            seven_counter <= seven_counter + 3'd2;
        end
    end
    else if(next_state == OUT&&current_state != OUT) begin
        case (current_state)
            RX_ZERO:begin
                OUT_buffer[out_counter] <= r_zero_counter;
            end
            RX_LEVEL:begin
                OUT_buffer[out_counter] <= in_data;
            end
        endcase
        //out_counter <= out_counter + 7'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        in_data_r <= 5'd0;
    end
    else begin
        in_data_r <= (in_valid)? in_data:in_data_r;
    end
end



always @(*) begin
    case (current_state)
        IDLE:begin
            next_state = (in_valid)? RX_ZERO:IDLE;
        end
        RX_ZERO:begin
            next_state = (~in_valid)? OUT:(non_zero)? RX_LEVEL:RX_ZERO;
        end
        RX_LEVEL:begin
            next_state = (~in_valid)? OUT:(non_zero)? RX_LEVEL:RX_ZERO;
        end
        OUT:begin
            next_state = (flag_out_r&&(seven_counter==3'd5))? IDLE:((cycle_counter!=6)&&flag_out&&(seven_counter!=3'd5))?IDLE:OUT;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)
    flag_out_r <= 0;
    else 
    flag_out_r <= flag_out;
end

assign flag_out = ((output_counter)==out_counter);
assign non_zero = ~(in_data==5'd0);



always @(posedge clk or posedge rst) begin
    if(rst) begin
        r_zero_counter <= 5'd0;
    end
    else if (current_state==RX_ZERO) begin
        r_zero_counter <=  (r_zero_counter==5'd31)? 5'd1:r_zero_counter + 5'd1;
    end
    else begin 
        r_zero_counter <= 5'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        r_zero_counter_r <= 5'd0;
    end
    else begin
        r_zero_counter_r <=  r_zero_counter;
    end
end


// OUTPUT

always @(posedge clk or posedge rst) begin
    if(rst) begin
        cycle_counter <= 3'd0;
        output_counter <= 7'd0;
        out_data <= 5'd0;
    end
    else if (current_state==OUT) begin
        if(cycle_counter==3'd6) begin
            cycle_counter <= 3'd0;
            output_counter <= output_counter;
            out_data <= ((output_counter-1)==out_counter)? 0:1;
        end
        else begin
            cycle_counter <= cycle_counter + 3'd1;
            output_counter <= output_counter + 7'd1;
            out_data <= OUT_buffer[output_counter];
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= (current_state==OUT);
    end
end

endmodule