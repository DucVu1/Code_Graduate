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
  logic               i_reset;
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
  logic [511:0]dictionary_data;
  
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
  
  // Clock generation: 10 ns period
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  // ----------------------------------------------------------------------  
  // Task: Preload the FIFO dictionary with known values.
  // This task writes two words at a time into the dictionary. We use hierarchical
  // references to drive the internal fifo_dict instance (named 'dictionary' in uut).
  // You can adjust the number of cycles to cover all 16 words.
  // ----------------------------------------------------------------------
  task preload_fifo_dict(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word = {word1, word0};
      #10;  // Wait one clock cycle for the write to occur

    end
  endtask
  
  // ----------------------------------------------------------------------  
  // Task: Check pattern matching outputs
  // For the two input words, check the encoded value and length outputs from the word_length generators.
  // ----------------------------------------------------------------------
  task check_pattern(
    input [31:0] first_word,
    input [31:0] second_word,
    input [2:0] expected_code1,
    input [5:0] expected_length1,
    input [2:0] expected_code2,
    input [5:0] expected_length2
  );
  begin
    $display("[Pattern Check] First Word = %h, Second Word = %h", first_word, second_word);
    $display("  o_code1 = %b, o_length1 = %d", o_code1, o_length1);
    $display("  o_code2 = %b, o_length2 = %d", o_code2, o_length2);
    if ((o_code1 !== expected_code1) || (o_length1 !== expected_length1))     
      $display("[ERROR] First word pattern mismatch: Expected code=%b, length=%d", expected_code1, expected_length1);
    else      $display("[PASS] First word pattern matches.");    
    if ((o_code2 !== expected_code2) || (o_length2 !== expected_length2))      
    $display("[ERROR] Second word pattern mismatch: Expected code=%b, length=%d", expected_code2, expected_length2);    
    else   $display("[PASS] Second word pattern matches.");
   end  endtask
  
  // ----------------------------------------------------------------------  
  // Task: Check dictionary matching outputs
  // This task checks the outputs from the dictionary matching blocks:
  // o_location2 and o_location4.
  // ----------------------------------------------------------------------
  task check_dictionary(
    input [31:0] first_word,
    input [31:0] second_word,
    input [4:0] expected_location2,
    input [4:0] expected_location4
  );
  begin
    $display("[Dictionary Check] First Word = %h, Second Word = %h", first_word, second_word);
    $display("  o_location2 = %d, o_location4 = %d", o_location2, o_location4);
    if (o_location2 !== expected_location2)
         $display("[ERROR] Dictionary first word mismatch: Expected location = %d", expected_location2);
    else      
    $display("[PASS] Dictionary first word matches.");
    if (o_location4 !== expected_location4)      $display("[ERROR] Dictionary second word mismatch: Expected location = %d", expected_location4);
    else      $display("[PASS] Dictionary second word matches.");  
    end
  endtask
  
  // ----------------------------------------------------------------------  
  // Preload dictionary at start of simulation.
  // We'll preload the FIFO dictionary with a known pattern (16 words).
  // ----------------------------------------------------------------------
  // initial begin
  //   // Wait until reset is deasserted.
  //   //@(negedge i_reset);
  //   // Preload dictionary with 8 cycles (2 words per cycle)
  //   preload_fifo_dict(32'hAABBCCDD, 32'h11223344);  // This writes to dictionary word 0 and 1
  //   preload_fifo_dict(32'h55667788, 32'h99AABBCC);  // Writes to words 2 and 3
  //   preload_fifo_dict(32'hDDEEFF00, 32'h12345678);  // Writes to words 4 and 5
  //   preload_fifo_dict(32'h9ABCDEF0, 32'h0F0E0D0C);  // Writes to words 6 and 7
  //   preload_fifo_dict(32'h87654321, 32'hFEDCBA98);  // Writes to words 8 and 9
  //   preload_fifo_dict(32'h00112233, 32'h44556677);  // Writes to words 10 and 11
  //   preload_fifo_dict(32'h8899AABB, 32'hCCDDEEFF);  // Writes to words 12 and 13
  //   preload_fifo_dict(32'h10203040, 32'h50607080);  // Writes to words 14 and 15 
  //   $display("Dictionary preloaded.");  
  //   end
  initial begin
  
  $dumpfile("tb_matching_stage.vcd");
  $dumpvars(0, tb_matching_stage);
  i_reset = 1;
  i_word = 64'd0;
  #15;
  i_reset = 0;
  preload_fifo_dict(32'hAABBCCDD, 32'h11223344);  // This writes to dictionary word 0 and 1
  preload_fifo_dict(32'h55667788, 32'h99AABBCC);  // Writes to words 2 and 3
  preload_fifo_dict(32'hDDEEFF00, 32'h12345678);  // Writes to words 4 and 5
  preload_fifo_dict(32'h9ABCDEF0, 32'h0F0E0D0C);  // Writes to words 6 and 7
  preload_fifo_dict(32'h87654321, 32'hFEDCBA98);  // Writes to words 8 and 9
  preload_fifo_dict(32'h00112233, 32'h44556677);  // Writes to words 10 and 11
  preload_fifo_dict(32'h8899AABB, 32'hCCDDEEFF);  // Writes to words 12 and 13
  preload_fifo_dict(32'h10203040, 32'h50607080);  // Writes to words 14 and 15 
  $display("Dictionary preloaded.");  
  // Test Case 1:
  // First word matches a known dictionary entry pattern (e.g., zzzz) and second word is arbitrary.
  i_word = {32'h55AA55AA, 32'h00000000};
   // first word = 0x00000000 (zzzz), second word = 0x55AA55AA\n
  #20;
  $display("--- Test Case 1 ---");
  // Expected pattern: for zzzz, let's assume word_length_genetator returns o_code1 = 3'b000 and o_length1 = 6'd2.\n 
  // Expected dictionary matching: assume dictionary matching finds entry 5 for first word and entry 7 for second word (example values).
  check_pattern(32'h00000000, 32'h55AA55AA, 3'b000, 6'd2, 3'b010, 6'd12);
  check_dictionary(32'h00000000, 32'h55AA55AA, 5, 7);
  
  // Test Case 2:
  // First word is mmmm and second word is arbitrary.
  i_word = {32'h12345678, 32'hFFFFFFFF};
  #20;    
  $display("--- Test Case 2 ---");
  // Expected pattern: for mmmm, assume o_code1 = 3'b001, o_length1 = 6'd6; \n    
  // and for second word, expected o_code2 = 3'b??? and o_length2 = 6'd??? (fill as per design).    
  // Expected dictionary matching: assume expected locations are 3 for first word and 10 for second word.
  check_pattern(32'hFFFFFFFF, 32'h12345678, 3'b001, 6'd6, 3'd4, 6'd5);
  check_dictionary(32'hFFFFFFFF, 32'h12345678, 3, 10);
  // Test Case 3:
  // First word = zzzx and second word = mmmx.
  i_word = {32'hFACECAFE, 32'h000000A5};
  #20;
  $display("--- Test Case 3 ---");
  // Expected: o_code1 = 3'b010, o_length1 = 6'd12; o_code2 = 3'b011, o_length2 = 6'd16
     // Expected dictionary matching: assume expected locations 8 for first word and 12 for second word.
  check_pattern(32'h000000A5, 32'hFACECAFE, 3'b010, 6'd12, 3'b011, 6'd16);
  check_dictionary(32'h000000A5, 32'hFACECAFE, 8, 12);
  $display("All tests completed.");
  #20;    
  $finish;
  end
  endmodule
