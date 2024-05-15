module test_top(
    input wire clock,
    input wire reset,
    input wire [31:0] PC,
    output wire taken
)

gshare gshare_inst (
    .pc(PC),
    .branch(taken),
    .clk(clock),
    .rst(reset),
    .predict()
);

two_level_adaptave two_level_adaptave_inst (
    .pc(PC),
    .branch(taken),
    .predict()
);

tournnament_mux tournnament_mux_inst (
    .global(gshare_inst.predict),
    .Local(two_level_adaptave_inst.predict),
    .choice_prediction(3'b111),
    .branch_predict(taken)
);



endmodule

// Testbench for the test_top module

module test_top_tb;

    // Inputs
    reg clock;
    reg reset;
    reg [31:0] PC;

    // Outputs
    wire taken;

    // Instantiate the test_top module
    test_top dut (
        .clock(clock),
        .reset(reset),
        .PC(PC),
        .taken(taken)
    );

    // Clock generation
    always #5 clock = ~clock;

    // Reset generation
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // Stimulus generation
    initial begin
        // Provide stimulus values for PC
        PC = 32'h00000000;
        #10 PC = 32'h00000001;
        #10 PC = 32'h00000002;
        // Add more stimulus values as needed
    end

    // Monitor
    always @(posedge clock) begin
        $display("PC = %h, taken = %b", PC, taken);
    end

endmodule

