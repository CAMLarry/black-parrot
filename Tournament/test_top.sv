module tournament_top_c(
    input logic clock,
    input logic reset,
    input logic [31:0] PC,
    input logic correct,
    //input logic global_predicton_taken,
    output logic prediction_final




    //these are some of the signals that we will actually recieve, based on andreas kuster design
    input clk_i,
    input reset_i,

    input w_v_i, // this might be wether it was a branch or not
    input [bht_idx_width_p-1:0] w_idx_i, //my understanding is that this is telling us the index (PC) of a previous instruction
    input correct_i, //and this tells us wether we were right or not on that past prediction

    input r_v_i, // this is like an enable signal, if this is zero predict_o always zero
    input [bht_idx_width_p-1:0] r_addr_i, // 
    output predict_o

);

/*initial beign
choice_prediction = 2'b11;
end*/

wire [11:0] global_history;
GHR ghr_inst (
    .clk(clock),
    .rst(reset),
    .branch_output(actually_taken),
    .global_history(global_history)
);

wire global_predictor;
global_prediction_table global_prediction_table_inst (
    .clock(clock),
    .reset(reset),
    .GHR(global_history),
    .taken(actually_taken),
    .prediction(global_predictor)
);


wire [9:0] historyTable;
local_history_table LHT (
    .clock(clock),
    .reset(reset),
    .taken(actually_taken),
    .pc(PC),
    .out(historyTable)
);

wire [1:0] choice_predictor;
choice_predictor choice_predictor_inst (
	 .clock(clock),
	 .reset(reset),
    .global_history(global_history),
    .actually_taken(actually_taken),
    .choice_prediction(choice_predictor)
);

wire local_prediction;
local_prediction local_predictor (
    .clock(clock),
    .reset(reset),
    .historyTable(historyTable),
    .taken(taken),
    .prediction(local_prediction)
);



choice_predictor_2 choice_predictor_2_inst (
    .global(global_history),
    .correct(correct),
    .lp_prediction(local_prediction),
    .choice_prediction(choice_predictor)
);



mux_ tournnament_mux_inst (
    .global(global_predicton),
    .Local(local_prediction),
    .choice_prediction(choice_predictor),
    .branch_predict(prediction_final)
);

// im trying some stuff to make it so that we can send in actual_taken because it is used in all modules.
always @(posedge clock) begin
    gp_twiceLast <= gp_last;
    gp_last <= global_prediction;
    
    lp_twiceLast <= lp_last;
    lp_last <= local_prediction;

    cp_twiceLast <= cp_last;
    cp_last <= choice_prediction;
end

always_comb begin
    if (choice_prediction > 3) begin
        actual_taken = (correct & gp_twiceLast)|(~correct & ~gp_twiceLast);
    end else begin
        actual_taken = (correct & lp_twiceLast)|(~correct & ~lp_twiceLast);
    end
end

endmodule