module arbiter(
    input clk,
    input rst_n,
    input [1:0] valid,
    input [1:0] ready,
    output [1:0] grant
);
/*
    Round robin arbiter for D0, D1 device
    default priority is D0 > D1
*/
    logic [1:0] cstate, nstate;
    logic prev_device;

    localparam STATE_IDLE = 2'b00;
    localparam STATE_D0   = 2'b01;
    localparam STATE_D1   = 2'b10;

    always_ff @( posedge clk or negedge rst_n ) begin
        if(~rst_n) cstate <= STATE_IDLE;
        else cstate <= nstate;
    end

    always_comb begin
        case(cstate)
            STATE_IDLE: begin
                case(valid)
                    2'b00: nstate = STATE_IDLE;
                    2'b01: nstate = STATE_D0;
                    2'b10: nstate = STATE_D1;
                    2'b11: nstate = (prev_device)? STATE_D0 : STATE_D1;
                endcase
            end
            STATE_D0: begin
                if(ready == 2'b11) nstate = STATE_IDLE;
                else nstate = STATE_D0;
            end
            STATE_D1: begin
                if(ready == 2'b11) nstate = STATE_IDLE;
                else nstate = STATE_D1;
            end
            default: nstate = STATE_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n)begin
        if(~rst_n) prev_device <= 1'b0;
        else if(cstate == STATE_D0) prev_device <= 1'b0;
        else if(cstate == STATE_D1) prev_device <= 1'b1;
    end

    assign grant[0] = (cstate == STATE_D0);
    assign grant[1] = (cstate == STATE_D1);
endmodule