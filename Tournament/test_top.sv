module tournament_top_c(
    input wire clock,
    input wire reset,
    input wire [31:0] PC,
    input wire actually_taken,
    output wire taken
);
wire clock;
wire reset;
wire [31:0] PC;
wire actually_taken;
wire taken;


wire [11:0] global_history;
GHR ghr_inst (
    .clock(clock),
    .reset(reset),
    .branch_output(taken),
    .global_history(global_history)
);

gselect gselect_inst (
    .clock(clock),
    .reset(reset),
    .pc(PC),
    .branch(taken),
    .predict(global_predicton_taken)
);

wire [9:0] historyTable;
local_history_table LHT (
    .clock(clock),
    .reset(reset),
    .taken(taken),
    .pc(PC),
    .out(historyTable)
);

wire [1:0] choice_predictor;
choice_predictor choice_predictor_inst (
    .global(global_history),
    .actually_taken(actually_taken),
    .choice_prediction(choice_predictor)
);

wire local_prediction_taken;
local_prediction local_predictor (
    .clock(clock),
    .reset(reset),
    .historyTable(historyTable),
    .taken(taken),
    .prediction(local_prediction_taken)
);

tournnament_mux tournnament_mux_inst (
    .global(global_predicton_taken),
    .Local(local_prediction_taken),
    .choice_prediction(choice_predictor),
    .branch_predict(taken)
);



endmodule