`timescale 1ns / 1ps

module tb_matching_stage;
  // Parameters matching the DUT (matching_stage) parameters
  parameter WIDTH      = 64;   // Two 32-bit words in one 64-bit input
  parameter DICT_ENTRY = 16;
  parameter DICT_WORD  = 32;
  parameter WORD       = 32;
  parameter DATA_WIDTH = 32;
  
  // DUT inputs
  logic               i_clk;
  logic               i_reset;   // active-low reset
  logic [WIDTH-1:0]   i_word;
  
  // DUT outputs
  logic [3:0]  o_location2;
  logic [3:0]  o_location4;
  logic [11:0] o_codeded1;
  logic [11:0] o_codeded3;
  logic        o_dict_full;
  logic [5:0]  o_length1;
  logic [5:0]  o_length2;
  logic [2:0]  o_code1;
  logic [2:0]  o_code2;
  logic [511:0] dictionary_data;
  
  // Local dictionary array for lookup
  logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
  int dict_index = 0;
  
  // Instantiate the DUT
  matching_stage #(
    .WIDTH(WIDTH),
    .DICT_ENTRY(DICT_ENTRY),
    .DICT_WORD(DICT_WORD),
    .WORD(WORD)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_word(i_word),
    .o_location2(o_location2),
    .o_location4(o_location4),
    .o_codeded1(o_codeded1),
    .o_codeded3(o_codeded3),
    .o_dict_full(o_dict_full),
    .o_length1(o_length1),
    .o_length2(o_length2),
    .o_code1(o_code1),
    .o_code2(o_code2),
    .dictionary_data(dictionary_data)
  );
  
  // Clock generation: 10 ns period.
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  // Display the current i_word and dictionary_data at every clock edge.
  always @(posedge i_clk) begin
    $display("[Cycle %0t] i_word: %h", $time, i_word);
    $display("[Cycle %0t] dictionary_data: %h", $time, dictionary_data);
  end
  
  // Task to preload the dictionary.
  // This task sets i_word and also saves the words into a local lookup array.
  task preload_fifo_dict(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word = {word1, word0}; // Lower word is word0, upper is word1
      dict_mem[dict_index]   = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10; // Wait one clock cycle for the write to occur
    end
  endtask
  
  // Function (implemented as a task) to compute expected pattern info.
  // If the word is all zeros, it is "zzzz" (length = 2, encoding = 3'b000).
  // Else if the word matches any dictionary entry, it is "mmmm" (length = 6, encoding = 3'b001).
  // Otherwise, it is "xxxx" (length = 34, encoding = 3'b101).
  task automatic get_expected_pattern(
    input  logic [31:0] word,
    output logic [6:0] expected_length,
    output logic [2:0] expected_encoding
  );
    integer j;
    logic found;
    begin
      found = 0;
      if (word == 32'd0) begin
         expected_length   = 7'd2;
         expected_encoding = 3'b000;
         found = 1;
      end else begin
         for (j = 0; j < DICT_ENTRY; j = j + 1) begin
           if (dict_mem[j] == word) begin
             expected_length   = 7'd6;
             expected_encoding = 3'b001;
             found = 1;
           end
         end
         if (!found) begin
           expected_length   = 7'd34;
           expected_encoding = 3'b101;
         end
      end
    end
  endtask
  
  // Task: Check pattern matching outputs.
  // This task uses get_expected_pattern for both first and second words.
  task check_pattern(
    input [31:0] first_word,
    input [31:0] second_word
  );
    logic [6:0] exp_length1, exp_length2;
    logic [2:0] exp_code1, exp_code2;
    begin
      get_expected_pattern(first_word, exp_length1, exp_code1);
      get_expected_pattern(second_word, exp_length2, exp_code2);
      $display("[Pattern Check] First Word = %h, Second Word = %h", first_word, second_word);
      
      if (o_code1 !== exp_code1 || o_length1 !== exp_length1)
        $display("[ERROR] First word pattern mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code1, exp_length1, o_code1, o_length1);
      else
        $display("[PASS] First word pattern matches.");
      
      if (o_code2 !== exp_code2 || o_length2 !== exp_length2)
        $display("[ERROR] Second word pattern mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code2, exp_length2, o_code2, o_length2);
      else
        $display("[PASS] Second word pattern matches.");
    end
  endtask
  
  // Task: Check dictionary matching outputs.
  // It finds the location index of the word in the preloaded dictionary.
  task check_dictionary(input [31:0] first_word, input [31:0] second_word);
    integer found1, found2;
    begin
      found1 = -1;
      found2 = -1;
      for (int i = 0; i < DICT_ENTRY; i++) begin
        if (dict_mem[i] == first_word) found1 = i;
        if (dict_mem[i] == second_word) found2 = i;
      end
      $display("[Dictionary Check] First Word = %h, Second Word = %h", first_word, second_word);
      if (o_location2 !== found1[3:0])
        $display("[ERROR] First word dictionary location mismatch: Expected %d, Got %d", found1, o_location2);
      else
        $display("[PASS] First word dictionary location matches.");
      if (o_location4 !== found2[3:0])
        $display("[ERROR] Second word dictionary location mismatch: Expected %d, Got %d", found2, o_location4);
      else
        $display("[PASS] Second word dictionary location matches.");
    end
  endtask
  
  // Test sequence.
  initial begin
    $dumpfile("tb_matching_stage.vcd");
    $dumpvars(0, tb_matching_stage);
    
    // Active-low reset: assert reset first
    i_reset = 0;
    i_word  = 64'd0;
    #15;
    i_reset = 1;  // release reset
    #10;
    
    // Preload dictionary with known values.
    preload_fifo_dict(32'hAABBCCDD, 32'h11223344);  // words 0 & 1
    preload_fifo_dict(32'h55667788, 32'h99AABBCC);  // words 2 & 3
    preload_fifo_dict(32'hDDEEFF00, 32'h12345678);  // words 4 & 5
    preload_fifo_dict(32'h9ABCDEF0, 32'h0F0E0D0C);  // words 6 & 7
    preload_fifo_dict(32'h87654321, 32'hFEDCBA98);  // words 8 & 9
    preload_fifo_dict(32'h00112233, 32'h44556677);  // words 10 & 11
    preload_fifo_dict(32'h8899AABB, 32'hCCDDEEFF);  // words 12 & 13
    preload_fifo_dict(32'h10203040, 32'h50607080);  // words 14 & 15
    $display("Dictionary preloaded.");
    
    // Test Case 1: Input word equals one of the dictionary words.
    // First word = 0xAABBCCDD, second word = 0x11223344.
    i_word = {32'h11223344, 32'hAABBCCDD};
    #20;
    check_pattern(32'hAABBCCDD, 32'h11223344);
    check_dictionary(32'hAABBCCDD, 32'h11223344);
    
    // Test Case 2: Input word is all zeros (zzzz pattern).
    i_word = {32'h00000000, 32'h00000000};
    #20;
    check_pattern(32'h00000000, 32'h00000000);
    // Since a zero word is not expected in dictionary, we assume default location 0.
    check_dictionary(32'h00000000, 32'h00000000);
    
    // Test Case 3: Input word does not match any dictionary entry (xxxx pattern).
    i_word = {32'hDEADBEEF, 32'hFACECAFE};
    #20;
    check_pattern(32'hDEADBEEF, 32'hFACECAFE);
    $display("[Test for non-matching dictionary]: Expected locations 0 for non-match");
    check_dictionary(32'hDEADBEEF, 32'hFACECAFE);
    
    $display("All tests completed.");
    #20;
    $finish;
  end
  
endmodule
