module WDT(
    input clk,
    input rst,
    
    input WDEN,
    input WDLIVE,
    input [31:0] WTOCNT,
    output logic WTO
);

logic [31:0] counter;
logic over;

assign over = (counter >= WTOCNT);
assign WTO = (WDEN && over);

always_ff@ (posedge clk) begin
    if(rst)
        counter <= 32'd0;
    else if (!WDEN)
        counter <= 32'd0;
    else if (over)
        counter <= 32'd0;
    else if (WDLIVE)
        counter <= 32'd0;
    else if (WDEN)
        counter <= counter + 32'd1;
    else
        counter <= counter;
end

endmodule