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