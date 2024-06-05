/*
 * bp_fe_bht.v
 *
 * Branch History Table (BHT) records the information of the branch history, i.e.
 * branch taken or not taken.
 * Each entry consists of 2 bit saturation counter. If the counter value is in
 * the positive regime, the BHT predicts "taken"; if the counter value is in the
 * negative regime, the BHT predicts "not taken". The implementation of BHT is
 * native to this design.
 * 2-bit saturating counter(high_bit:prediction direction,low_bit:strong/weak prediction)
 */
`include "bp_common_defines.svh"
`include "bp_fe_defines.svh"

module bp_fe_bht
 import bp_common_pkg::*;
 import bp_fe_pkg::*;
 #(parameter bp_params_e bp_params_p = e_bp_default_cfg
   `declare_bp_proc_params(bp_params_p)

   , localparam entry_width_lp = 2*bht_row_els_p
   )
  (input                                  clk_i
   , input                                reset_i

   , output logic                         init_done_o

   , input                                w_v_i // enable for a past history
   , input [bht_idx_width_p-1:0]          w_idx_i // 
   , input [bht_offset_width_p-1:0]       w_offset_i
   , input [ghist_width_p-1:0]            w_ghist_i
   , input [bht_row_width_p-1:0]          val_i
   , input                                correct_i
   , output logic                         w_yumi_o

   , input                                r_v_i // this oculd mean enable branch prediction
   , input [vaddr_width_p-1:0]            r_addr_i
   , input [ghist_width_p-1:0]            r_ghist_i
   , output logic [bht_row_width_p-1:0]   val_o
   , output logic                         pred_o
   );

  wire [11:0] global_history;
GHR ghr_inst (
    .clk(clk_i),
    .rst(reset_i),
    .branch_output(actually_taken),
    .global_history(global_history)
);

wire global_predictor;
global_prediction_table global_prediction_table_inst (
    .clock(clk_i),
    .reset(reset_i),
    .GHR(global_history),
    .taken(actually_taken),
    .prediction(global_predictor)
);


wire [9:0] historyTable;
local_history_table LHT (
    .clock(clk_i),
    .reset(reset_i),
    .taken(actually_taken),
    .pc(r_addr_i),
    .out(historyTable)
);

wire [1:0] choice_predictor;
choice_predictor choice_predictor_inst (
	 .clock(clk_i),
	 .reset(reset_i),
   .global_history(global_history),
   .actually_taken(actually_taken),
   .choice_prediction(choice_predictor)
);

wire local_prediction;
local_prediction local_predictor (
    .clock(clk_i),
    .reset(reset_i),
    .historyTable(historyTable),
    .taken(actually_taken),
    .prediction(local_prediction)
);


mux_ tournnament_mux_inst (
    .global(val_o[pred_idx_lo]), // adding in their global predictor
    .Local(local_prediction),
    .choice_prediction(choice_predictor),
    .branch_predict(prediction_final)
);

assign pred_o = prediction_final;


// im trying some stuff to make it so that we can send in actual_taken because it is used in all modules.
always @(posedge clock) begin
    cp_twiceLast <= cp_last;
    cp_last <= choice_predictor;

    global_prediction_twiceLast <= global_prediction_last;
    global_prediction_last <= global_predicton;

    local_prediction_twiceLast <= local_prediction_last;
    local_prediction_last <= local_prediction;
end

always_comb begin
    if (correct_i && (cp_twiceLast > 3))
        actually_taken <= global_prediction_twiceLast;
    else 
        actually_taken = local_prediction_twiceLast;
end





  // Initialization state machine
  enum logic [1:0] {e_reset, e_clear, e_run} state_n, state_r;
  wire is_reset = (state_r == e_reset);
  wire is_clear = (state_r == e_clear);
  wire is_run   = (state_r == e_run);

  assign init_done_o = is_run;

  localparam idx_width_lp = bht_idx_width_p+ghist_width_p;
  localparam bht_els_lp = 2**idx_width_lp;
  localparam bht_init_lp = 2'b01;
  logic [`BSG_WIDTH(bht_els_lp)-1:0] init_cnt;
  bsg_counter_clear_up
   #(.max_val_p(bht_els_lp), .init_val_p(0))
   init_counter
    (.clk_i(clk_i)
     ,.reset_i(reset_i)

     ,.clear_i(1'b0)
     ,.up_i(is_clear)
     ,.count_o(init_cnt)
     );
  wire finished_init = (init_cnt == bht_els_lp-1'b1);

  always_comb
    case (state_r)
      e_clear: state_n = finished_init ? e_run : e_clear;
      e_run  : state_n = e_run;
      // e_reset
      default: state_n = e_clear;
    endcase

  // synopsys sync_set_reset "reset_i"
  always_ff @(posedge clk_i)
    if (reset_i)
      state_r <= e_reset;
    else
      state_r <= state_n;

  logic rw_same_addr;

  wire                             w_v_li = is_clear | (w_v_i & ~rw_same_addr);
  wire [idx_width_lp-1:0]        w_idx_li = is_clear ? init_cnt : {w_ghist_i, w_idx_i};
  wire [bht_row_els_p-1:0]      w_mask_li = is_clear ? '1 : (1'b1 << w_offset_i);
  logic [bht_row_width_p-1:0] w_data_li;
  for (genvar i = 0; i < bht_row_els_p; i++)
    begin : wval
      assign w_data_li[2*i]   =
        is_clear ? bht_init_lp[0] : w_mask_li[i] ? ~correct_i : val_i[2*i];
      assign w_data_li[2*i+1] =
        is_clear ? bht_init_lp[1] : w_mask_li[i] ? val_i[2*i+1] ^ (~correct_i & val_i[2*i]) : val_i[2*i+1];
    end

  // GSELECT
  wire                            r_v_li = r_v_i;
  wire [idx_width_lp-1:0]       r_idx_li = {r_ghist_i, r_addr_i[2+:bht_idx_width_p]} ^ r_addr_i[1];
  logic [bht_row_width_p-1:0] r_data_lo;

  assign rw_same_addr = r_v_i & w_v_i & (r_idx_li == w_idx_li);

  bsg_mem_1r1w_sync
   #(.width_p(bht_row_width_p), .els_p(bht_els_lp), .latch_last_read_p(1))
   bht_mem
    (.clk_i(clk_i)
     ,.reset_i(reset_i)

     ,.w_v_i(w_v_li)
     ,.w_addr_i(w_idx_li)
     ,.w_data_i(w_data_li)

     ,.r_v_i(r_v_li)
     ,.r_addr_i(r_idx_li)
     ,.r_data_o(r_data_lo)
     );
  assign w_yumi_o = is_run & w_v_i & ~rw_same_addr;

  logic [`BSG_SAFE_CLOG2(bht_row_width_p)-1:0] pred_idx_lo;
  if (bht_row_els_p > 1)
    begin : fold
      logic [bht_offset_width_p-1:0] pred_offset_n, pred_offset_r;
      assign pred_offset_n = r_addr_i[2+bht_idx_width_p+:bht_offset_width_p];
      bsg_dff
       #(.width_p(bht_offset_width_p))
       pred_idx_reg
        (.clk_i(clk_i)
         ,.data_i(pred_offset_n)
         ,.data_o(pred_offset_r)
         );
    assign pred_idx_lo = (pred_offset_r << 1'b1) + 1'b1;
   end
 else
   begin : no_fold
     assign pred_idx_lo = 1'b1;
   end

  assign val_o = r_data_lo;

  //removed their pred_o
  //assign pred_o = val_o[pred_idx_lo];

endmodule

