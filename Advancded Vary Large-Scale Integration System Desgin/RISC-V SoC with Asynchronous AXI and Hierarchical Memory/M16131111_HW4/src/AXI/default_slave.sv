module default_slave(
// AXI slave
  input ACLK,
  input ARESETn,

  //read addr
  input [`AXI_IDS_BITS-1 :0] ARID,
  input [`AXI_LEN_BITS-1 :0] ARLEN,
  input ARVALID,
  output logic ARREADY,

  //read data
  output logic [`AXI_IDS_BITS-1 :0] RID,
  output logic [1:0] RRESP,
  output logic RLAST,
  output logic RVALID,
  input RREADY,

  //write addr
  input [`AXI_IDS_BITS-1 :0] AWID,
  input [`AXI_LEN_BITS-1 :0] AWLEN,
  input AWVALID,
  output logic AWREADY,
  //write data
  input WLAST,
  input WVALID,
  output logic WREADY,
  //write responce
  output logic [`AXI_IDS_BITS-1:0] BID,
  output logic [1:0] BRESP,
  output logic BVALID,
  input BREADY
);
// input register AR
  logic[`AXI_IDS_BITS-1:0] ARID_r;
  logic[`AXI_LEN_BITS-1:0] ARLEN_r;

// input register AW
  logic [`AXI_IDS_BITS-1:0] AWID_r;
  logic [`AXI_LEN_BITS-1:0] AWLEN_r;
// flag
  logic read_trans;
  logic write_trans;
 
  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) read_trans <= 1'b0;
    else if(ARREADY & ARVALID) read_trans <= 1'b1;
    else if(RREADY & RLAST & RVALID) read_trans <= 1'b0;
  end
  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) write_trans <= 1'b0;
    else if(AWREADY & AWVALID) write_trans <= 1'b1;
    else if(WREADY & WLAST & WVALID) write_trans <= 1'b0;
  end
// counter
  logic [`AXI_LEN_BITS-1 :0] r_burst_count;

  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) r_burst_count <= {`AXI_LEN_BITS{1'b0}};
    else if(ARREADY & ARVALID) r_burst_count <= {`AXI_LEN_BITS{1'b0}};
    else if(RREADY & RVALID) r_burst_count <= r_burst_count + 1'b1;
  end

// read reg
  always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(~ARESETn)begin
          ARID_r   <= {`AXI_IDS_BITS{1'b0}};
          ARLEN_r  <= {`AXI_LEN_BITS{1'b0}};
      end
      else if(ARVALID & ARREADY)begin
          ARID_r   <= ARID;
          ARLEN_r  <= ARLEN;
      end
  end
// write reg
  always_ff @( posedge ACLK or negedge  ARESETn ) begin 
      if(~ARESETn)begin
          AWID_r   <= {`AXI_IDS_BITS{1'b0}};
          AWLEN_r  <= {`AXI_LEN_BITS{1'b0}};
      end
      else if(AWVALID & AWREADY)begin
          AWID_r   <= AWID;
          AWLEN_r  <= AWLEN;
      end
  end
// output 
/*--------AR--------*/
// ARREADY
  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) ARREADY <= 1'b0;
    else if(~read_trans & ARVALID) ARREADY <= (ARREADY)? 1'b0 : 1'b1;
  end
/*-------- R--------*/
  assign RID = ARID_r;
  assign RRESP = 2'b11;
// RLAST,
  assign RLAST = (r_burst_count == ARLEN_r);
// RVALID,
  assign RVALID = read_trans;
/*--------AW--------*/
// AWREADY
  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) AWREADY <= 1'b0;
    else if(~write_trans & AWVALID) AWREADY <= (AWREADY)? 1'b0 : 1'b1;
  end
/*-------- W--------*/
// WREADY
  assign WREADY = write_trans;
/*-------- B--------*/
  assign BID = AWID_r;
  assign BRESP = 2'b11; //DECERR
// BVALID,
  always_ff @( posedge ACLK or negedge ARESETn ) begin
    if(~ARESETn) BVALID <= 1'b0;
    else if(WREADY & WLAST & WVALID) BVALID <= 1'b1;
    else if(BVALID & BREADY) BVALID <= 1'b0;
  end
endmodule