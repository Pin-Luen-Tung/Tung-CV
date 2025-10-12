module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);

///////////////////////////////
//	Write Your Design Here ~ //
///////////////////////////////

wire [3:0] num1_1;
wire [3:0] num2_1;
wire [3:0] num7_1;
wire [3:0] num3_1;
wire [3:0] num4_1;
wire [3:0] num5_1;
wire [3:0] num6_1;

wire [3:0] num1_2;
wire [3:0] num2_2;
wire [3:0] num3_2;
wire [3:0] num4_2;
wire [3:0] num5_2;
wire [3:0] num6_2;
wire [3:0] num7_2;


wire [3:0] num1_3;
wire [3:0] num2_3;
wire [3:0] num3_3;
wire [3:0] num4_3;
wire [3:0] num5_3;
wire [3:0] num6_3;
wire [3:0] num7_3;

wire [3:0] num2_4;
wire [3:0] num3_4;
wire [3:0] num4_4;
wire [3:0] num5_4;


wire [3:0] num4_5;
wire [3:0] num5_5;

wire [3:0] num3_6;
Comparator2 u1(
	.A(num1),
	.B(num7),
	.max(num7_1),
	.min(num1_1)
);

Comparator2 u2(
	.A(num3),
	.B(num4),
	.max(num4_1),
	.min(num3_1)
);

Comparator2 u3(
	.A(num5),
	.B(num6),
	.max(num6_1),
	.min(num5_1)
);

Comparator2 u4(
	.A(num5_1),
	.B(num2),
	.max(num5_2),
	.min(num2_1)
);

Comparator2 u5(
	.A(num1_1),
	.B(num3_1),
	.max(num3_2),
	.min(num1_2)
);

Comparator2 u6(
	.A(num7_1),
	.B(num4_1),
	.max(num7_2),
	.min(num4_2)
);

Comparator2 u7(
	.A(num1_2),
	.B(num2_1),
	.max(num2_2),
	.min(num1_3)
);

Comparator2 u8(
	.A(num4_2),
	.B(num5_2),
	.max(num5_3),
	.min(num4_3)
);

Comparator2 u9(
	.A(num3_2),
	.B(num6_1),
	.max(num6_2),
	.min(num3_3)
);

Comparator2 u10(
	.A(num2_2),
	.B(num3_3),
	.max(num3_4),
	.min(num2_3)
);

Comparator2 u11(
	.A(num5_3),
	.B(num7_2),
	.max(num7_3),
	.min(num5_4)
);

Comparator2 u12(
	.A(num3_4),
	.B(num4_3),
	.max(num4_4),
	.min(num3_5)
);

Comparator2 u13(
	.A(num5_4),
	.B(num6_2),
	.max(num6_3),
	.min(num5_5)
);



Comparator2 u14(
	.A(num4_4),
	.B(num5_5),
	.max(num5_6),
	.min(num4_5)
);


assign median = num4_5;
endmodule
