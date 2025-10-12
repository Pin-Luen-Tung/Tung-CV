module data_array_wrapper (
  input CK,
  input CS, 
  input OE,
  input [15:0] WEB,
  input [4:0] A,
  input LRU,
  input hit_1,
  input hit_2,
  input [127:0] DI,
  output [127:0] DO_1,
  output [127:0] DO_2
);

logic use_1_or_2;// 0 represent write 2 , 1 represent write 1
logic WEB_1_1;
logic WEB_1_2;
logic WEB_2_1;
logic WEB_2_2;
logic [63:0] BWEB_1_1;
logic [63:0] BWEB_1_2;
logic [63:0] BWEB_2_1;
logic [63:0] BWEB_2_2;
assign use_1_or_2 = (hit_1)? 1'b1 : 
                    (hit_2)? 1'b0 : 
                    (LRU)?   1'b1 : 1'b0;
// 1_1
assign BWEB_1_1 = (use_1_or_2)? {{8{WEB[7]}},
                          {8{WEB[6]}},
                          {8{WEB[5]}},
                          {8{WEB[4]}},
                          {8{WEB[3]}},
                          {8{WEB[2]}},
                          {8{WEB[1]}},
                          {8{WEB[0]}}} : 64'hffff_ffff_ffff_ffff;

assign WEB_1_1 = (use_1_or_2)? &WEB[7:0]:1'b1;

// 1_2
assign BWEB_1_2 = (use_1_or_2)? {{8{WEB[15]}},
                          {8{WEB[14]}},
                          {8{WEB[13]}},
                          {8{WEB[12]}},
                          {8{WEB[11]}},
                          {8{WEB[10]}},
                          {8{WEB[9]}},
                          {8{WEB[8]}}} : 64'hffff_ffff_ffff_ffff;

assign WEB_1_2 = (use_1_or_2)? &WEB[15:8]:1'b1;

// 2_1
assign BWEB_2_1 = (~use_1_or_2)? {{8{WEB[7]}},
                          {8{WEB[6]}},
                          {8{WEB[5]}},
                          {8{WEB[4]}},
                          {8{WEB[3]}},
                          {8{WEB[2]}},
                          {8{WEB[1]}},
                          {8{WEB[0]}}} : 64'hffff_ffff_ffff_ffff;

assign WEB_2_1 = (~use_1_or_2)? &WEB[7:0]:1'b1;

// 2_2
assign BWEB_2_2 = (~use_1_or_2)? {{8{WEB[15]}},
                          {8{WEB[14]}},
                          {8{WEB[13]}},
                          {8{WEB[12]}},
                          {8{WEB[11]}},
                          {8{WEB[10]}},
                          {8{WEB[9]}},
                          {8{WEB[8]}}} : 64'hffff_ffff_ffff_ffff;

assign WEB_2_2 = (~use_1_or_2)? &WEB[15:8]:1'b1;

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_1 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0 ),  // chip enable, active LOW
    .WEB        ( WEB_1_1 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_1_1 ),  // bitwise write enable write:LOW
    .D          ( DI[63:0] ),  // Data into RAM
    .Q          ( DO_1[63:0] ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );
  
  
    TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array1_2 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0 ),  // chip enable, active LOW
    .WEB        ( WEB_1_2 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_1_2 ),  // bitwise write enable write:LOW
    .D          ( DI[127:64] ),  // Data into RAM
    .Q          ( DO_1[127:64] ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );

  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_1 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0 ),  // chip enable, active LOW
    .WEB        ( WEB_2_1 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_2_1 ),  // bitwise write enable write:LOW
    .D          ( DI[63:0] ),  // Data into RAM
    .Q          ( DO_2[63:0] ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );
  
  TS1N16ADFPCLLLVTA128X64M4SWSHOD_data_array i_data_array2_2 (
    .CLK        ( CK ),
    .A          ( A ),
    .CEB        ( 1'b0 ),  // chip enable, active LOW
    .WEB        ( WEB_2_2 ),  // write:LOW, read:HIGH
    .BWEB       ( BWEB_2_2 ),  // bitwise write enable write:LOW
    .D          ( DI[127:64] ),  // Data into RAM
    .Q          ( DO_2[127:64] ),  // Data out of RAM
    .RTSEL      (),
    .WTSEL      (),
    .SLP        (),
    .DSLP       (),
    .SD         (),
    .PUDELAY    ()
  );


endmodule
