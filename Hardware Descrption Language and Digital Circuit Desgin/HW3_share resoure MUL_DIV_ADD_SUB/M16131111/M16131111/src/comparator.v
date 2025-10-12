module comparator #(
    parameter DATA_WIDTH = 16
)(
    input   [DATA_WIDTH - 1:0]   a  ,  
    input   [DATA_WIDTH - 1:0]   b  ,  
    output  reg [DATA_WIDTH - 1:0]   min,  
    output  reg [DATA_WIDTH - 1:0]   max  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
always @(*) begin
    if(a>b)begin
        max = a;
        min = b;
    end
    else begin
        max = b;
        min = a;
    end
end
endmodule
