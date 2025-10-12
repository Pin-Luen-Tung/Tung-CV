module BRANCH_DECISION_IP(
    input [31:0] i_branch_data_1,
    input [31:0] i_branch_data_2,
    input [2:0] i_branch_funct3,
    output logic o_branch_decision
);

logic eq;
logic lt;
logic ltu;
 

assign eq = (i_branch_data_1 == i_branch_data_2);
assign ltu = (i_branch_data_1 < i_branch_data_2);
assign lt = ($signed(i_branch_data_1) < $signed(i_branch_data_2));

always_comb begin
    case(i_branch_funct3)
    3'b000:begin
        o_branch_decision = eq;
    end
    3'b001:begin
        o_branch_decision = ~eq;
    end
    3'b100:begin
        o_branch_decision = lt;
    end
    3'b101:begin
        o_branch_decision = ~lt;
    end
    3'b110:begin
        o_branch_decision = ltu;
    end
    3'b111:begin
        o_branch_decision = ~ltu;
    end
    default:begin
        o_branch_decision = 1'b0;
    end
    endcase
end



endmodule