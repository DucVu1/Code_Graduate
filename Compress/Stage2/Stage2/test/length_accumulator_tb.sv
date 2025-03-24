`timescale 1ns/1ps

module tb_length_accumulator;

  parameter CACHE_LINE = 128;
  parameter WORD_SIZE  = 64;
  
  // DUT signals
  logic         clk;
  logic         i_reset;
  logic [6:0]   i_total_length;
  logic         o_store_flag;
  logic [6:0]   o_shift_amount;
  logic         o_send_back;

  // Expected values for checking
  logic         expected_store_flag;
  logic [6:0]   expected_shift_amount;
  logic         expected_send_back;
  
  logic [6:0]   sum_partial;  
  logic [7:0]   sum_total;    

  // Instantiate the DUT
  length_accumulator #(
    .CACHE_LINE(CACHE_LINE),
    .WORD_SIZE(WORD_SIZE)
  ) dut (
    .clk(clk),
    .i_reset(i_reset),
    .i_total_length(i_total_length),
    .o_store_flag(o_store_flag),
    .o_shift_amount(o_shift_amount),
    .o_send_back(o_send_back)
  );
  
  // Clock generation: 10 ns period.
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Monitor the signals
  initial begin
    $monitor("Time=%0t: i_total_length=%d, o_store_flag=%b, o_shift_amount=%d, o_send_back=%b", 
             $time, i_total_length, o_store_flag, o_shift_amount, o_send_back);
  end
  
  // Test sequence
  initial begin
    $dumpfile("tb_length_accumulator.vcd");
    $dumpvars(0, tb_length_accumulator);
    
    // Apply reset
    i_reset = 0;
    i_total_length = 7'd0;
    sum_partial = 0;
    sum_total = 0;
    #15;
    i_reset = 1;

    // Test cases
    repeat (5) begin
      test_case(7'd10);
      #10;
      test_case(7'd20);
      #10;
      test_case(7'd40);
      #10;
      test_case(7'd5);
      #10;
      test_case(7'd60);
      #10;
    end

    $display("Test complete.");
    #20;
    $finish;
  end

  // Task to apply stimulus and check output
  task test_case(input logic [6:0] length);
    begin
      i_total_length = length;


      // Compute expected values
      sum_partial = sum_partial + length;
      sum_total   = sum_total + length;

      if (sum_partial >= WORD_SIZE) begin
        expected_store_flag   = 1;
        expected_shift_amount = sum_partial - WORD_SIZE;
        sum_partial           = sum_partial - WORD_SIZE;
      end else begin
        expected_store_flag   = 0;
        expected_shift_amount = sum_partial;
      end

      if (sum_total >= CACHE_LINE)begin
        expected_send_back   = 1;
        sum_total           = sum_total - CACHE_LINE;
      end else begin
        expected_send_back   = 0;
      end

      // Check outputs
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
