`timescale 1ns / 1ps

module or_gate_tb;

    // Parameters
    parameter I_WIDTH1 = 68;
    parameter I_WIDTH2 = 34;
    parameter TOTAL_WIDTH = 136;

    // Testbench signals
    logic [I_WIDTH1 - 1 : 0] i_first_word;
    logic [I_WIDTH2 - 1 : 0] i_second_word;
    logic [TOTAL_WIDTH - 1 : 0] i_reg_array;
    logic [TOTAL_WIDTH - 1 : 0] o_word;
    logic [TOTAL_WIDTH - 1 : 0] expected_o_word;

    // Instantiate the DUT
    or_gate #(
        .I_WIDTH1(I_WIDTH1),
        .I_WIDTH2(I_WIDTH2),
        .TOTAL_WIDTH(TOTAL_WIDTH)
    ) dut (
        .i_first_word(i_first_word),
        .i_second_word(i_second_word),
        .i_reg_array(i_reg_array),
        .o_word(o_word)
    );

    // Test procedure
    initial begin
        $dumpfile("or_gate_tb.vcd");
        $dumpvars(0, or_gate_tb);
        
        // Test case 1: All zeros
        i_first_word = 68'b0;
        i_second_word = 34'b0;
        i_reg_array = 136'b0;
        #10;
        expected_o_word = 136'b0; // Expected output
        $display("TC1: o_word = %b", o_word);
        assert (o_word === expected_o_word) else $error("TC1 Failed!");

        // Test case 2: Random values
        i_first_word = 68'h123456789ABCDEF;
        i_second_word = 34'h3F3F3F3F;
        i_reg_array = 136'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;
        expected_o_word = {i_reg_array[TOTAL_WIDTH-1:68], 
                           ({i_second_word | i_first_word[67:34], i_first_word[33:0]} | i_reg_array[67:0])};
        $display("TC2: o_word = %b", o_word);
        assert (o_word === expected_o_word) else $error("TC2 Failed!");

        // Test case 3: Mixed values
        i_first_word = 68'hAAAAAAAAAAAAAAAA;
        i_second_word = 34'h55555555;
        i_reg_array = 136'h0000FFFFFFFF0000FFFFFFFF0000FFFFFFFF;
        #10;
        expected_o_word = {i_reg_array[TOTAL_WIDTH-1:68], 
                           ({i_second_word | i_first_word[67:34], i_first_word[33:0]} | i_reg_array[67:0])};
        $display("TC3: o_word = %b", o_word);
        assert (o_word === expected_o_word) else $error("TC3 Failed!");

        // Test case 4: Edge case with all ones
        i_first_word = 68'hFFFFFFFFFFFFFFFF;
        i_second_word = 34'hFFFFFFFF;
        i_reg_array = 136'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;
        expected_o_word = {i_reg_array[TOTAL_WIDTH-1:68], 
                           ({i_second_word | i_first_word[67:34], i_first_word[33:0]} | i_reg_array[67:0])};
        $display("TC4: o_word = %b", o_word);
        assert (o_word === expected_o_word) else $error("TC4 Failed!");

        // Finish simulation
        $display("All test cases passed!");
        $finish;
    end

endmodule
