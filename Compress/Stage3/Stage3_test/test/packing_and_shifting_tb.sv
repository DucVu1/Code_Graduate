`timescale 1ns / 1ps

module packing_and_shifting_tb;

    // Parameters
    parameter TOTAL_WIDTH           = 136;
    parameter TOTAL_BITS_COMPRESSED = 34;
    parameter CACHE_LINE            = 64;
    parameter WORD_WIDTH            = 32;
    parameter SHIFT_WIDTH           = 68;
    parameter WORD2_LENGTH          = 6;
    parameter TOTAL_LENGTH          = 7;
    parameter DICT_WORD             = 16;
    parameter OUT_SHIFT_BIT         = 7;

    // Signals
    logic                               clk;
    logic [2:0]                         code1, code2;
    logic [TOTAL_LENGTH - 1 : 0]        total_length;
    logic [OUT_SHIFT_BIT - 1 : 0]       out_shift;
    logic [WORD2_LENGTH - 1 : 0]        word2_length;
    logic [WORD_WIDTH - 1 :0]           word1, word2;
    logic [DICT_WORD * WORD_WIDTH - 1:0] dict;
    logic [$clog2(DICT_WORD) - 1:0]     idx1, idx2;
    logic [CACHE_LINE - 1 : 0]          final_output;

    // DUT Instantiation
    packing_and_shifting #(
        .TOTAL_WIDTH(TOTAL_WIDTH),
        .TOTAL_BITS_COMPRESSED(TOTAL_BITS_COMPRESSED),
        .CACHE_LINE(CACHE_LINE),
        .WORD_WIDTH(WORD_WIDTH),
        .SHIFT_WIDTH(SHIFT_WIDTH),
        .WORD2_LENGTH(WORD2_LENGTH),
        .TOTAL_LENGTH(TOTAL_LENGTH),
        .DICT_WORD(DICT_WORD),
        .OUT_SHIFT_BIT(OUT_SHIFT_BIT)
    ) DUT (
        .i_clk(clk),
        .i_code1(code1),
        .i_code2(code2),
        .i_total_length(total_length),
        .i_out_shift(out_shift),
        .i_word2_length(word2_length),
        .i_word1(word1),
        .i_word2(word2),
        .i_dict(dict),
        .i_idx1(idx1),
        .i_idx2(idx2),
        .o_final_output(final_output)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Test Stimulus
    initial begin
        // Initialize clock
        clk = 0;

        // Initialize inputs
        code1 = 3'b001;
        code2 = 3'b010;
        total_length = 7'd10;
        out_shift = 7'd5;
        word2_length = 6'd8;
        word1 = 32'hA5A5A5A5;
        word2 = 32'h5A5A5A5A;
        idx1 = 4'd3;
        idx2 = 4'd7;
        dict = {16{32'hFFFFFFFF}}; // Initialize dictionary with all 1s

        // Apply test cases
        #10;
        word1 = 32'h12345678;
        word2 = 32'h87654321;
        idx1 = 4'd5;
        idx2 = 4'd10;

        #10;
        word1 = 32'hDEADBEEF;
        word2 = 32'hCAFEBABE;
        total_length = 7'd15;
        out_shift = 7'd3;

        #20;
        $stop;
    end

    // Monitor Outputs
    initial begin
        $monitor($time, " Output: %h", final_output);
    end

endmodule
