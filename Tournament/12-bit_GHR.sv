module GHR (
    input logic clk,
    input logic rst,
    input logic branch_output,
    output logic [11:0] global_history
);

logic [11:0] ghr_reg;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ghr_reg <= 12'b0;
    end else begin
        ghr_reg <= {branch_output, ghr_reg[10:0]};
    end
end

assign global_history = ghr_reg;

endmodule
