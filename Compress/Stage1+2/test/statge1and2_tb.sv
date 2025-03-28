`timescale 1ns / 1ps

module tb_stage1and2;
  // Parameters matching the DUT (stage1and2) parameters.
  parameter WIDTH      = 64;   // Two 32-bit words in one 64-bit input
  parameter DICT_ENTRY = 16;
  parameter DICT_WORD  = 32;
  parameter WORD       = 32;
  parameter CACHE_LINE = 128;
  parameter DATA_WIDTH = 32;
  
  // DUT inputs
  logic               i_clk;
  logic               i_reset;    // active-low reset
  logic [WIDTH-1:0]   i_word;
  
  // DUT outputs
  logic               o_store_flag;  
  logic [6:0]         o_shift_amount;
  logic               o_send_back;
  logic [511:0]       dictionary_data;
  
  // Local dictionary memory array for lookup (simulate preloaded dictionary)
  logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
  int dict_index = 0;
  
  // Instantiate the DUT: stage1and2.
  stage1and2 #(
    .WIDTH(WIDTH),
    .DICT_ENTRY(DICT_ENTRY),
    .DICT_WORD(DICT_WORD),
    .WORD(WORD),
    .CACHE_LINE(CACHE_LINE)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_word(i_word),
    .o_store_flag(o_store_flag),
    .o_shift_amount(o_shift_amount),
    .o_send_back(o_send_back),
    .dictionary_data(dictionary_data)
  );
  
  // Clock generation: 10 ns period.
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  // Dump waveforms for debugging.
  initial begin
    $dumpfile("tb_stage1and2.vcd");
    $dumpvars(0, tb_stage1and2);
  end
    // Task: Initialize the dictionary.
  task init_dictionary();
    begin
      preload_fifo_dict(32'hAABBCCDD, 32'h11223344);  // words 0 & 1
      preload_fifo_dict(32'h55667788, 32'h99AABBCC);  // words 2 & 3
      preload_fifo_dict(32'hDDEEFF00, 32'h12345678);  // words 4 & 5
      preload_fifo_dict(32'h9ABCDEF0, 32'h0F0E0D0C);  // words 6 & 7
      preload_fifo_dict(32'h87654321, 32'hFEDCBA98);  // words 8 & 9
      preload_fifo_dict(32'h00112233, 32'h44556677);  // words 10 & 11
      preload_fifo_dict(32'h8899AABB, 32'hCCDDEEFF);  // words 12 & 13
      preload_fifo_dict(32'h10203040, 32'h50607080);  // words 14 & 15
    end
  endtask
  
  // Task: Preload dictionary word pair
  task preload_fifo_dict(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word <= {word1, word0};
      dict_mem[dict_index]   = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10;
    end
  endtask
  // ---------------------------
  // Task: init_dictionary
  // Preloads the dictionary in the DUT by driving i_word with known pairs.
  // Also stores the words in a local array for later checking.
  // ---------------------------
  task init_dictionary();
    begin
      preload_word(32'hAABBCCDD, 32'h11223344); // dictionary words 0 & 1
      preload_word(32'h55667788, 32'h99AABBCC); // words 2 & 3
      preload_word(32'hDDEEFF00, 32'h12345678); // words 4 & 5
      preload_word(32'h9ABCDEF0, 32'h0F0E0D0C); // words 6 & 7
      preload_word(32'h87654321, 32'hFEDCBA98); // words 8 & 9
      preload_word(32'h00112233, 32'h44556677); // words 10 & 11
      preload_word(32'h8899AABB, 32'hCCDDEEFF); // words 12 & 13
      preload_word(32'h10203040, 32'h50607080); // words 14 & 15
      $display("Dictionary preloaded.");
    end
  endtask
  
  // ---------------------------
  // Task: preload_word
  // Drives i_word with a pair of words to preload the dictionary.
  // Also updates the local dict_mem array.
  // ---------------------------
  task preload_word(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word = {word1, word0}; // Lower word is word0, upper word is word1
      dict_mem[dict_index]   = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10; // Wait one clock cycle for the dictionary to update.
    end
  endtask
  
  // ---------------------------
  // Task: check_pattern_zz
  // Checks the case when the pattern is "zzzz" or "zzzx".
  // For example, if a word is all zeros, it's "zzzz" (expected compressed length = 2, code = 000).
  // You can update the expected values to match your design.
  // ---------------------------
  task check_pattern_zz(input [31:0] first_word, input [31:0] second_word);
    logic [6:0] exp_length1, exp_length2;
    logic [2:0] exp_code1, exp_code2;
    begin
      // If a word is all zero, we treat it as pattern "zzzz"
      if (first_word == 32'd0) begin
        exp_length1 = 7'd2;
        exp_code1   = 3'b000;
      end else begin
        // If not all zero but nearly, we can treat it as "zzzx"
        exp_length1 = 7'd12;
        exp_code1   = 3'b010;
      end
      
      if (second_word == 32'd0) begin
        exp_length2 = 7'd2;
        exp_code2   = 3'b000;
      end else begin
        exp_length2 = 7'd12;
        exp_code2   = 3'b010;
      end
      
      $display("[Pattern Check: zzzz/zzzx] First Word = %h, Second Word = %h", first_word, second_word);
      if ((o_code1 !== exp_code1) || (o_length1 !== exp_length1))
        $display("[ERROR] First word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code1, exp_length1, o_code1, o_length1);
      else
        $display("[PASS] First word pattern OK.");
      
      if ((o_code2 !== exp_code2) || (o_length2 !== exp_length2))
        $display("[ERROR] Second word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code2, exp_length2, o_code2, o_length2);
      else
        $display("[PASS] Second word pattern OK.");
    end
  endtask
  
  // ---------------------------
  // Task: check_pattern_other
  // Checks cases when the words are not all zeros.
  // For example, if a word exactly matches a dictionary entry, we treat it as "mmmm"
  // (expected length = 6, code = 001), otherwise "xxxx" (expected length = 34, code = 101).
  // ---------------------------
  task check_pattern_other(input [31:0] first_word, input [31:0] second_word);
    logic [6:0] exp_length1, exp_length2;
    logic [2:0] exp_code1, exp_code2;
    integer j;
    logic found1, found2;
    begin
      found1 = 0;
      found2 = 0;
      // Check first word against dictionary
      for (j = 0; j < DICT_ENTRY; j = j + 1) begin
        if (dict_mem[j] == first_word) begin
          found1 = 1;
          break;
        end
      end
      if (found1) begin
        exp_length1 = 7'd6;
        exp_code1   = 3'b001;
      end else begin
        exp_length1 = 7'd34;
        exp_code1   = 3'b101;
      end
      
      // Check second word against dictionary
      for (j = 0; j < DICT_ENTRY; j = j + 1) begin
        if (dict_mem[j] == second_word) begin
          found2 = 1;
          break;
        end
      end
      if (found2) begin
        exp_length2 = 7'd6;
        exp_code2   = 3'b001;
      end else begin
        exp_length2 = 7'd34;
        exp_code2   = 3'b101;
      end
      
      $display("[Pattern Check: Other] First Word = %h, Second Word = %h", first_word, second_word);
      if ((o_code1 !== exp_code1) || (o_length1 !== exp_length1))
        $display("[ERROR] First word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code1, exp_length1, o_code1, o_length1);
      else
        $display("[PASS] First word pattern OK.");
      
      if ((o_code2 !== exp_code2) || (o_length2 !== exp_length2))
        $display("[ERROR] Second word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code2, exp_length2, o_code2, o_length2);
      else
        $display("[PASS] Second word pattern OK.");
    end
  endtask
  
  // ---------------------------
  // Task: check_length
  // Checks the control signals from the length generation stage:
  // o_store_flag, o_shift_amount, and o_send_back.
  // (You need to update these expected values based on your design.)
  // ---------------------------
  task check_length(input logic exp_store_flag, input logic [6:0] exp_shift_amount, input logic exp_send_back);
    begin
      $display("[Length Check] store_flag=%b, shift_amount=%d, send_back=%b", 
               o_store_flag, o_shift_amount, o_send_back);
      if (o_store_flag !== exp_store_flag)
        $display("[ERROR] store_flag mismatch: Expected %b, Got %b", exp_store_flag, o_store_flag);
      if (o_shift_amount !== exp_shift_amount)
        $display("[ERROR] shift_amount mismatch: Expected %d, Got %d", exp_shift_amount, o_shift_amount);
      if (o_send_back !== exp_send_back)
        $display("[ERROR] send_back mismatch: Expected %b, Got %b", exp_send_back, o_send_back);
    end
  endtask
  
  // ---------------------------
  // Test Sequence
  // ---------------------------
  initial begin
    $dumpfile("tb_stage1and2.vcd");
    $dumpvars(0, tb_stage1and2);
    
    // Reset sequence (active-low reset)
    i_reset = 0;  // Assert reset
    i_word = 64'd0;
    #15;
    i_reset = 1;  // Release reset
    #10;
    
    // Initialize dictionary by preloading known words.
    init_dictionary();
    
    // Test Case 1: Use dictionary match for both words.
    // For example, first word = 0xAABBCCDD, second word = 0x11223344
    // (Both are in the dictionary per init_dictionary.)
    i_word = {32'h11223344, 32'hAABBCCDD};
    #20;
    $display("Test Case 1: Dictionary Match");
    // Expect pattern "mmmm": length = 6, code = 001 for both words.
    check_pattern_other(32'hAABBCCDD, 32'h11223344);
    check_length(0, 7'd?, 0); // Replace 7'd? with expected shift amount based on your length generation logic.
    
    // Test Case 2: Use "zzzz" pattern (all zeros)
    i_word = {32'h00000000, 32'h00000000};
    #20;
    $display("Test Case 2: ZZZZ Pattern");
    check_pattern_zz(32'h00000000, 32'h00000000);
    check_length(0, 7'd?, 0); // Expected shift amount, etc.
    
    // Test Case 3: Non-matching words ("xxxx" pattern)
    i_word = {32'hDEADBEEF, 32'hFACECAFE};
    #20;
    $display("Test Case 3: Non-Matching Pattern");
    check_pattern_other(32'hDEADBEEF, 32'hFACECAFE);
    check_length(1, 7'd?, 0); // For example, if store_flag is asserted when partial length exceeds 64 bits.
    
    $display("All tests completed.");
    #20;
    $finish;
  end
  


endmodule
