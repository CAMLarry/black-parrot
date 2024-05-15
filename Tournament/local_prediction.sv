module local_prediction(
    input logic clock,
    input logic reset,
    input logic [9:0] historyTable,
    input logic taken,
    output logic prediction
);
    logic [9:0] last;
    logic [9:0] twiceLast;
    logic [9:0] current;
    logic [1024:0] [2:0] mainTable;
    always @(posedge clock) begin
        twiceLast <= last;
        last <= current;
        current <= historyTable;

        if (mainTable[current] > 3)
            prediction <= 1'b1;
        else 
            prediction <= 1'b0;

        if (taken)
            if (mainTable [twiceLast] != 7) // prevent overflow
                mainTable [twiceLast] <=  mainTable [twiceLast] + 1;
        else 
            if (mainTable [twiceLast] != 0) // prevent underflow
                mainTable [twiceLast] <=  mainTable [twiceLast] - 1;

    end
endmodule

module local_prediction_tb;
    // Inputs
    logic clock;
    logic reset;
    logic [9:0] historyTable;
    logic taken;
    
    // Outputs
    logic prediction;
    
    // Instantiate the module under test
    local_prediction dut (
        .clock(clock),
        .reset(reset),
        .historyTable(historyTable),
        .taken(taken),
        .prediction(prediction)
    );
    
    // Clock generation
    always begin
        clock = 1'b0;
        #5;
        clock = 1'b1;
        #5;
    end
    
    // Test stimulus
    initial begin
        reset = 1'b1;
        historyTable = 10'b0;
        taken = 1'b0;
        #10;
        reset = 1'b0;
        #10;
        historyTable = 10'b5;
        taken = 1'b1;
        #10;
        historyTable = 10'b5;
        taken = 1'b0;
        #10;
        historyTable = 10'b20;
        taken = 1'b1;
        #10;
        historyTable = 10'b20;
        taken = 1'b0;
        #10;
        historyTable = 10'b1;
        taken = 1'b1;
        #10;
        historyTable = 10'b1;
        taken = 1'b0;
        #10;
        $finish;
    end
endmodule
