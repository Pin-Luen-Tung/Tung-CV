module Comparator2 (
    input   [3:0]   A  ,  
    input   [3:0]   B  ,  
    output  reg [3:0]   min,  
    output  reg [3:0]   max  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////
always @(*) begin
    if(A>B)begin
        max = A;
        min = B;
    end
    else begin
        max = B;
        min = A;
    end
end
endmodule
