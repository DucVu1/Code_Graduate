`timescale 1ns/1ps

module tb_word_comparator;
    parameter INPUT_WORD  = 8;
    parameter COMPARE_WORD = 32;
    localparam BYTE = 8;  // Each byte is 8 bits

    // Inputs for word_comparator.
    reg  [INPUT_WORD-1:0]   i_input;
    reg  [COMPARE_WORD-1:0] i_dict;

    // Outputs from word_comparator.
    wire [2:0] o_no_match;  // (Decoded match count; see word_decoder)
    wire       o_align;     // 1 if matching bytes are contiguous

    // Instantiate the Device Under Test (DUT).
    word_comparator #(.INPUT_WORD(INPUT_WORD), .COMPARE_WORD(COMPARE_WORD))
      dut (
        .i_input(i_input),
        .i_dict(i_dict),
        .o_no_match(o_no_match),
        .o_align(o_align)
      );

    initial begin
        $display("Time\t i_input\ti_dict\t\t  o_no_match\to_align");
        
        // Test Case 1: All bytes match.
        // Let i_input = 8'hAA and dictionary = {8'hAA, 8'hAA, 8'hAA, 8'hAA}.
        // Expected: compare_vec = 4'b1111.
        // The decoder should output (for example) match_count = 4 and aligned.
        i_input = 8'hAA;
        i_dict  = {8'hAA, 8'hAA, 8'hAA, 8'hAA};  // Byte3=AA, Byte2=AA, Byte1=AA, Byte0=AA.
        #10;
        $display("%0t\t %h\t %h\t      %b\t     %b", $time, i_input, i_dict, o_no_match, o_align);
        
        // Test Case 2: Only the first byte (Byte0) matches.
        // Let i_input = 8'hAA and dictionary = {8'h55, 8'h33, 8'h11, 8'hAA}.
        // Ordering: Byte3 = 55, Byte2 = 33, Byte1 = 11, Byte0 = AA.
        // Expected: compare_vec = 4'b0001. Decoder should report one match (and aligned).
        i_input = 8'hAA;
        i_dict  = {8'h55, 8'h33, 8'h11, 8'hAA};
        #10;
        $display("%0t\t %h\t %h\t      %b\t     %b", $time, i_input, i_dict, o_no_match, o_align);
        
        // Test Case 3: Two contiguous matches.
        // Let i_input = 8'hAA and dictionary = {8'h55, 8'hAA, 8'hAA, 8'hCC}.
        // Ordering: Byte3 = 55, Byte2 = AA, Byte1 = AA, Byte0 = CC.
        // Comparators: Byte0: CC != AA (0), Byte1: AA==AA (1), Byte2: AA==AA (1), Byte3: 55 != AA (0).
        // compare_vec = 4'b0110 (if bit0 corresponds to Byte0).
        // Expected: 2 matches and aligned.
        i_input = 8'hAA;
        i_dict  = {8'h55, 8'hAA, 8'hAA, 8'hCC};
        #10;
        $display("%0t\t %h\t %h\t      %b\t     %b", $time, i_input, i_dict, o_no_match, o_align);
        
        // Test Case 4: Two non-contiguous matches.
        // Let i_input = 8'hAA and dictionary = {8'hAA, 8'h55, 8'hCC, 8'hAA}.
        // Ordering: Byte3 = AA, Byte2 = 55, Byte1 = CC, Byte0 = AA.
        // Comparators: Byte0: AA==AA (1), Byte1: CC != AA (0), Byte2: 55 != AA (0), Byte3: AA==AA (1).
        // compare_vec = 4'b1001.
        // Expected: 2 matches but not contiguous (o_align = 0).
        i_input = 8'hAA;
        i_dict  = {8'hAA, 8'h55, 8'hCC, 8'hAA};
        #10;
        $display("%0t\t %h\t %h\t      %b\t     %b", $time, i_input, i_dict, o_no_match, o_align);
        
        // Test Case 5: No matches.
        // Let i_input = 8'hAA and dictionary = {8'h55, 8'h55, 8'h55, 8'h55}.
        // Expected: compare_vec = 4'b0000.
        // Decoder should report 0 matches, and alignment can be 0.
        i_input = 8'hAA;
        i_dict  = {8'h55, 8'h55, 8'h55, 8'h55};
        #10;
        $display("%0t\t %h\t %h\t      %b\t     %b", $time, i_input, i_dict, o_no_match, o_align);
        
        #10;
        $finish;
    end

endmodule
