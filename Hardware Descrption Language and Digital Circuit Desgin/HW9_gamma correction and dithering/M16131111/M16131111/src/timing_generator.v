module timing_generator(
          
    input             clk,
    input             rst_n,
                    
    input  [11:0]     h_total,
    input  [11:0]     h_size,
    input  [10:0]     h_sync,
    input  [10:0]     h_start,
    input  [10:0]     v_total,
    input  [10:0]     v_size,
    input  [ 9:0]     v_sync,
    input  [ 9:0]     v_start,
    input  [22:0]     vs_reset, 

    output [26:24]    Synco
);

reg [22:0] vs_reset_count;
wire Vsync;
wire Hsync;
wire Den;
reg vs_rst;
wire rst;
wire v_valid;
wire h_valid;

wire [11:0] v_out; 
wire [12:0] h_out;

assign v_out = v_start + v_size;
assign h_out = h_start + h_size;

reg [10:0] v_total_count;
reg [11:0] h_total_count;
assign Synco[26] = Vsync;
assign Synco[25] = Hsync;
assign Synco[24] = Den;

assign v_valid = (v_total_count>=v_start) && (v_total_count<(v_out));
assign h_valid = (h_total_count>=h_start) && (h_total_count<(h_out));
assign Den = v_valid & h_valid;





assign rst = ~rst_n | vs_rst;

assign Vsync = (v_total_count<v_sync);
assign Hsync = (h_total_count<h_sync);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        v_total_count <= 11'd0;
    end
    else if(v_total_count==v_total) begin
        v_total_count <= 11'd0;
    end
    else if(h_total_count==h_total)begin
        v_total_count <= v_total_count + 11'd1;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        h_total_count <= 12'd0;
    end
    else if(h_total_count==h_total) begin
        h_total_count <= 12'd0;
    end
    else begin
        h_total_count <= h_total_count + 12'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        vs_reset_count <= 23'd0;
        vs_rst <= 1'b1;
    end else if (vs_reset == 23'h7FFFFF) begin
        vs_rst <= 1'b0;
    end else if (vs_reset_count < vs_reset) begin
        vs_reset_count <= vs_reset_count + 23'd1;
        vs_rst <= 1'b1;
    end else begin
        vs_rst <= 1'b0;
    end
end



endmodule
