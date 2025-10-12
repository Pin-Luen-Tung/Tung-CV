/*********************************   I2C slave  *************************************/

`define statebits 3

module i2c_slave
#( SLAVE_ADDR = 7'b1111_010)
(
    //i
    input clk,
    input rst_n,
    input scl,
    input sda_i,
    input [7:0] i2c_din,
    //o
    output reg sda_o,
    output reg sda_o_en,
    output wr,
    output rd,
    output [7:0] i2c_addr,
    output [7:0] i2c_dout	
); 
//write down your code//

reg [1:0] scl_sync, sda_sync;
reg [7:0] dev_addr;
reg [7:0] reg_addr;
reg [2:0] rx_dev_addr_count;
wire [2:0] rx_dev_addr_count_reverse;
reg [2:0] rx_reg_addr_count;
wire [2:0] rx_reg_addr_count_reverse;
wire dev_match;
reg rx_dev_addr_done;
reg rx_dev_ack_done;
reg rx_reg_addr_done;
reg rx_reg_ack_done;

reg read_write_decision_flag;
reg [7:0] data_to_reg;
reg [7:0] reg_data;
reg [2:0] read_write_decision_count;
reg [2:0] read_write_decision_count_reverse;
reg read_write_decision_done;

reg tx_ack_done;

reg write_done;
reg write_ack_done;
reg read_done;
reg [`statebits-1:0] current_state , next_state;

reg [2:0] tx_reg_count;
wire [2:0] tx_reg_count_reverse;

