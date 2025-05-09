`timescale 1ns/1ps

module tb_reg_out;

  parameter WIDTH   = 32;
  parameter O_WIDTH = 128;

  logic                 i_clk;
  logic                 i_reset;
  logic [WIDTH-1:0]     i_word1, i_word2;
  logic [O_WIDTH-1:0]   o_word;
  logic                 o_count;
  logic [1:0]           word_count_r;

  // Instantiate the DUT
  reg_out #(
    .WIDTH(WIDTH),
    .O_WIDTH(O_WIDTH)
  ) dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_word1(i_word1),
    .i_word2(i_word2),
    .o_word(o_word),
    .o_count(o_count)
  );

 assign word_count_r = dut.word_count_r; 
  // Clock generation
  always #5 i_clk = ~i_clk;

  // Task to send input
  task send_input(input [WIDTH-1:0] w1, input [WIDTH-1:0] w2);
    begin
      @(posedge i_clk);
      i_word1 = w1;
      i_word2 = w2;
    end
  endtask

  initial begin
    $display("Starting Testbench...");
    i_clk   = 0;
    i_reset = 0;
    i_word1 = 0;
    i_word2 = 0;

    // Reset sequence
    @(negedge i_clk);
    i_reset = 1;
    @(negedge i_clk);
    i_reset = 0;
    repeat (2) @(posedge i_clk);
    i_reset = 1;

    // First 64-bit input
    send_input(32'h1111_1111, 32'h2222_2222);  // Cycle 1
    assert(o_count == 0) else $error("Output count should be 0 after 1st input");

    // Second 64-bit input -> triggers output
    send_input(32'h3333_3333, 32'h4444_4444);  // Cycle 2
    assert(o_count == 1) else $error("Output count should be 1 after 2nd input");
    $display("Output Word = %h", o_word);
    // Expect: o_word = 4444_4444_3333_3333_2222_2222_1111_1111

    // Next set
    send_input(32'hAAAA_AAAA, 32'hBBBB_BBBB);  // Cycle 3
    assert(o_count == 0);
    send_input(32'hCCCC_CCCC, 32'hDDDD_DDDD);  // Cycle 4
    assert(o_count == 1);
    $display("Output Word = %h", o_word);
    // Expect: o_word = DDDD_DDDD_CCCC_CCCC_BBBB_BBBB_AAAA_AAAA

    // === Additional testcases ===

    // Test 5: Alternating bits
    send_input(32'h5555_5555, 32'hAAAA_AAAA);  // Cycle 5
    assert(o_count == 0);
    send_input(32'hFFFF_0000, 32'h0000_FFFF);  // Cycle 6
    assert(o_count == 1);
    $display("Output Word = %h", o_word);

    // Test 6: Zero pattern
    send_input(32'h0000_0000, 32'h0000_0000);  // Cycle 7
    assert(o_count == 0);
    send_input(32'h0000_0000, 32'h0000_0000);  // Cycle 8
    assert(o_count == 1);
    $display("Output Word = %h", o_word);

    // Test 7: All ones
    send_input(32'hFFFF_FFFF, 32'hFFFF_FFFF);  // Cycle 9
    assert(o_count == 0);
    send_input(32'hFFFF_FFFF, 32'hFFFF_FFFF);  // Cycle 10
    assert(o_count == 1);
    $display("Output Word = %h", o_word);

    // Test 8: Incremental pattern
    send_input(32'h0000_0001, 32'h0000_0002);  // Cycle 11
    assert(o_count == 0);
    send_input(32'h0000_0003, 32'h0000_0004);  // Cycle 12
    assert(o_count == 1);
    $display("Output Word = %h", o_word);

    $display("All tests passed!");
    $finish;
  end

endmodule
