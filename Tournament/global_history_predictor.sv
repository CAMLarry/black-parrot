// note: this one doesnt seem to care about the "predictions" i think it just waits for the actual values
// until it changes anything meaning its just like 3 cycles behind but i assume that is fine
module global_history_predictor (
    input logic clock,
    input logic reset,
    input logic correct,
    input logic [11:0] global_history,
    output logic predict
);

logic [4096:0] [1:0] mainTable;

initial begin
		for (int i = 0; i < 1024; i++) begin
			mainTable[i] = 10'd2;
		end
	 end

always @(posedge clock) begin
        if (reset) begin
            mainTable <= '{default:10'd2};
        end else begin
            if (count_up & (mainTable[global_history] != 1'b11)) begin
                mainTable[global_history] <= mainTable[global_history] + 1;
            end else if (count_down & (mainTable[global_history] != 1'b00)) begin
                mainTable[global_history] <= mainTable[global_history] - 1;
            end
        end
        
        predict <= (mainTable[global_history] >= 2'd2);
    end

always_comb begin
    taken_prde = mainTable[global_history] >= 2'd2;

    // these are all weird rn and wrong
    taken_actual = (correct & taken_pred) | (~correct & ~taken_pred);

    count_up = (correct & taken_pred) | (~correct & ~taken_pred);
    count_down = (correct & ~taken_pred) | (~correct & taken_pred);
end
endmodule