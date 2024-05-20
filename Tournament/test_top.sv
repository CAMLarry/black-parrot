module tournament_top_c(
    input logic clock,
    input logic reset,
    input logic [31:0] PC,
    input logic actually_taken,
    input logic global_predicton_taken,
    output logic taken
);

logic clock;
logic reset;
logic [31:0] PC;
logic actually_taken;
logic global_predicton_taken;
logic taken;


wire [11:0] global_history;
GHR ghr_inst (
    .clock(clock),
    .reset(reset),
    .branch_output(taken),
    .global_history(global_history)
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