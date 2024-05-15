module tournament_top(clock, reset, PC, taken) {
    input clock, reset;
    input [31:0] PC;
    output taken; // should this be 2 bits behind PC, to account for pipeline stages?

    

}