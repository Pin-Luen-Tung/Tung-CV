module arbiter_3M(
    input clk,
    input rst_n,
    input [2:0] valid,
    input [2:0] ready,
    output [2:0] grant
);
/*
    Round robin arbiter for D0,D1,D2evice
    default priority is D0 > D1 > D2
*/
    logic [1:0] current_state;
    logic [1:0] next_state;
    logic [2:0]prev_device;

    localparam IDLE = 2'b00;
    localparam D0   = 2'b01;
    localparam D1   = 2'b10;
    localparam D2   = 2'b11;


    always_ff @( posedge clk or negedge rst_n ) begin
        if(~rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    always_comb begin
        case(current_state)
            IDLE: begin
                case(valid)
                    3'b000: next_state = IDLE;
                    3'b001: next_state = D0;
                    3'b010: next_state = D1;
                    3'b011: next_state = (prev_device[0])? D1 : D0;
                    3'b100: next_state = D2;
                    3'b101: next_state = (prev_device[0])? D2 : D0;
                    3'b110: next_state = (prev_device[1])? D2 : D1;
                    3'b111: begin
                        casex (prev_device)
                            3'b001:next_state = D1;
                            3'b010:next_state = D0;
                            3'b100:next_state = D0;
                            default:next_state = D0;
                        endcase
                    end
                endcase
            end
            D0: begin
                if(ready==3'b111) next_state = IDLE;
                else next_state = D0;
            end
            D1: begin
                if(ready==3'b111) next_state = IDLE;
                else next_state = D1;
            end
            D2: begin
                if(ready==3'b111) next_state = IDLE;
                else next_state = D2;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n)begin
        if(~rst_n) prev_device <= 1'b0;
        else if(current_state == D0) prev_device <= 3'b001;
        else if(current_state == D1) prev_device <= 3'b010;
        else if(current_state == D2) prev_device <= 3'b100;
    end

    assign grant[0] = (current_state == D0);
    assign grant[1] = (current_state == D1);
    assign grant[2] = (current_state == D2);
endmodule