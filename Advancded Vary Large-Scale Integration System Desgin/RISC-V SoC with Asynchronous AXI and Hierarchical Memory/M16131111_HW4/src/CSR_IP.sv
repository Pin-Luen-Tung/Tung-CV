module CSR_IP(
    input pipe_freeze,
    input clk,
    input rst,
    input i_csr_barnch_exe,
    input [1:0] i_csr_sel,
    input i_csr_stall,
    output logic [31:0] o_csr_data
);

logic [63:0] cycle;
logic [63:0] cycle_ID;
logic [63:0] instret;
logic [63:0] instret_ID; 

    always_ff @(posedge clk or posedge rst)begin
            if(rst) begin 
                cycle <= 64'd0;
            end
            else begin
                cycle <= cycle + 64'd1;
            end
        end
    always_ff @(posedge clk or posedge rst)begin
            if(rst) begin
                cycle_ID <= 64'd0;
            end
            else begin
                cycle_ID <= cycle;
            end
    end
    


    always_ff @(posedge clk or posedge rst)begin
        if(rst) begin
            instret <= 64'd0;
        end
        else begin
            instret <= (i_csr_stall | pipe_freeze)? instret : (i_csr_barnch_exe)? (instret-64'd1) : (instret+64'd1);
        end
    end
    always_ff @(posedge clk or posedge rst)begin
        if(rst) begin
            instret_ID <= 64'd0;
        end
        else begin
            instret_ID <= instret;
        end
    end

    always_comb begin
        case (i_csr_sel)
            0:begin
                o_csr_data = instret_ID[63:32];
            end
            1:begin
                o_csr_data = instret_ID[31:0];
            end
            2:begin
                o_csr_data = cycle_ID[63:32];
            end
            3:begin
                o_csr_data = cycle_ID[31:0];
            end 
            default:begin
                o_csr_data = 32'd0;
            end 
        endcase
    end

endmodule