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

