module local_history_table (
    /*input logic clock,
    input logic reset,
    input logic taken,
    input logic [31:0] pc,
    output logic [9:0] out,*/

    //these are some of the signals that we will actually recieve, based on andreas kuster design
    input clk_i,
    input reset_i,

    input w_v_i, // this might be wether it was a branch or not
    input [31:0] w_idx_i, //my understanding is that this is telling us the index (PC) of a previous instruction
    input correct_i, //and this tells us wether we were right or not on that past prediction

    //input r_v_i, // this is like an enable signal, if this is zero predict_o always zero
    input [31:0] r_addr_i, // bht_idx_width_p
    output logic [9:0] out
    //output predict_o
);
    //logic [9:0] current;
    //logic [9:0] last;
    //logic [9:0] twiceLast;

    logic [1023:0] [9:0] mainTable;

	 initial begin
		for (int i = 0; i < 1024; i++) begin
			mainTable[i] = 10'b0;
		end
	 end
	 
    always @(posedge clk_i) begin
        /*twiceLast <= last;
        last <= current;
        current <= pc [9:0];*/
        //out <= mainTable [current];
        
        // need to implement some way to tell this module wether the instruction two cycles ago was a branch or not
        if (w_v_i) begin // if this current "past" instruction was a branch
            if (correct_i) begin
                mainTable [r_addr_i] <= (mainTable [r_addr_i] >> 1) + 512;
            end else begin
                mainTable [r_addr_i] <= (mainTable [r_addr_i] >> 1);
            end
        end
    end
	 
	 always_comb begin
		out = mainTable[r_addr_i]; //making this combinational output seems best for sending to the local_prediction on time
	 end
endmodule

module local_history_table_tb;
    // Inputs
    logic clock;
    logic reset;
    logic taken;
    logic [31:0] pc;
    
    // Outputs
    logic [9:0] out;
    
    // Instantiate the module under test
    local_history_table dut (
        .clock(clock),
        .reset(reset),
        .taken(taken),
        .pc(pc),
        .out(out)
    );
    
    // Clock generation
    always #5 clock = ~clock;
    
    /* I tried this on my end and it seemed to work best, remember that the PC changes every clock cycle, running
    your testbench it was taken many clock cycles for the PC to change
    clock = 0;
    reset = 0;
    taken = 0;
    pc = 0;
     @(posedge clock);
    
    reset = 1; @(posedge clock);
    reset = 0; @(posedge clock);
        
    pc = 1234; @(posedge clock);
    pc = 0000; @(posedge clock);
    pc = 0001; @(posedge clock);
    pc = 0002; taken = 1; @(posedge clock);
    pc = 0003; taken = 0; @(posedge clock);
    pc = 1234; @(posedge clock);
    pc = 0000; @(posedge clock);
    pc = 0001; @(posedge clock);
    
    pc = 0002; @(posedge clock);
    pc = 0003; @(posedge clock);
    pc = 0004; @(posedge clock);
    pc = 0005; @(posedge clock);
    pc = 0006; @(posedge clock);
    */
    
    // Initialize inputs
    initial begin
        clock = 0;
        reset = 0;
        taken = 0;
        pc = 0;
        
        #10 reset = 1;
        #10 reset = 0;
        
        // Test case 1
        taken = 1;
        #10 
        pc = 1234;
        
        // Test case 2
        taken = 0;
        #10 pc = 1233;
        
        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 1;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1233;

        taken = 0;
        #10 pc = 1234;

        taken = 0;
        #10 pc = 1235;

        for (int i = 0; i < 25; i++) begin
            taken = 0;
            #10 pc = 1236;

            taken = 0;
            #10 pc = 1237;

            taken = 1;
            #10 pc = 1238;
        end

        taken = 0;
        #10 pc = 1236;

        taken = 0;
        #10 pc = 1237;

        taken = 1;
        #10 pc = 1238;

        taken = 0;
        #10 pc = 1239;

        taken = 0;
        #10 pc = 1240;


        
        #100 $stop;
    end
endmodule