wire scl_rising  =  (scl_sync == 2'b01);
wire scl_falling =  (scl_sync == 2'b10);
wire sda_rising  =  (sda_sync == 2'b01);
wire sda_falling =  (sda_sync == 2'b10);

localparam IDLE = `statebits'd0;
localparam RX_DEV_ADDR = `statebits'd1;
localparam RX_REG_ADDR = `statebits'd2;
localparam RX_READ_WRITE_DECISION = `statebits'd3;
localparam WRITE_REG = `statebits'd4;
localparam READ_REG = `statebits'd5;
localparam TX_REG_DATA = `statebits'd6;

reg IDLE_start;

assign wr = (current_state==WRITE_REG);
assign rd = (current_state==READ_REG);
assign i2c_addr = reg_addr;
assign i2c_dout = data_to_reg;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        reg_data <= 8'd0;
    end
    else if(current_state==READ_REG) begin
        reg_data <= i2c_din;
    end
end



always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    scl_sync <= 2'b11;
    sda_sync <= 2'b11;
  end else begin
    scl_sync <= {scl_sync[0], scl};
    sda_sync <= {sda_sync[0], sda_i};
  end
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sda_o <= 1'b0;
    end
    else if(current_state==TX_REG_DATA) begin
        if(tx_ack_done) begin
            sda_o <= reg_data[tx_reg_count_reverse];
        end
        else begin
            sda_o <= 1'b0;
        end
    end
    else begin
        sda_o <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        IDLE_start <= 1'b0;
    end
    else if(current_state==IDLE) begin
        if(sda_falling && (scl_sync[1]==1)) begin
            IDLE_start <= 1'b1;
        end
    end
    else begin
        IDLE_start <= 1'b0;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            next_state = (IDLE_start&&scl_falling)? RX_DEV_ADDR:IDLE;
        end
        RX_DEV_ADDR: begin
            next_state = (rx_dev_ack_done&&dev_match)? RX_REG_ADDR:(rx_dev_addr_done&&~dev_match)? IDLE:RX_DEV_ADDR; 
        end
        RX_REG_ADDR: begin
            next_state = (rx_reg_ack_done)? RX_READ_WRITE_DECISION:RX_REG_ADDR;
        end
        RX_READ_WRITE_DECISION: begin
            next_state = (read_write_decision_done)? (read_write_decision_flag)? WRITE_REG:READ_REG:RX_READ_WRITE_DECISION;
        end
        WRITE_REG: begin
            next_state = (write_ack_done==1'b1)? IDLE:WRITE_REG;
        end
        READ_REG: begin
            next_state = (read_done)? TX_REG_DATA:READ_REG;
        end
        TX_REG_DATA: begin
            next_state = (tx_reg_count==3'd7&&scl_falling)? IDLE:TX_REG_DATA; 
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_dev_addr_count <= 3'd0;
    end
    else if(current_state==RX_DEV_ADDR&&scl_falling)begin
        rx_dev_addr_count <= rx_dev_addr_count + 3'd1;
    end
    else if(current_state!=RX_DEV_ADDR)begin
        rx_dev_addr_count <= 3'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_dev_addr_done <= 1'd0;
    end
    else if(current_state==RX_DEV_ADDR)begin
        if(rx_dev_addr_count==3'd7&&scl_falling) begin
            rx_dev_addr_done <= 1'd1;
        end
    end
    else begin
        rx_dev_addr_done <= 1'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_dev_ack_done <=1'b0;
    end
    else if(current_state==RX_DEV_ADDR)begin
        if(rx_dev_addr_done&&dev_match) begin
            if(rx_dev_addr_done) begin
                if(scl_falling) begin
                    rx_dev_ack_done <= 1'b1;
                end
            end
        end
    end
    else begin
        rx_dev_ack_done <=1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sda_o_en <=1'b0;
    end
    else begin
        case (current_state)
            IDLE: sda_o_en <=1'b0;
            RX_DEV_ADDR: sda_o_en <= (rx_dev_addr_done&&dev_match)? 1'b1:1'b0;
            RX_REG_ADDR: sda_o_en <= (rx_reg_addr_done)? 1'b1:1'b0;
            TX_REG_DATA: sda_o_en <= 1'b1;
            WRITE_REG: sda_o_en <= (write_done)? 1'b1:1'b0;
            default: sda_o_en <=1'b0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        dev_addr <= 8'd0;
    end
    else if(current_state==RX_DEV_ADDR)begin
        if(scl_falling&&~rx_dev_addr_done) begin
            dev_addr[rx_dev_addr_count_reverse] <= sda_i; 
        end
    end
end

assign rx_dev_addr_count_reverse = ~rx_dev_addr_count;
assign rx_reg_addr_count_reverse = ~rx_reg_addr_count;
assign read_write_decision_count_reverse = ~read_write_decision_count;
assign dev_match = (dev_addr[7:1]==SLAVE_ADDR);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_reg_addr_count <= 3'd0;
    end
    else if(current_state==RX_REG_ADDR&&scl_falling)begin
        rx_reg_addr_count <= rx_reg_addr_count + 3'd1;
    end
    else if(current_state!=RX_REG_ADDR)begin
        rx_reg_addr_count <= 3'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_reg_addr_done <= 1'd0;
    end
    else if(current_state==RX_REG_ADDR)begin
        if(rx_reg_addr_count==3'd7&&scl_falling) begin
            rx_reg_addr_done <= 1'd1;
        end
    end
    else begin
        rx_reg_addr_done <= 1'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rx_reg_ack_done <=1'b0;
    end
    else if(current_state==RX_REG_ADDR)begin
        if(rx_reg_addr_done) begin
            if(scl_falling) begin
                rx_reg_ack_done <=1'b1;
            end
        end
    end
    else begin
        rx_reg_ack_done <=1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        reg_addr <= 8'd0;
    end
    else if(current_state==RX_REG_ADDR)begin
        if(scl_falling&&~rx_reg_addr_done) begin
            reg_addr[rx_reg_addr_count_reverse] <= sda_i; 
        end
    end
end

reg sub_flag;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        read_write_decision_count <= 3'd0;
        sub_flag <= 1'd0;
    end
    else if(current_state==RX_READ_WRITE_DECISION&&scl_falling)begin
        if(~sub_flag&&~read_write_decision_flag) begin
            read_write_decision_count <= read_write_decision_count;
            sub_flag <= 1'd1;
        end
        else begin
            read_write_decision_count <= read_write_decision_count + 3'd1;
        end
    end
    else if(current_state!=RX_READ_WRITE_DECISION)begin
        read_write_decision_count <= 3'd0;
        sub_flag <= 1'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        read_write_decision_flag <= 1'd1;
    end
    else if(current_state==RX_READ_WRITE_DECISION) begin
        if(sda_falling && (scl_sync[1]==1) && read_write_decision_count==3'd0) begin
            read_write_decision_flag <= 1'd0;
        end
    end
    else begin
        read_write_decision_flag <= 1'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        data_to_reg <= 8'd0;
    end
    else if(current_state==RX_READ_WRITE_DECISION) begin
        if(scl_falling&&~read_write_decision_done) begin
            data_to_reg[read_write_decision_count_reverse] <= sda_i; 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        read_write_decision_done <= 1'd0;
    end
    else if(current_state==RX_READ_WRITE_DECISION)begin
        if(read_write_decision_count==3'd7&&scl_falling) begin
            read_write_decision_done <= 1'd1;
        end
    end
    else begin
        read_write_decision_done <= 1'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        read_done <= 1'b0;
    end
    else if(current_state==READ_REG) begin
        read_done <= 1'b1;
    end
    else begin
        read_done <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        write_done <= 1'b0;
    end
    else if(current_state==WRITE_REG) begin
        write_done <= 1'b1;
    end
    else begin
        write_done <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        write_ack_done <= 1'b0;
    end
    else if(current_state==WRITE_REG)begin
        if(write_done) begin
            if(scl_falling) begin
                write_ack_done <= 1'b1;
            end
        end
    end
    else begin
        write_ack_done <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        tx_reg_count <= 3'd0;
    end
    else if(current_state==TX_REG_DATA&&scl_falling)begin
        if(tx_ack_done) begin
            tx_reg_count <= tx_reg_count + 3'd1;
        end
    end
    else if(current_state!=TX_REG_DATA)begin
        tx_reg_count <= 3'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        tx_ack_done <= 1'b0;
    end
    else if(current_state==TX_REG_DATA) begin
        if(scl_falling) begin
            tx_ack_done <= 1'b1;
        end
    end
    else begin
        tx_ack_done <= 1'b0;
    end
end

assign tx_reg_count_reverse = ~tx_reg_count;

endmodule

