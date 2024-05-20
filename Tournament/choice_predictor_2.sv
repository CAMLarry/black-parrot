module choice_predictor_2(
    input logic clock,
    input logic reset,
    input logic [11:0] global_history, //.global(global_history),
    input logic correct, //.actually_taken(actually_taken),
    input logic lp_prediction,
    output logic choice_prediction //.choice_prediction(choice_predictor)

);

    logic [11:0] last;
    logic [11:0] twiceLast;
    logic [11:0] current;
    logic [4095:0] [2:0] mainTable;
	 
	 initial begin
		for (int i = 0; i < 1024; i++) begin
			mainTable [i] = 3'b100;
		end
	 end
	 
    always @(posedge clock) begin
        twiceLast <= last;
        last <= current;
        current <= global_history;

        lp_twiceLast <= lp_last;
        lp_last <= lp_current;
        lp_current <= lp_prediction;

        /*if (mainTable[current] > 3)
            prediction <= 1'b1;
        else 
            prediction <= 1'b0;*/

        if (count_up) begin
            if (mainTable [twiceLast] < 7) // prevent overflow
                mainTable [twiceLast] <=  mainTable [twiceLast] + 1;
        end else if (count_down) begin
            if (mainTable [twiceLast] > 0) // prevent underflow
                mainTable [twiceLast] <=  mainTable [twiceLast] - 1;
		  end

    end
	 
	 always_comb begin
		if (mainTable[global_history] > 3)
			choice_prediction <= 1'b1;
        else 
			choice_prediction <= 1'b0;

        taken_actual_global = (correct & (mainTable[twiceLast] > 3'b100))|(~correct & ~(mainTable[twiceLast] > 3'b100));
        taken_actual_local = (correct & lp_twiceLast)|(~correct & ~lp_twiceLast);

        if (mainTable[twiceLast] > 3'b100)
            taken_actual = taken_actual_global;
        else if (mainTable[twiceLast] < 3'b100)
            taken_actual = taken_actual_local;

        count_up = taken_actual;
        count_down = ~taken_actual;
	 end
	 
endmodule

module choice_predictor_tb;
    // Inputs
    logic clock;
    logic reset;
    logic [11:0] global;
    logic actually_taken;
    
    // Outputs
    logic choice_prediction;
    
    // Instantiate the module under test
    choice_predictor dut (
        .clock(clock),
        .reset(reset),
        .global(global),
        .actually_taken(taken),
        .choice_prediction(prediction)
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
        choice_prediction = 10'd0;
        taken = 1'b0;
        #10;
        reset = 1'b0;
        #10;
        choice_prediction = 10'd5;
        taken = 1'b1;
        #10;
        choice_prediction = 10'd5;
        taken = 1'b0;
        #10;
        choice_prediction = 10'd20;
        taken = 1'b1;
        #10;
        choice_prediction = 10'd20;
        taken = 1'b0;
        #10;
		  choice_prediction = 10'd20;
        taken = 1'b0;
        #10;
		  choice_prediction = 10'd20;
        taken = 1'b0;
        #10;
		  choice_prediction = 10'd20;
        taken = 1'b0;
        #10;
		  choice_prediction = 10'd20;
        taken = 1'b0;
        #10;
        choice_prediction = 10'd1;
        taken = 1'b1;
        #10;
        choice_prediction = 10'd1;
        taken = 1'b0;
        #10;
        $stop;
    end
endmodule