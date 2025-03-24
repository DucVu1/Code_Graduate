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
  always @(posedge i_clk) begin
    $display("[Cycle %0t] word: %h", $time, i_word);
    $display("[Cycle %0t] dictionary_data: %h", $time, dictionary_data);
  end

  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  task preload_fifo_dict(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word = {word1, word0};
      dict_mem[dict_index] = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10;
    end
  endtask
  
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
    if ((o_code1 !== expected_code1) || (o_length1 !== expected_length1))     
      $display("[ERROR] First word mismatch");
    if ((o_code2 !== expected_code2) || (o_length2 !== expected_length2))      
      $display("[ERROR] Second word mismatch");    
  end  endtask
  
  task check_dictionary(input [31:0] first_word, input [31:0] second_word);
    integer found1, found2;
    begin
      for (int i = 0; i < DICT_ENTRY; i++) begin
        if (dict_mem[i] == first_word) found1 = i;
        if (dict_mem[i] == second_word) found2 = i;
      end
      $display("[Dictionary Check] First Word = %h, Second Word = %h", first_word, second_word);
      if (o_location2 !== found1[3:0])
        $display("[ERROR] First word location mismatch");
      if (o_location4 !== found2[3:0])
        $display("[ERROR] Second word location mismatch");
    end
  endtask
  
  initial begin
    $dumpfile("tb_matching_stage.vcd");
    $dumpvars(0, tb_matching_stage);
    i_reset = 0;
    i_word = 64'd0;
    #15;
    i_reset = 1;
    #20;
    preload_fifo_dict(32'hAABBCCDD, 32'h11223344);
    preload_fifo_dict(32'h55667788, 32'h99AABBCC);
    preload_fifo_dict(32'hDDEEFF00, 32'h12345678);
    preload_fifo_dict(32'h9ABCDEF0, 32'h0F0E0D0C);
    preload_fifo_dict(32'h87654321, 32'hFEDCBA98);
    preload_fifo_dict(32'h00112233, 32'h44556677);
    preload_fifo_dict(32'h8899AABB, 32'hCCDDEEFF);
    preload_fifo_dict(32'h10203040, 32'h50607080);
    $display("Dictionary preloaded.");
    
    i_word = {32'hAABBCCDD, 32'h11223344};
    #20;
    check_pattern(32'hAABBCCDD, 32'h11223344, 3'b010, 6'd12, 3'b011, 6'd16);
    check_dictionary(32'h11223344, 32'hAABBCCDD);
    
    i_word = {32'h55667788, 32'h99AABBCC};
    #20;
    check_pattern(32'h55667788, 32'h99AABBCC, 3'b001, 6'd6, 3'b100, 6'd10);
    check_dictionary(32'h99AABBCC, 32'h55667788);
    
    i_word = {32'hFACECAFE, 32'hDEADBEEF};
    #20;
    $display("[Test for non-matching words]");
    if (o_location2 !== 0 && o_location4 !== 0)
      $display("[ERROR] Unexpected match found!");
    else
      $display("[PASS] No match found as expected.");
    
    $display("All tests completed.");
    #20;    
    $finish;
  end
endmodule
