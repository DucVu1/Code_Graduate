`timescale 1ns/1ps

module tb_compressor_decompressor;

  parameter WIDTH                 = 64;
  parameter WORD                  = 32;
  parameter CACHE_LINE            = 128;
  parameter SETUP_WAIT            = 0;

  int   log_file;
  logic i_clk;
  logic i_reset;
  logic i_compressor_en;
  logic [WIDTH-1:0]              i_word_c;
  logic [CACHE_LINE-1:0]         o_compressed_word;
  logic                          o_compressed_flag;
  logic                          i_compressed_flag;
  logic [7:0]                    o_shift_amount;
  logic [5:0]                    o_length1, o_length2;
  logic                          o_finish_c_flag;
  logic                          i_stop_flag;

  //logic [7:0]                    sum_total_reg;
  //logic [7:0]                    next_sum_total;

  // logic [5:0]                    o_length1;
  // logic [5:0]                    o_length2;
  // logic [3:0]                    i_type_matched2;
  // logic [1:0]                    i_type_matched1;
  // logic [3:0]                    o_type_matched2;
  // logic [1:0]                    o_type_matched1;
  //logic [CACHE_LINE-1:0]         o_backup_buffer3;
  logic [7:0]                    o_remain_length_n, o_remain_length, o_first_length, o_second_length;
  logic                          i_decompressor_en;
  logic                          i_update_d;
  logic [CACHE_LINE-1:0]         i_word_d;
  logic [CACHE_LINE-1:0]         o_decompressed_word;
  logic [196-1:0] shifted_data_n, shifted_data_r, reg_array1_out;
  logic [7 - 1 : 0]o_len_r;
  logic [195 : 0] o_mux_2; 
  logic [196 - 1 : 0]       o_barrel_shifter1; 
  logic [196 - 1 : 0]       o_barrel_shifter2; 
  logic [196 - 1 : 0]       o_or_gate; 
  logic                     o_comp_signal;
  logic [128 - 1 : 0]o_reg_array3;
  logic [128 - 1 : 0]o_latch;
  logic [31:0]  third_word, fourth_word;
  logic [196-1 : 0]         pre_word;
  logic [511:0] dictionary_data;

  // DUT
  compressor_decompressor #(
    .WIDTH(WIDTH),
    .DICT_ENTRY(16),
    .DICT_WORD(32),
    .WORD(WORD),
    .CACHE_LINE(CACHE_LINE),
    .TOTAL_BITS_COMPRESSED(34)
  ) dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_update_d(i_update_d),
    .i_decompressor_en(i_decompressor_en),
    .i_compressor_en(i_compressor_en),
    .i_compressed_flag(i_compressed_flag),
    .o_compressed_flag(o_compressed_flag),
    .i_word_c(i_word_c),
    .i_word_d(i_word_d),
    .o_compressed_word(o_compressed_word),
    .o_decompressed_word(o_decompressed_word),
    .o_finish_c_flag(o_finish_c_flag)
  );
assign third_word = dut.third_word;
assign fourth_word = dut.fourth_word;
assign o_length1 = dut.compressor.o_length1;
assign o_length2 = dut.compressor.o_length2;
assign o_shift_amount = dut.compressor.o_shift_amount;
  // Internal signal assignments
  assign o_reg_array3 = dut.decompressor.o_reg_array3;
  assign o_latch = dut.decompressor.o_latch;
  assign pre_word = dut.decompressor.barrel_shifter2.pre_word;
  assign o_first_length = dut.decompressor.o_first_length;
  assign o_second_length = dut.decompressor.o_second_length;
  assign o_comp_signal = dut.decompressor.o_comp_signal;
  assign o_len_r = dut.decompressor.o_len_r;
  assign o_or_gate = dut.decompressor.o_or_gate;
  assign reg_array1_out = dut.decompressor.reg_array1_out;
  assign o_barrel_shifter1 = dut.decompressor.o_barrel_shifter1;
  assign o_barrel_shifter2 = dut.decompressor.o_barrel_shifter2;
  assign o_mux_2 = dut.decompressor.o_mux_2;
  assign shifted_data_n = dut.decompressor.unpacker.shifted_data_n;
  assign shifted_data_r = dut.decompressor.unpacker.shifted_data_r;
  assign o_remain_length_n = dut.decompressor.o_remain_length_n;
  assign o_remain_length = dut.decompressor.o_remain_length;
  assign dictionary_data  = dut.dictionary_data;
  //assign o_backup_buffer3 = dut.compressor.o_backup_buffer3;
  assign i_stop_flag      = dut.compressor.stage3.i_stop_flag;
  //assign sum_total_reg    = dut.compressor.stage1and2.stage2.length_accumulator.sum_total_reg;
  //assign next_sum_total   = dut.compressor.stage1and2.stage2.length_accumulator.next_sum_total;
  // assign o_length1        = dut.compressor.stage1and2.o_length1;
  // assign o_length2        = dut.compressor.stage1and2.o_length2;
  // assign i_type_matched1  = dut.compressor.stage1and2.i_type_matched1;
  // assign i_type_matched2  = dut.compressor.stage1and2.i_type_matched2;
  // assign o_type_matched1  = dut.compressor.stage1and2.o_type_matched1;
  // assign o_type_matched2  = dut.compressor.stage1and2.o_type_matched2;

  // Storage arrays for later decompression
  logic [CACHE_LINE-1:0] compressed_words[0:31];
  logic                  finish_flags    [0:31];
  logic                  compressed_flag [0:31];
  int                    capture_index = 0;

  // Clock generation
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  // Utility tasks
  task wait_clk(input integer cycle);
    int k;
    begin
      for (k = 0; k < cycle; k++) @(posedge i_clk);
    end
  endtask

  task preload_word(input logic [WORD-1:0] w1,
                    input logic [WORD-1:0] w0,
                    logic dict);
    begin
      if (~dict)
        i_word_c <= {w1, w0};
      else
        i_word_c <= {w0, w1};
      wait_clk(1);
      $display("[TB] Compressed word = %h", o_compressed_word);
    end
  endtask

  task init_dictionary();
    logic dict;
    dict = 1'b1;
    preload_word(32'hDDEEFF00, 32'h12345678, dict);
    preload_word(32'h9ABCDEF0, 32'h0F0E0D0C, dict);
    preload_word(32'h87654321, 32'hFEDCBA98, dict);
    preload_word(32'h00112233, 32'h44556677, dict);
    preload_word(32'hAABBCCDD, 32'h11223344, dict);
    preload_word(32'h55667788, 32'h99AABBCC, dict);
    preload_word(32'h8899AABB, 32'hCCDDEEFF, dict);
    preload_word(32'h10203040, 32'h50607080, dict);
    $display("[TB] Dictionary preloaded.");
  endtask

  // Capture on finish or stop
  logic prev_finish, prev_stop;
  logic last_stop_capture;

  always_ff @(posedge i_clk) begin
    prev_finish <= o_finish_c_flag;
    prev_stop   <= i_stop_flag;

    // Capture stop events
    if (i_stop_flag | o_finish_c_flag) begin
      if(o_finish_c_flag) begin
       if(~prev_stop) begin
      compressed_words[capture_index] = o_compressed_word;
      finish_flags[capture_index]     = o_finish_c_flag;
      compressed_flag[capture_index]  = o_compressed_flag;
      last_stop_capture               <= 1;
      $fdisplay(log_file,"[TB] Captured[%0d] word=%h, compressed: %b", 
               capture_index,
               o_compressed_word,
               o_compressed_flag);
      capture_index <= capture_index + 1;
      end
      end else begin
      compressed_words[capture_index] = o_compressed_word;
      finish_flags[capture_index]     = o_finish_c_flag;
      compressed_flag[capture_index]  = o_compressed_flag;
      last_stop_capture               <= 1;
      $fdisplay(log_file,"[TB] Captured[%0d] word=%h, compressed: %b", 
               capture_index,
               o_compressed_word,
               o_compressed_flag);
      capture_index <= capture_index + 1;
      end
    end
  end

  initial begin
  log_file = $fopen("compressor_decompressor.log", "w");
  if (log_file == 0) begin
    $fatal("Failed to open log file");
  end
end
logic test_flag;
task run_testcase();
    integer offset, idx;
    integer  cycles;
    begin
    test_flag = compressed_flag[4];
    idx = 0;
    cycles = 0;
    i_word_d <= compressed_words[0];
    i_compressed_flag <= compressed_flag[0];
    offset = 0;
    i_update_d = 1;
    i_decompressor_en = 1;
    @(posedge i_clk);
    i_update_d = 0;
    @(posedge i_clk);
    //$display("%d",offset );
    while(idx < 15 && cycles < 100) begin
      i_compressed_flag = compressed_flag[idx + 1];
      i_word_d = compressed_words[idx + 1];
      if((o_remain_length_n < 8'd68) && idx < 14) begin
       idx++;
       i_word_d <= compressed_words[idx + 1];
        i_compressed_flag = compressed_flag[idx + 1];
      end
      @(posedge i_clk);  
      cycles = cycles + 1;
    end
    // while (offset < WIDTH128 && i < 64) begin
    //   check_word(shift_data, 0, first_word_length);
    //   shift_data = shift_data >> first_word_length;
    //   check_word(shift_data, 1, second_word_length);
    //   shift_data = shift_data >> second_word_length;
    //   offset= first_word_length + second_word_length + offset;
    //   $fdisplay(log_file,"shift_data: %b\n", shift_data);
    //   $fdisplay(log_file,"Current length: %d", offset );
    //   i++;
    //   @(posedge clk);  
    // end
    $fdisplay(log_file,"Exit loop");
    end
  endtask

  // Main test
  initial begin
    // Reset
    i_reset = 0;
    i_update_d = 0;
    i_compressor_en = 0;
    i_word_d = 0;
    i_decompressor_en = 0;
    i_word_c = 0;
    wait_clk(2);
    i_reset = 1;
    i_compressor_en = 1;

    // Initialize dictionary
    init_dictionary();

    // Test cases (compression)
    preload_word(32'h556677FF, 32'h99AAABCD, 1'b0); //40 //40
    preload_word(32'hAABBCCDD, 32'h11223344, 1'b0); //12 //52
    preload_word(32'hAABBCCDD, 32'h11223344, 1'b0); //12 //64
    preload_word(32'h00000012, 32'h000000AB, 1'b0); //24 //88
    preload_word(32'hAABBCC12, 32'h11223399, 1'b0); //32 //120
    preload_word(32'h00000000, 32'h11223344, 1'b0); //8  //128
    preload_word(32'hAABB0012, 32'h11220099, 1'b0); //48 //48
    preload_word(32'h00000000, 32'h11223344, 1'b0); //8 //56
    preload_word(32'hFACEB00C, 32'hDEADBEEF, 1'b0); //68 //124 
    preload_word(32'h00000000, 32'h00000000, 1'b0); //4 //128
    i_compressor_en = 0;
    // preload_word(32'h000000AA, 32'h55667788, 1'b0); 
    // preload_word(32'hAABBCCDD, 32'h00000000, 1'b0);
    // preload_word(32'h556677FF, 32'h99AAABCD, 1'b0);

    // // Dictionary updates
    // preload_word(32'hAAAABBBB, 32'hCCCCDDDD, 1'b0);
    // preload_word(32'hEEEFFFFF, 32'h12345678, 1'b0);
    // preload_word(32'hFFFFFFFF, 32'h00000000, 1'b0);
    // preload_word(32'h80000000, 32'h7FFFFFFF, 1'b0);
    
    run_testcase();

    #20 $finish;
  end
endmodule
