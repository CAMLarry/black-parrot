module local_history_table (
    input logic clock,
    input logic reset,
    input logic taken,
    input logic [31:0] pc,
    output logic [9:0] out
);
    logic [9:0] current;
    logic [9:0] last;
    logic [9:0] twiceLast;

    logic [1024:0] [10:0] mainTable;

    always @(posedge clock) begin
        twiceLast <= last;
        last <= current;
        current <= pc [9:0];
        out <= mainTable [current];
        

        if (twiceLastType) begin
            if (taken) begin
                mainTable [twiceLast] <= (mainTable [twiceLast] >> 1) + 512;
            end else begin
                mainTable [twiceLast] <= (mainTable [twiceLast] >> 1);
            end
        end
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
    
    // Initialize inputs
    initial begin
        clock = 0;
        reset = 0;
        taken = 0;
        pc = 0;
        
        #10 reset = 1;
        #20 reset = 0;
        
        // Test case 1
        #30 taken = 1;
        #40 pc = 1234;
        
        // Test case 2
        #50 taken = 0;
        #60 pc = 1233;
        
        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 1;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1233;

        #30 taken = 0;
        #40 pc = 1234;

        #50 taken = 0;
        #60 pc = 1235;

        for (int i = 0; i < 25; i++) begin
            #50 taken = 0;
            #60 pc = 1236;

            #50 taken = 0;
            #60 pc = 1237;

            #50 taken = 1;
            #60 pc = 1238;
        end

        #50 taken = 0;
            #60 pc = 1236;

            #50 taken = 0;
            #60 pc = 1237;

            #50 taken = 1;
            #60 pc = 1238;

            #50 taken = 0;
            #60 pc = 1239;

            #50 taken = 0;
            #60 pc = 1240;


        
        #100 $finish;
    end
endmodule

