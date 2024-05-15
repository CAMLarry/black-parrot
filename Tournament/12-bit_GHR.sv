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

module GHR_testbench;

    // Inputs
    logic clk;
    logic rst;
    logic branch_output;
    
    // Outputs
    logic [11:0] global_history;
    
    // Instantiate the GHR module
    GHR dut (
        .clk(clk),
        .rst(rst),
        .branch_output(branch_output),
        .global_history(global_history)
    );
    
    // Clock generation
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end
    
    // Reset generation
    initial begin
        rst = 1'b1;
        #10;
        rst = 1'b0;
        #10;
    end
    
    // Stimulus
    initial begin
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b0;
        #20;
        branch_output = 1'b1;
        #20;
        branch_output = 1'b0; // final value should be 010010100101
        #20;
        $finish;
    end
    
endmodule
