module mux (
    input wire global,
    input wire Local,
    input wire [1:0] choice_prediction,
    output wire  branch_predict
); 
    
    if (a == b)
        assign y = a;
    else if (sel >= 2'b10)
        assign y = a;
    else
        assign y = b;

endmodule

module mux_tb;

    // Inputs
    reg global;
    reg Local;
    reg [1:0] choice_prediction;

    // Outputs
    wire branch_predict;

    // Instantiate the mux module
    mux uut (
        .global(global),
        .Local(Local),
        .choice_prediction(choice_prediction),
        .branch_predict(branch_predict)
    );

    // Clock generation
    reg clk;
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        clk = 0;
        global = 0;
        Local = 0;
        choice_prediction = 2'b00;
        #10; 
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;
        #10;

        #10;
        global = 1;
        Local = 1;
        choice_prediction = 2'b00;
        #10;
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;
        #10;

        #10;
        global = 0;
        choice_prediction = 2'b00;
        #10;
        choice_prediction = 2'b01;
        #10;
        choice_prediction = 2'b10;
        #10;
        choice_prediction = 2'b11;

        #10;
        Local = 0;
        global = 1;
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
