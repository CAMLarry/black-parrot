module comparator (
    input wire clk_i,
    input wire reset_i,
    input wire a,
    input wire b,
    output wire eq
);

    reg eq_reg;

    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            eq_reg <= 0;
        end else begin
            eq_reg <= (a == b);
        end
    end

    assign eq = eq_reg;

endmodule