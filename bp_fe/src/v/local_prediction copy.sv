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
    logic [1023:0] [2:0] mainTable;
	 
	 initial begin
		for (int i = 0; i < 1024; i++) begin
			mainTable [i] = 3'b100;
		end
	 end
	 
    always @(posedge clock) begin
        twiceLast <= last;
        last <= current;
        current <= historyTable;

        /*if (mainTable[current] > 3)
            prediction <= 1'b1;
        else 
            prediction <= 1'b0;*/

        if (taken) begin
            if (mainTable [twiceLast] < 7) // prevent overflow
                mainTable [twiceLast] <=  mainTable [twiceLast] + 1;
        end else begin
            if (mainTable [twiceLast] > 0) // prevent underflow
                mainTable [twiceLast] <=  mainTable [twiceLast] - 1;
		  end

    end
	 
	 always_comb begin
		if (mainTable[historyTable] > 3)
			prediction <= 1'b1;
      else 
			prediction <= 1'b0;
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
        historyTable = 10'd0;
        taken = 1'b0;
        #10;
        reset = 1'b0;
        #10;
        historyTable = 10'd5;
        taken = 1'b1;
        #10;
        historyTable = 10'd5;
        taken = 1'b0;
        #10;
        historyTable = 10'd20;
        taken = 1'b1;
        #10;
        historyTable = 10'd20;
        taken = 1'b0;
        #10;
		  historyTable = 10'd20;
        taken = 1'b0;
        #10;
		  historyTable = 10'd20;
        taken = 1'b0;
        #10;
		  historyTable = 10'd20;
        taken = 1'b0;
        #10;
		  historyTable = 10'd20;
        taken = 1'b0;
        #10;
        historyTable = 10'd1;
        taken = 1'b1;
        #10;
        historyTable = 10'd1;
        taken = 1'b0;
        #10;
        $stop;
    end
endmodule
