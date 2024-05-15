module bp_fe_bimodal(clk_i, reset_i, wr, rd, index, increase, decrease, update_e)


always @(posedge clk_i)
    begin
        if (increase == 1, && update_e == 1 ) // 
           //increase c_bits at index by 1
        else if (decrease == 1, && update_e == 1 ) //
              //decrease c_bits at index by 1
        else
                //do nothing



    

    end

always @(posedge clk_i)
    begin
        if (rd == 1)
            // read c_bits at index
        else
            // read 1?
    end

endmodule


