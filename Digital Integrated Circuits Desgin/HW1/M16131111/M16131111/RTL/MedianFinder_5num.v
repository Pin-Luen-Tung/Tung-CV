module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] min_1;
wire [3:0] min_2;
wire [3:0] min_3;
wire [3:0] min_4;
wire [3:0] max_1;
wire [3:0] max_2;
wire [3:0] max_3;
wire [3:0] max_4;


Comparator2 u1(
	.A(num1),
	.B(num2),
	.min(min_1),
	.max(max_1)
);

Comparator2 u2(
	.A(num3),
	.B(num4),
	.min(min_2),
	.max(max_2)
);

Comparator2 u3(
	.A(min_1),
	.B(min_2),
	.max(max_3),
	.min()
);

Comparator2 u4(
	.A(max_1),
	.B(max_2),
	.max(),
	.min(min_4)
);

MedianFinder_3num u5(
	.num1(max_3),
	.num2(min_4),
	.num3(num5),
	.median(median)
);


endmodule
