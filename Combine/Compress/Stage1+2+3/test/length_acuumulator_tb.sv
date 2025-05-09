`timescale 1ns/1ps

module tb_length_accumulator;

  // Parameters
  parameter CACHE_LINE = 128;
  parameter WORD_SIZE  = 64;

  // DUT Signals
  logic         clk;
  logic         reset;
  logic [6:0]   i_total_length;
  logic         o_store_flag;
  logic [7:0]   o_shift_amount;
  logic         o_fill_flag;
  logic         o_output_flag;
  logic         o_fill_ctrl;
  logic         o_stop_flag;
  logic         o_done_flag;
  logic         o_finish_final;
  logic         o_push_flag;
  logic         push_flag_n2;

  // DUT Instantiation
  length_accumulator #(
    .CACHE_LINE(CACHE_LINE),
    .WORD_SIZE(WORD_SIZE)
  ) dut (
    .i_clk(clk),
    .i_reset(reset),
    .i_total_length(i_total_length),
    .o_store_flag(o_store_flag),
    .o_shift_amount(o_shift_amount),
    .o_fill_flag(o_fill_flag),
    .o_output_flag(o_output_flag),
    .o_fill_ctrl(o_fill_ctrl),
    .o_stop_flag(o_stop_flag),
    .o_done_flag(o_done_flag),
    .o_finish_final(o_finish_final),
    .o_push_flag(o_push_flag)
  );
 assign push_flag_n2 = dut.push_flag_n2;
  // Clock generation
  always #5 clk = ~clk;

  // Task to apply total_length and wait a cycle
  task apply_total_length(input [6:0] len);
    i_total_length = len;
    @(posedge clk);
  endtask

  // Stimulus
  initial begin
    $display("Start Simulation");
    clk = 0;
    reset = 0;
    i_total_length = 0;

    @(posedge clk);
    reset = 1;
    @(posedge clk);


    apply_total_length(7'd40);
    apply_total_length(7'd12);  
    apply_total_length(7'd12);
    apply_total_length(7'd24);  
    apply_total_length(7'd32);  
    apply_total_length(7'd8);  

    apply_total_length(7'd48);   
    apply_total_length(7'd8);
    apply_total_length(7'd68);  
    apply_total_length(7'd4);
    repeat(5) @(posedge clk);

    $display("End Simulation");
    $finish;
  end

  // Monitor
  always @(posedge clk) begin
    $display("Time %0t | i_total_length=%0d | shift=%0d | store=%b | output=%b | stop=%b | push=%b | fill=%b | fill_ctrl=%b | done=%b | final=%b",
             $time, i_total_length, o_shift_amount, o_store_flag, o_output_flag, o_stop_flag,
             o_push_flag, o_fill_flag, o_fill_ctrl, o_done_flag, o_finish_final);
  end

endmodule
