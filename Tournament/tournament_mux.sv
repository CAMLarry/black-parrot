module mux_ (
    input wire global_in,
    input wire Local_in,
    input wire [1:0] choice_prediction,
    output wire  branch_predict
); 
    
    if (global_in_in == Local_in)
        assign branch_predict = global_in;
    else if (choice_prediction >= 2'b10)
        assign branch_predict = global_in;
    else
        assign branch_predict = Local_in;

endmodule

module mux_tb;

    // Inputs
    reg global_in;
    reg Local_in;
    reg [1:0] choice_prediction;

    // Outputs
    wire branch_predict;

    // Instantiate the mux module
    mux_ uut (
        .global_in(global_in),
        .Local_in(Local_in),
        .choice_prediction(choice_prediction),
        .branch_predict(branch_predict)
    );

    // Clock generation
    reg clk;
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        clk = 0;
        global_in = 0;
        Local_in = 0;
        choice_prediction = 2'b00;
        #10; 
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;
        #10;

        #10;
        global_in = 1;
        Local_in = 1;
        choice_prediction = 2'b00;
        #10;
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;
        #10;

        #10;
        global_in = 0;
        choice_prediction = 2'b00;
        #10;
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;

        #10;
        Local_in = 0;
        global_in = 1;
        choice_prediction = 2'b00;
        #10;
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;
        #10;
        
        $finish;
    end

endmodule
