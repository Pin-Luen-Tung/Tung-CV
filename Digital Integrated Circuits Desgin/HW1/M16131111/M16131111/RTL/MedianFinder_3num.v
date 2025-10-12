module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] max_1;
wire [3:0] min_1;
wire [3:0] max_2;
wire [3:0] min_2;


Comparator2 u1(
    .A(num1),
    .B(num2),
    .max(max_1),
    .min(min_1)
);

Comparator2 u2(
    .A(max_1),
    .B(num3),
    .max(max_2),
    .min(min_2)
);



Comparator2 u3(
    .A(min_1),
    .B(min_2),
    .max(median),
    .min()
);


endmodule
