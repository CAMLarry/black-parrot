module tournament_top(clock, reset, PC, takenIn, prediction)
    input clock, reset;
    input [31:0] PC;
    input takenIn;
    output prediction; // should this be 2 bits behind PC, to account for pipeline stages?
endmodule


