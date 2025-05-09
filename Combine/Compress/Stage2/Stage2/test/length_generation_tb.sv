`timescale 1ns/1ps

module length_generation_tb;

  parameter CACHE_LINE = 128;
  parameter WORD_SIZE  = 64;

  // DUT Signals
  logic         i_clk;
  logic         i_reset;
  logic [3:0]   i_type_matched2;
  logic [1:0]   i_type_matched1;
  logic [1:0]   i_match_s;
  logic         o_store_flag;
  logic [6:0]   o_shift_amount;
  logic         o_send_back;

  // Expected values for checking
  logic [6:0]   expected_shift_amount;
  logic         expected_store_flag;
  logic         expected_send_back;

  // Instantiate the DUT
  length_generation #(
    .CACHE_LINE(CACHE_LINE),
    .WORD_SIZE(WORD_SIZE)
  ) dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_type_matched2(i_type_matched2),
    .i_type_matched1(i_type_matched1),
    .i_match_s(i_match_s),
    .o_store_flag(o_store_flag),
    .o_shift_amount(o_shift_amount),
    .o_send_back(o_send_back)
  );

  // Clock Generation: 10 ns period
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  // Monitor the signals
  initial begin
    $monitor("Time=%0t: i_type_matched2=%b, i_type_matched1=%b, i_match_s=%b, o_store_flag=%b, o_shift_amount=%d, o_send_back=%b",
             $time, i_type_matched2, i_type_matched1, i_match_s, o_store_flag, o_shift_amount, o_send_back);
  end

  // Test sequence
  initial begin
    $dumpfile("length_generation_tb.vcd");
    $dumpvars(0, length_generation_tb);

    // Reset the module
    i_reset = 1;
    i_type_matched2 = 4'b0000;
    i_type_matched1 = 2'b00;
    i_match_s = 2'b00;
    #15;
    i_reset = 0; // Apply reset
    #10;
    i_reset = 1; // Release reset

    // Apply test cases
    test_case(4'b1100, 2'b11, 2'b01);
    test_case(4'b1010, 2'b00, 2'b10);
    test_case(4'b0111, 2'b01, 2'b11);
    test_case(4'b0000, 2'b10, 2'b00);
    test_case(4'b1111, 2'b11, 2'b11);

    // Randomized testing
    repeat (10) begin
      test_case($random, $random, $random);
    end

    $display("Test complete.");
    #20;
    $finish;
  end

  // Task to apply stimulus and check output
  task test_case(input logic [3:0] type_matched2, input logic [1:0] type_matched1, input logic [1:0] match_s);
    begin
      i_type_matched2 = type_matched2;
      i_type_matched1 = type_matched1;
      i_match_s       = match_s;
      #10; // Wait for one clock cycle

      // Compute expected values (replace this with actual logic to predict expected outputs)
      expected_store_flag   = 0; // Placeholder
      expected_shift_amount = 0; // Placeholder
      expected_send_back    = 0; // Placeholder

      // Compare expected and actual outputs
      assert (o_store_flag == expected_store_flag) 
        else $error("Mismatch at time %0t: Expected o_store_flag=%b, Got o_store_flag=%b",
                    $time, expected_store_flag, o_store_flag);
      
      assert (o_shift_amount == expected_shift_amount) 
        else $error("Mismatch at time %0t: Expected o_shift_amount=%d, Got o_shift_amount=%d",
                    $time, expected_shift_amount, o_shift_amount);
      
      assert (o_send_back == expected_send_back) 
        else $error("Mismatch at time %0t: Expected o_send_back=%b, Got o_send_back=%b",
                    $time, expected_send_back, o_send_back);
    end
  endtask

endmodule
