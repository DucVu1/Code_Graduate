`timescale 1ns / 1ps

module tb_fifo_dict;
  parameter DATA_WIDTH = 32;
  parameter WORDS_PER_ENTRY = 16;
  
  // DUT signals
  logic i_clk;
  logic i_reset;
  logic wr;
  logic wr2;
  logic [DATA_WIDTH-1:0] w_data;
  logic [DATA_WIDTH-1:0] w_data2;
  logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data;
  logic full;
  
  // Instantiate the DUT
  fifo_dict #(
    .DATA_WIDTH(DATA_WIDTH),
    .WORDS_PER_ENTRY(WORDS_PER_ENTRY)
  ) dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .wr(wr),
    .wr2(wr2),
    .w_data(w_data),
    .w_data2(w_data2),
    .r_data(r_data),
    .full(full)
  );
  
  // Clock generation: 10 ns period
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  // Test sequence
  initial begin
    $dumpfile("tb_fifo_dict.vcd");
    $dumpvars(0, tb_fifo_dict);
    
    // Apply reset
    i_reset = 1;
    wr = 0; wr2 = 0;
    w_data = 32'd0; w_data2 = 32'd0;
    #15;
    i_reset = 0;
    
    // Test 1: Single write cycle
    // Write one word into the dictionary.
    // Expected: The word at the current pointer is updated.
    @(posedge i_clk);
    wr = 1; wr2 = 0;
    w_data = 32'hDEADBEEF;
    #10;
    wr = 0;
    $display("After single write: r_data = %h, full = %b", r_data, full);
    
    // Test 2: Dual write cycle
    // Write two words in one clock cycle.
    @(posedge i_clk);
    wr = 1; wr2 = 1;
    w_data  = 32'hCAFEBABE;
    w_data2 = 32'h12345678;
    #10;
    wr = 0; wr2 = 0;
    $display("After dual write: r_data = %h, full = %b", r_data, full);
    
    // Test 3: Fill the FIFO dictionary
    // With dual writes, we need 7 more cycles to write 14 words then one cycle for a single write to complete 16 words.
    repeat (7) begin
      @(posedge i_clk);
      wr = 1; wr2 = 1;
      w_data  = $urandom_range(0, 32'hFFFFFFFF);
      w_data2 = $urandom_range(0, 32'hFFFFFFFF);
      #10;
      wr = 0; wr2 = 0;
    end
    // Final word: single write to complete 16 words.
    @(posedge i_clk);
    wr = 1; wr2 = 0;
    w_data = 32'hA5A5A5A5;
    #10;
    wr = 0;
    $display("After filling FIFO: r_data = %h, full = %b", r_data, full);
    
    // Test 4: Wrap-around test
    // With the FIFO full, the pointer should wrap-around and new writes will replace earlier values.
    @(posedge i_clk);
    wr = 1; wr2 = 1;
    w_data = 32'h11111111;
    w_data2 = 32'h22222222;
    #10;
    wr = 0; wr2 = 0;
    $display("After wrap-around dual write: r_data = %h, full = %b", r_data, full);
    
    $finish;
  end
  
endmodule
