`timescale 1ns/1ps

module tb_reg_array2;

    parameter TOTAL_WIDTH = 128;

    // Inputs
    logic                  i_clk;
    logic                  i_reset;
    logic                  i_enable;
    logic                  i_push_flag;
    logic  [7:0]           i_push_amount;
    logic  [TOTAL_WIDTH-1:0] i_word;

    // Output
    logic  [TOTAL_WIDTH-1:0] o_word;

    // DUT
    reg_array2 #(.TOTAL_WIDTH(TOTAL_WIDTH)) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(i_enable),
        .i_push_flag(i_push_flag),
        .i_push_amount(i_push_amount),
        .i_word(i_word),
        .o_word(o_word)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    // Test procedure
    initial begin
        // Init
        i_clk = 0;
        i_reset = 0;
        i_enable = 0;
        i_push_flag = 0;
        i_push_amount = 0;
        i_word = 0;

        // Reset
        #12;
        i_reset = 1;

        // -------- Test Case 1: First half, push_flag = 0 --------
        @(posedge i_clk);
        i_enable = 1;
        i_push_flag = 0;
        i_word = 128'hDEAD_BEEF_1234_5678_CAFE_BABE_F00D_C0DE;

        @(posedge i_clk); // second half
        i_enable = 1;
        i_push_flag = 0;
        i_word = 128'h0000_1111_2222_3333_4444_5555_6666_7777;

        // -------- Test Case 2: push_flag = 1, push_amount = 16 --------
        @(posedge i_clk);
        i_push_flag = 1;
        i_push_amount = 8'd16;
        i_word = 128'hAAAA_BBBB_CCCC_DDDD_EEEE_FFFF_0000_1111;

        @(posedge i_clk);
        i_word = 128'h2222_3333_4444_5555_6666_7777_8888_9999;

        // -------- Test Case 3: push_flag = 1, push_amount = 40 --------
        @(posedge i_clk);
        i_push_flag = 1;
        i_push_amount = 8'd40;
        i_word = 128'hABCD_EFAB_CDEF_ABCD_EFAB_CDEF_ABCD_EFAB;

        @(posedge i_clk);
        i_word = 128'h1357_2468_9ABC_DEF0_1357_2468_9ABC_DEF0;

        // Stop
        @(posedge i_clk);
        i_enable = 0;
        i_push_flag = 0;

        #20;
        $display("Final o_word = %h", o_word);
        $finish;
    end

endmodule
