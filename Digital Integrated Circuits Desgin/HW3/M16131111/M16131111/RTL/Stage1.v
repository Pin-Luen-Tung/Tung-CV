module Stage1 #(
    parameter   N = 16,     
    parameter   M = 16,     
    parameter   INT_WIDTH_in = 8, 
    parameter   FRA_WIDTH_in = 8,
    parameter   INT_WIDTH_out = 8,
    parameter   FRA_WIDTH_out = 16
)(
    input               clk, 
    input               rst,  
    input               di_en,  
    input   [INT_WIDTH_in+FRA_WIDTH_in-1:0] di_re,  
    input   [INT_WIDTH_in+FRA_WIDTH_in-1:0] di_im,  
    output              do_en,  
    output  [INT_WIDTH_out+FRA_WIDTH_out-1:0] do_re,  
    output  [INT_WIDTH_out+FRA_WIDTH_out-1:0] do_im  
);

localparam WIDTH_STAGE_1 = INT_WIDTH_in+FRA_WIDTH_in;
localparam WIDTH_STAGE_2 = INT_WIDTH_out+FRA_WIDTH_out;


//  log2 constant function
function integer log2;
    input integer x;
    integer value;
    begin
        value = x-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

localparam  LOG_N = log2(N);    
localparam  LOG_M = log2(M);    


reg [LOG_N-1:0] di_count;   
wire            bf1_bf;    
wire[WIDTH_STAGE_1-1:0] bf1_x0_re; 
wire[WIDTH_STAGE_1-1:0] bf1_x0_im; 
wire[WIDTH_STAGE_1-1:0] bf1_x1_re;  
wire[WIDTH_STAGE_1-1:0] bf1_x1_im;  
wire[WIDTH_STAGE_1-1:0] bf1_y0_re;  
wire[WIDTH_STAGE_1-1:0] bf1_y0_im; 
wire[WIDTH_STAGE_1-1:0] bf1_y1_re; 
wire[WIDTH_STAGE_1-1:0] bf1_y1_im; 
wire[WIDTH_STAGE_1-1:0] db1_di_re;  
wire[WIDTH_STAGE_1-1:0] db1_di_im; 
wire[WIDTH_STAGE_1-1:0] db1_do_re;  
wire[WIDTH_STAGE_1-1:0] db1_do_im;
wire[WIDTH_STAGE_1-1:0] bf1_sp_re;  
wire[WIDTH_STAGE_1-1:0] bf1_sp_im;  
reg             bf1_sp_en;  
reg [LOG_N-1:0] bf1_count; 
wire            bf1_start;  
wire            bf1_end;   
wire            bf1_mj;    
reg [WIDTH_STAGE_1-1:0] bf1_do_re;  
reg [WIDTH_STAGE_1-1:0] bf1_do_im;  


reg             bf2_bf;    
wire[WIDTH_STAGE_1-1:0] bf2_x0_re;  
wire[WIDTH_STAGE_1-1:0] bf2_x0_im; 
wire[WIDTH_STAGE_1-1:0] bf2_x1_re;  
wire[WIDTH_STAGE_1-1:0] bf2_x1_im;  
wire[WIDTH_STAGE_1-1:0] bf2_y0_re;  
wire[WIDTH_STAGE_1-1:0] bf2_y0_im; 
wire[WIDTH_STAGE_1-1:0] bf2_y1_re; 
wire[WIDTH_STAGE_1-1:0] bf2_y1_im; 
wire[WIDTH_STAGE_1-1:0] db2_di_re;  
wire[WIDTH_STAGE_1-1:0] db2_di_im;  
wire[WIDTH_STAGE_1-1:0] db2_do_re;  
wire[WIDTH_STAGE_1-1:0] db2_do_im; 
wire[WIDTH_STAGE_1-1:0] bf2_sp_re;  
wire[WIDTH_STAGE_1-1:0] bf2_sp_im;  
reg             bf2_sp_en; 
reg [LOG_N-1:0] bf2_count; 
reg             bf2_start; 
wire            bf2_end;   
reg [WIDTH_STAGE_1-1:0] bf2_do_re;  
reg [WIDTH_STAGE_1-1:0] bf2_do_im;  
reg             bf2_do_en; 
//  Multiplication
wire[1:0]       tw_sel;     
wire[LOG_N-3:0] tw_num;  
wire[LOG_N-1:0] tw_addr;    
wire[15:0] tw_re;      
wire[15:0] tw_im;      
reg             mu_en;     
wire[WIDTH_STAGE_1-1:0] mu_a_re;    
wire[WIDTH_STAGE_1-1:0] mu_a_im;    
wire[WIDTH_STAGE_2-1:0] mu_m_re;   
wire[WIDTH_STAGE_2-1:0] mu_m_im;   
reg [WIDTH_STAGE_2-1:0] mu_do_re;  
reg [WIDTH_STAGE_2-1:0] mu_do_im;  
reg             mu_do_en;   




