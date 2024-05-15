module GShareBranchPredictor (
    input wire [31:0] pc,
    input wire branch,
    input wire clk,
    input wire rst,
    output wire predict
);
    // Define the size of the global history register
    parameter HISTORY_SIZE = 1024;

    // Define the size of the pattern history table
    parameter PHT_SIZE = 4096;

    // Define the size of the branch history register
    parameter BHR_SIZE = 12;

    // Define the size of the branch history mask
    parameter BHR_MASK = (1 << BHR_SIZE) - 1;

    // Define the size of the global history mask
    parameter HISTORY_MASK = (1 << HISTORY_SIZE) - 1;

    // Define the size of the pattern history table mask
    parameter PHT_MASK = (1 << PHT_SIZE) - 1;

    // Define the global history register
    reg [HISTORY_SIZE-1:0] global_history;

    // Define the branch history register
    reg [BHR_SIZE-1:0] branch_history;

    // Define the pattern history table
    reg [1:0] pht [PHT_SIZE-1:0];

    // Update the global history register and branch history register
    always @(posedge clk) begin
        global_history <= {global_history[HISTORY_SIZE-2:0], branch};
        branch_history <= {branch_history[BHR_SIZE-2:0], branch};
    end

    // Predict the branch outcome based on the global history and pattern history table
    always @(pc) begin
        predict = pht[pc ^ (global_history & HISTORY_MASK)] >= 2;
    end

    // Update the pattern history table based on the branch outcome
    always @(posedge clk) begin
        if (branch) begin
            pht[pc ^ (global_history & HISTORY_MASK)] <= pht[pc ^ (global_history & HISTORY_MASK)] + 1;
        end else begin
            pht[pc ^ (global_history & HISTORY_MASK)] <= pht[pc ^ (global_history & HISTORY_MASK)] - 1;
        end
    end
endmodule
