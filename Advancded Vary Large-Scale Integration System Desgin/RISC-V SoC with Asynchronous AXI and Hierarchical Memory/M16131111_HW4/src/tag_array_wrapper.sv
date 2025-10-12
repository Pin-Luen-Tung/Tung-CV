module tag_array_wrapper (
  input CK,
  input CS,
  input OE,
  input WEB,
  input [4:0] A,
  input [22:0] DI,
  input LRU,//0 represent last used is 1
  input write_or_allocate,
  input hit_1,
  input hit_2,
  output [22:0] DO_1,
  output [22:0] DO_2
);
logic  use_1_or_2;// 0 represent write 2 , 1 represent write 1
logic WEB_1;
logic WEB_2;
logic [31:0] BWEB_1;
logic [31:0] BWEB_2;
logic [31:0] D;
logic [31:0] Q_1;
logic [31:0] Q_2;
assign use_1_or_2 = (hit_1)? 1'b1 : 
                    (hit_2)? 1'b0 : 
                    (LRU)?   1'b1 : 1'b0;
assign WEB_1 = WEB | ~use_1_or_2;
assign WEB_2 = WEB | use_1_or_2;
assign D = {10'b0,DI};
assign DO_1 = Q_1[22:0];
assign DO_2 = Q_2[22:0];
assign BWEB_1 = (WEB_1)? 32'hffff_ffff : 32'd0;
assign BWEB_2 = (WEB_2)? 32'hffff_ffff : 32'd0;
  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array1 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0 ),  // chip enable, active LOW
    .WEB        ( WEB_1 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_1),  // bitwise write enable write:LOW
    .D          ( D ),  // Data into RAM
    .Q          ( Q_1 ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_tag_array i_tag_array2 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0  ),  // chip enable, active LOW
    .WEB        ( WEB_2 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_2 ),  // bitwise write enable write:LOW
    .D          ( D ),  // Data into RAM
    .Q          ( Q_2 ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

endmodule