always @(posedge clk or posedge rst) begin
    if (rst) begin
        di_count <= {LOG_N{1'b0}};
    end else begin
        di_count <= di_en ? (di_count + 1'b1) : di_count;
    end
end
assign  bf1_bf = di_count[LOG_M-1];


assign  bf1_x0_re = bf1_bf ? db1_do_re : {WIDTH_STAGE_1{1'b0}};
assign  bf1_x0_im = bf1_bf ? db1_do_im : {WIDTH_STAGE_1{1'b0}};
assign  bf1_x1_re = bf1_bf ? di_re : {WIDTH_STAGE_1{1'b0}};
assign  bf1_x1_im = bf1_bf ? di_im : {WIDTH_STAGE_1{1'b0}};

Butterfly #(
    .INT_WIDTH(INT_WIDTH_in),
    .FRA_WIDTH(FRA_WIDTH_in)
) 
BF1 
(
    .x0_re  (bf1_x0_re  ),  
    .x0_im  (bf1_x0_im  ),  
    .x1_re  (bf1_x1_re  ),  
    .x1_im  (bf1_x1_im  ),  
    .y0_re  (bf1_y0_re  ),  
    .y0_im  (bf1_y0_im  ),  
    .y1_re  (bf1_y1_re  ),  
    .y1_im  (bf1_y1_im  )   
);

DelayBuffer #(
    .DEPTH(2**(LOG_M-1)),
    .INT_WIDTH(INT_WIDTH_in),
    .FRA_WIDTH(FRA_WIDTH_in)
) 
DB1 
(
    .clk  (clk      ),  
    .stall  (1'b0),
    .di_re  (db1_di_re  ),  
    .di_im  (db1_di_im  ),  
    .do_re  (db1_do_re  ),  
    .do_im  (db1_do_im  )   
);

assign  db1_di_re = bf1_bf ? bf1_y1_re : di_re;
assign  db1_di_im = bf1_bf ? bf1_y1_im : di_im;
assign  bf1_sp_re = bf1_bf ? bf1_y0_re : bf1_mj ?  db1_do_im : db1_do_re;
assign  bf1_sp_im = bf1_bf ? bf1_y0_im : bf1_mj ? -db1_do_re : db1_do_im;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bf1_sp_en <= 1'b0;
        bf1_count <= {LOG_N{1'b0}};
    end 
    else if(di_en)begin
        bf1_sp_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_sp_en;
        bf1_count <= bf1_sp_en ? (bf1_count + 1'b1) : {LOG_N{1'b0}};
    end
end
assign  bf1_start = (di_count == (2**(LOG_M-1)-1));
assign  bf1_end = (bf1_count == (2**LOG_N-1));
assign  bf1_mj = (bf1_count[LOG_M-1:LOG_M-2] == 2'd3);

always @(posedge clk) begin
    bf1_do_re <= bf1_sp_re;
    bf1_do_im <= bf1_sp_im;
end




always @(posedge clk) begin
    bf2_bf <= bf1_count[LOG_M-2];
end


assign  bf2_x0_re = bf2_bf ? db2_do_re : {WIDTH_STAGE_1{1'b0}};
assign  bf2_x0_im = bf2_bf ? db2_do_im : {WIDTH_STAGE_1{1'b0}};
assign  bf2_x1_re = bf2_bf ? bf1_do_re : {WIDTH_STAGE_1{1'b0}};
assign  bf2_x1_im = bf2_bf ? bf1_do_im : {WIDTH_STAGE_1{1'b0}};


Butterfly #(
    .INT_WIDTH(INT_WIDTH_in),
    .FRA_WIDTH(FRA_WIDTH_in)
)
BF2 
(
    .x0_re  (bf2_x0_re  ),  
    .x0_im  (bf2_x0_im  ),  
    .x1_re  (bf2_x1_re  ),  
    .x1_im  (bf2_x1_im  ),  
    .y0_re  (bf2_y0_re  ),  
    .y0_im  (bf2_y0_im  ),  
    .y1_re  (bf2_y1_re  ),  
    .y1_im  (bf2_y1_im  )   
);

DelayBuffer #(
    .DEPTH(2**(LOG_M-2)),
    .INT_WIDTH(INT_WIDTH_in),
    .FRA_WIDTH(FRA_WIDTH_in)
) 
DB2 
(
    .clk  (clk      ), 
    .stall  (1'b0),
    .di_re  (db2_di_re  ),  
    .di_im  (db2_di_im  ), 
    .do_re  (db2_do_re  ),  
    .do_im  (db2_do_im  )   
);

assign  db2_di_re = bf2_bf ? bf2_y1_re : bf1_do_re;
assign  db2_di_im = bf2_bf ? bf2_y1_im : bf1_do_im;
assign  bf2_sp_re = bf2_bf ? bf2_y0_re : db2_do_re;
assign  bf2_sp_im = bf2_bf ? bf2_y0_im : db2_do_im;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bf2_sp_en <= 1'b0;
        bf2_count <= {LOG_N{1'b0}};
    end else begin
        bf2_sp_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_sp_en;
        bf2_count <= bf2_sp_en ? (bf2_count + 1'b1) : {LOG_N{1'b0}};
    end
end

always @(posedge clk) begin
    bf2_start <= (bf1_count == (2**(LOG_M-2)-1)) & bf1_sp_en;
end
assign  bf2_end = (bf2_count == (2**LOG_N-1));

always @(posedge clk) begin
    bf2_do_re <= bf2_sp_re;
    bf2_do_im <= bf2_sp_im;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bf2_do_en <= 1'b0;
    end else begin
        bf2_do_en <= bf2_sp_en;
    end
end



assign  tw_sel[1] = bf2_count[LOG_M-2];
assign  tw_sel[0] = bf2_count[LOG_M-1];
assign  tw_num = bf2_count << (LOG_N-LOG_M);
assign  tw_addr = tw_num * tw_sel;

Twiddle TW (
    .clk  (clk  ),  
    .addr   (tw_addr),  
    .tw_re  (tw_re  ), 
    .tw_im  (tw_im  )   
);


always @(posedge clk) begin
    mu_en <= (tw_addr != {LOG_N{1'b0}});
end

assign  mu_a_re = mu_en ? bf2_do_re : {WIDTH_STAGE_1{1'b0}};
assign  mu_a_im = mu_en ? bf2_do_im : {WIDTH_STAGE_1{1'b0}};

Multiply #(
    .INT_WIDTH_in(INT_WIDTH_in),
    .FRA_WIDTH_in(FRA_WIDTH_in)
)
MU 
(
    .a_re   (mu_a_re),  
    .a_im   (mu_a_im),  
    .b_re   (tw_re  ),  
    .b_im   (tw_im  ), 
    .m_re   (mu_m_re), 
    .m_im   (mu_m_im)  
);

always @(posedge clk) begin
	mu_do_re <= mu_en ? mu_m_re : {bf2_do_re,8'd0};
    mu_do_im <= mu_en ? mu_m_im : {bf2_do_im,8'd0};
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mu_do_en <= 1'b0;
    end else begin
        mu_do_en <= bf2_do_en;
    end
end


assign  do_en = mu_do_en;
assign  do_re = mu_do_re;
assign  do_im = mu_do_im;


endmodule