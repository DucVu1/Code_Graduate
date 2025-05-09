`timescale 1ns/1ps

module stage1and2and3_tb;

parameter WIDTH = 64;
parameter CACHE_LINE = 128;
parameter DATA_WIDTH = 32;
parameter DICT_ENTRY = 16;
parameter COMPRESSED = 34;
parameter TOTAL_BITS = 34;

parameter TOTAL_WIDTH = 136;
parameter SETUP_WAIT = 0;
parameter INTERNAL_WAIT = 0;
parameter HOLD_WAIT = 0;
parameter OUT_SHIFT_BIT = 7;
integer log_file;
logic i_clk;
logic i_reset;
logic [WIDTH - 1:0] i_word;
integer compressed_bit_exp = 0;
logic [3:0] dict_index = 0; 
logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
logic i_output_flag;


string failed_cases_log[$]; 
string fifo_wr_failed_cases_log[$]; 
logic [2:0] i_encoded2, i_encoded1;
logic [3:0] i_location2, i_location4, wr_addr;
logic [1:0] fifo_wr_signal;
logic [31:0] total_compressed_bits = 0;
logic [31:0] total_words_compressed = 0;
logic [127:0] final_output_check = 0;
logic         o_stop_flag;
logic         o_full_flag;
logic         o_push_flag;
logic         o_store_flag;
logic         o_done_flag;
logic         o_finish_final;
logic [127:0] accumulator_g = 0;
logic [127:0] o_reg_array2;
logic [CACHE_LINE - 1:0] o_mux_array2;
logic [127:0] final_output_check_reg = 0;
logic [7:0]   o_shift_amount;
logic [7:0] sum_total_reg;
logic [7:0]   o_length1, o_length2;
logic [127:0] o_barrel3_shifted;
logic [TOTAL_WIDTH - 1 :0] o_reg_array1;
logic [127:0] final_output_check_reg_pre = 0;

//logic [5:0]   g_length1, g_length2; 
logic [127:0] final_backup_buffer = 0;
logic [$clog2(DICT_ENTRY) - 1 :0]     i_idx1;
logic [2:0]                           i_code1;
logic [$clog2(DICT_ENTRY) - 1 :0]     i_idx2;
logic [2:0]                           i_code2;
//debugging

logic [127:0] o_backup_buffer3, o_backup_buffer;
logic [127:0] o_latch;
logic [127:0] o_mux_array3;
logic [127:0] shifted_and_or;
logic [OUT_SHIFT_BIT - 1 : 0]  i_out_shift;
logic [3:0]         i_type_matched2, i_type_matched1;
//output check

// concatenate check
logic [COMPRESSED - 1 :0] compressed1, compressed2;
logic [COMPRESSED - 1 :0] g_compressed1, g_compressed2;
//reg_check

//mux check
logic [127:0] o_mux_array1;
logic         i_store_flag;
//shifting 1 check


logic [135:0] o_barrel2_shifted;
logic [127:0] o_or_gate;
logic [7:0]   sum_partial_reg, next_sum_partial;
// Internal dictionary
logic [511:0] dictionary_data;
  

integer passed_tests = 0;
integer failed_tests = 0;
integer failed_final_tests = 0;
integer fifo_wr_failed_tests = 0;
integer total_tests  = 0;
integer total_word   = 0;

// Instantiate DUT
stage1and2and3 dut (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_word(i_word),
  .o_mux_array2(o_mux_array2),
  .o_finish_final(o_finish_final),
  .dictionary_data(dictionary_data)
);
//debugging
assign o_done_flag = dut.o_done_flag;
assign o_full_flag = dut.stage1and2.stage2.length_accumulator.o_full_flag;
assign sum_total_reg = dut.stage1and2.stage2.length_accumulator.sum_total_reg;
assign o_store_flag = dut.o_store_flag;
assign o_push_flag = dut.o_push_flag;
assign o_length1 = dut.stage1and2.stage2.o_length1;
assign o_length2 = dut.stage1and2.stage2.o_length2;
//output check
assign o_stop_flag = dut.o_stop_flag;
assign o_backup_buffer3 = dut.o_backup_buffer3;
assign o_backup_buffer = dut.o_backup_buffer;
// concatenate check
assign compressed1 =  dut.stage3.o_compressed_word1;
assign compressed2 =  dut.stage3.o_compressed_word2;
//reg_check
assign o_reg_array2 = dut.stage3.o_reg_array2;
//mux check
assign o_mux_array1 = dut.stage3.o_mux_array1;
assign i_store_flag = dut.stage3.i_store_flag;
//shifting 1 check
assign o_shift_amount = dut.o_shift_amount;
assign o_barrel3_shifted = dut.stage3.o_barrel3_shifted;
assign o_reg_array1 = dut.stage3.o_reg_array1;
assign o_barrel2_shifted = dut.stage3.o_barrel2_shifted;
assign o_or_gate = dut.stage3.o_or_gate;
assign sum_partial_reg = dut.stage1and2.stage2.length_accumulator.sum_partial_reg;
assign next_sum_partial = dut.stage1and2.stage2.length_accumulator.next_sum_partial;
//----------------------------------------------------------------------------------------------------------------------------------------------
assign i_type_matched1 = dut.stage1and2.i_type_matched1;
assign i_type_matched2 = dut.stage1and2.i_type_matched2;
assign i_shift_amount = dut.i_shift_amount;
assign i_encoded2 = dut.i_encoded2;
assign i_encoded1 = dut.i_encoded1;
assign i_location2 = dut.i_location2;
assign i_location4 = dut.i_location4;
assign o_mux_array3 = dut.stage3.o_mux_array3;
assign shifted_and_or = dut.stage3.shifted_and_or;
assign o_latch = dut.stage3.o_latch;
assign i_out_shift = dut.stage3.i_out_shift;
assign i_output_flag = dut.stage3.i_output_flag;
assign i_idx1 =  dut.stage3.i_idx1;
assign i_code1 =  dut.stage3.i_code1;
assign i_idx2 =  dut.stage3.i_idx2;
assign i_code2 =  dut.stage3.i_code2;
assign fifo_wr_signal = dut.stage1and2.stage1.fifo_wr_signal;
assign wr_addr = dut.stage1and2.stage1.dictionary.wr_addr;

task wait_clk(input integer cycle);
begin
  int k;
  k = 0;
  while (k < cycle) begin
  @(posedge i_clk);
  k = k + 1;
  end
end
endtask

task update_fifo_dictionary(
    input logic [DATA_WIDTH-1:0] word1, 
    input logic [DATA_WIDTH-1:0] word2, 
    input logic                  update_word1, 
    input logic                  update_word2
);
  logic [DATA_WIDTH-1:0] old_word1, old_word2;
  begin
    if (~update_word1) begin
      // Optionally store old word for debugging
      old_word1 <= dict_mem[dict_index];
      $display("[FIFO Update] Old word1: %h, New word1: %h inserted at index %0d",
               old_word1, word1, dict_index);
      dict_mem[dict_index] = word1;
      dict_index = dict_index + 1;
    end
    if (~update_word2) begin
      old_word2 = dict_mem[dict_index];
      $display("[FIFO Update] Old word2: %h, New word2: %h inserted at index %0d",
               old_word2, word2, dict_index);
      dict_mem[dict_index] <= word2;
      dict_index = dict_index + 1;
    end
  end
endtask


task preload_word(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
  begin
    i_word <= {word1, word0}; // Lower word is word0, upper word is word1
    predict_compressed_word(i_word);
    // wait_clk(1);
    #10;
  end
endtask


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

task check_pattern(input [31:0] first_word, input [31:0] second_word, 
                    output logic [6:0] exp_length1, output logic [6:0] exp_length2,
                    output logic [2:0] exp_code1, output logic [2:0] exp_code2,
                    output logic [3:0] dict_idx1, output logic [3:0] dict_idx2, output logic update_dict,   output logic found1, found2);
  integer j;
  logic update_dict1, update_dict2;
  logic [1:0] i_fifo_wr_signal;
  string log_entry;
  
  update_dict = 0;
  update_dict1 = 0;
  update_dict2 = 0;
  // Check first word
  found1 = 0;
  dict_idx1 = 4'b1111; // Default invalid index
  if (first_word == 32'd0) begin // zzzz
      found1 = 1;
      exp_length1 = 7'd2;
      exp_code1   = 3'b000;
  end else if (first_word[31:8] == 24'd0) begin
      found1 = 1;
      exp_length1 = 7'd12;
      exp_code1   = 3'b010;
  end else begin
      for (j = 0; j < DICT_ENTRY; j = j + 1) begin
          if (dict_mem[j] == first_word) begin // mmmm
              found1 = 1;
              exp_length1 = 7'd6;
              exp_code1   = 3'b001;
              dict_idx1   = j;
              break;
          end else if (dict_mem[j][31:8] == first_word[31:8]) begin  // mmmx
              exp_length1 = 7'd16;
              exp_code1   = 3'b011;
              dict_idx1   = j;
              found1 = 1;
          end else if (dict_mem[j][31:16] == first_word[31:16]) begin // mmxx
              exp_length1 = 7'd24;
              exp_code1   = 3'b100;
              dict_idx1   = j;
              found1 = 1;
          end
      end
      if (!found1) begin
          exp_length1 = 7'd34;
          exp_code1   = 3'b101;
          update_dict1 = 1;
      end
  end
  
  // Check second word
  found2 = 0;
  dict_idx2 = 4'b1111;
  if (second_word == 32'd0) begin
      found2 = 1;
      exp_length2 = 7'd2;
      exp_code2   = 3'b000;
  end else if (second_word[31:8] == 24'd0) begin
      found2 = 1;
      exp_length2 = 7'd12;
      exp_code2   = 3'b010;
  end else begin
      for (j = 0; j < DICT_ENTRY; j = j + 1) begin
          if (dict_mem[j] == second_word) begin // mmmm
              found2 = 1;
              exp_length2 = 7'd6;
              exp_code2   = 3'b001;
              dict_idx2   = j;
              break;
          end else if (dict_mem[j][31:8] == second_word[31:8]) begin  // mmmx
              exp_length2 = 7'd16;
              exp_code2   = 3'b011;
              dict_idx2   = j;
              found2 = 1;
          end else if (dict_mem[j][31:16] == second_word[31:16]) begin // mmxx
              exp_length2 = 7'd24;
              exp_code2   = 3'b100;
              dict_idx2   = j;
              found2 = 1;
          end
      end
      if (!found2) begin
          exp_length2 = 7'd34;
          exp_code2   = 3'b101;
          update_dict2 = 1;
      end

      update_dict = update_dict1 | update_dict2;
      case ({update_dict2, update_dict1})
      2'b00: i_fifo_wr_signal = 2'b00;
      2'b01: i_fifo_wr_signal = 2'b01;
      2'b10: i_fifo_wr_signal = 2'b10;
      2'b11: i_fifo_wr_signal = 2'b11;
      endcase
      // if(i_fifo_wr_signal == fifo_wr_signal) $display("[FIFO_WR_SIGNAL] PASS");
      // else begin 
      //     fifo_wr_failed_tests ++;
      //     $display("[FIFO_WR_SIGNAL] FAIL expected: %b, actual: %b", i_fifo_wr_signal, fifo_wr_signal);
      //     $sformat(log_entry, "FAIL - Word: %h | Expected: %h, Got: %h", i_word, i_fifo_wr_signal, fifo_wr_signal);
      //     fifo_wr_failed_cases_log.push_back(log_entry);
      //     $display("%s", log_entry);
      // end
      // g_length1 = exp_length1;
      // g_length2 = exp_length2;
      // #2;
   
  end
endtask

task track_compression(input [6:0] exp_length1, input [6:0] exp_length2);
  begin
    total_compressed_bits += exp_length1 + exp_length2;
    total_words_compressed += 2;  // Processing two words at a time
    $display("compressed_word1: %d, compressed_word2: %d, current_length: %d", exp_length1, exp_length2, total_compressed_bits);
  end
endtask
logic [127:0] current_compressed_word_g;
logic toggle = 0;
task predict_final_compressor_output(
  input  logic [DATA_WIDTH - 1 : 0] i_word1,
  input  logic [DATA_WIDTH - 1 : 0] i_word2,
  input  logic [COMPRESSED-1:0]     comp_word1,    
  input  logic [COMPRESSED-1:0]     comp_word2,
  input  logic [6:0]                exp_length1,
  input  logic [6:0]                exp_length2
);
  logic [CACHE_LINE-1:0] accumulator;
  logic [67:0] g_concatenated ;
  logic [127:0] current_compressed_word;
  integer capture_time;
  logic [5:0] shift_amount;
  begin
  $display("Join");
    $fdisplay(log_file,"Word_in: %h", {i_word2,i_word1});
    if (total_words_compressed <= 2) begin
      final_backup_buffer[63:0] = i_word;
    end else begin
      final_backup_buffer[127:64] = i_word;
      total_words_compressed =  0;
    end
    // Generate final compressed output
    if (compressed_bit_exp > CACHE_LINE) begin
      final_output_check = final_backup_buffer;
      compressed_bit_exp = 0;
    end else begin
      //accumulator = 128'd0;
      current_compressed_word = (comp_word2 << exp_length1) | comp_word1;
      $fdisplay(log_file,"current_compressed_word: %h", current_compressed_word);
      compressed_bit_exp = exp_length1 + exp_length2 + compressed_bit_exp; 
      $fdisplay(log_file,"compressed_bit_exp: %d", compressed_bit_exp);
      //shift_amount = CACHE_LINE - (total_compressed_bits + (COMPRESSED * 2));
      current_compressed_word_g = (current_compressed_word_g << (exp_length1 + exp_length2)) | current_compressed_word;
      $fdisplay(log_file,"current_compressed_word_g: %h", current_compressed_word_g);
      $fdisplay(log_file,"comp_word1: %h", comp_word1);
      $fdisplay(log_file,"comp_word2: %h", comp_word2);
      if(compressed_bit_exp == 8'd64  || compressed_bit_exp >= 8'd128) begin
        $fdisplay(log_file,"In");
        if(toggle) accumulator_g[63:0] = current_compressed_word_g[63:0];
        else accumulator_g[127:64] = current_compressed_word_g[63:0];
        toggle = ~toggle; 
        if(compressed_bit_exp >= 8'd128) compressed_bit_exp = '0;
      end
      $fdisplay(log_file,"Accumulator: %h", accumulator_g);
      //accumulator = {comp_word2, comp_word1} << shift_amount;
      //accumulator_g = accumulator;
      final_output_check = accumulator_g;
      $fdisplay(log_file,"[INFO] at time: %t current predict output: %h ", $realtime,final_output_check);
    end
  end
endtask

always_ff @(posedge i_clk) begin
  if(~i_reset) final_output_check_reg_pre <= 128'd0;
  else final_output_check_reg_pre <= final_backup_buffer;
end

always_ff @(posedge i_clk) begin
  if(~i_reset) final_output_check_reg <= 128'd0;
  else final_output_check_reg <= final_output_check_reg_pre;
end
// Separate task that performs the output check.
task final_check_output();
  integer capture_time;
  begin
  if(o_stop_flag) begin
    if(total_compressed_bits >= CACHE_LINE) begin
      if(final_output_check_reg == o_mux_array2) begin
         $fdisplay(log_file,"PASS at time %0t: Final output matches expected.", $time);
      end else begin
         capture_time = $time; 
         $fdisplay(log_file,"FAIL at time %0t: expected_output: %h, actual: %h", capture_time, final_output_check_reg, o_mux_array2);
         failed_final_tests++;
      end
      total_compressed_bits = 0;
    end
  end
  end
endtask

task generate_prediction(input logic [31:0] i_word, input logic [2:0] i_code, input logic [3:0] i_dict_idx, output logic [127:0] temp);
begin
  case (i_code)
    3'b000: temp = 32'd0; // zzzz
    3'b001: temp = {{(TOTAL_BITS-6){1'b0}}, i_dict_idx, 2'b10}; // mmmm
    3'b010: temp = {{(TOTAL_BITS-12){1'b0}}, i_word[7:0], 4'b1101}; // zzzx
    3'b011: temp = {{(TOTAL_BITS-16){1'b0}},  i_word[7:0], i_dict_idx, 4'b1110};// mmmx
    3'b100: temp = {{(TOTAL_BITS-24){1'b0}},  i_word[15:0], i_dict_idx, 4'b1100 }; // mmxx
    3'b101: temp = {i_word, 2'b01};// xxxx
    default: temp = {TOTAL_BITS{1'b0}};
  endcase
end
endtask

integer capture_time [DICT_ENTRY];  
integer mismatch_found = 0;
task check_fifo_dictionary();
  integer i;
  begin
    $display("\n=================== FIFO Dictionary Memory ===================");

    for (i = 0; i < DICT_ENTRY; i = i + 1) begin
      capture_time[i] = $time;  
      
      if (dict_mem[i] != dictionary_data[i*DATA_WIDTH +: DATA_WIDTH]) begin
        $display("time: %0t, FAILED MEM at index %0d: dictionary_data %h, dict_mem %h", 
                 capture_time[i], i, dictionary_data[i*DATA_WIDTH +: DATA_WIDTH], dict_mem[i]);
        mismatch_found = 1;
      end
    end

    if (!mismatch_found) begin
      $display("PASS MEM - FIFO dictionary matches expected memory.");
      mismatch_found = 0;
    end
    
    $display("============================================================\n");
  end
endtask
task check_compressed(input logic [33:0] expected_compressed_word1, expected_compressed_word2);
  string log_entry;
  integer capture_time;
  if (expected_compressed_word1 == compressed1) begin
      $display("PASS");
      passed_tests ++;
    end else begin
      capture_time = $time; 
      $display("time: %0t FAIL: Inital word: %h, expected_compressed_word: %h, actual: %h", capture_time, i_word[31:0], expected_compressed_word1, compressed1);
      failed_tests ++;
      check_fifo_dictionary();
      $sformat(log_entry, "FAIL - Word1: %h | Expected: %h, Got: %h", i_word[31:0], expected_compressed_word1, compressed1);
      failed_cases_log.push_back(log_entry);
      $display("%s", log_entry);
    end

  if (expected_compressed_word2 == compressed2) begin
    $display("PASS");
    passed_tests ++;
  end else begin
    capture_time = $time; 
    $display("time: %0t FAIL: Inital word: %h, expected_compressed_word2: %h, actual: %h", capture_time, i_word[63:32],  expected_compressed_word2, compressed2);
    failed_tests ++;
    check_fifo_dictionary();
    $sformat(log_entry, "FAIL - Word2: %h | Expected: %h, Got: %h", i_word[63:32], expected_compressed_word2, compressed2);
    failed_cases_log.push_back(log_entry);
    $display("%s", log_entry);
  end
endtask
logic [63:0] temp_word = 0;
task predict_compressed_word_pre(input logic [63:0] in_word);

 temp_word <= in_word;
 predict_compressed_word(temp_word); 
 if(in_word == 64'h556677FF99AAABCD) compressed_bit_exp = 0;
endtask

task predict_compressed_word(input logic [63:0] in_word);
  logic [6:0] exp_length1, exp_length2;
  logic [2:0] exp_code1, exp_code2;
  logic [3:0] dict_idx1, dict_idx2;
  logic [33:0] expected_compressed_word1;
  logic [33:0] expected_compressed_word2;
  logic update_dict;
  logic found1, found2;

  begin
  final_check_output();
  total_tests++;
  //total_word = total_word + 2;
  $display("Word_in: %h", in_word);
  check_pattern(in_word[31:0], in_word[63:32], exp_length1, exp_length2, exp_code1, exp_code2, dict_idx1, dict_idx2, update_dict, found1, found2);
  generate_prediction(in_word[31:0], exp_code1, dict_idx1, expected_compressed_word1);
  generate_prediction(in_word[63:32], exp_code2, dict_idx2, expected_compressed_word2);
  g_compressed1 = expected_compressed_word1;
  g_compressed2 = expected_compressed_word2;
  track_compression(exp_length1, exp_length2);
  update_fifo_dictionary(in_word[31:0],  in_word[63:32], found1, found2);

  wait_clk(INTERNAL_WAIT);
  if(update_dict) begin
    //check_fifo_dictionary();
    update_dict = 0;
  end
  //$display("[Prediction] Expected Compressed Word1: %h", expected_compressed_word1);
  //check_compressed(expected_compressed_word1, expected_compressed_word2);
  //$display("[Prediction] Expected Compressed Word2: %h", expected_compressed_word2);
  predict_final_compressor_output(in_word[31:0], in_word[63:32], expected_compressed_word1, expected_compressed_word2,
                                  exp_length1, exp_length2);
end 
endtask


// Clock generation
always #5 i_clk = ~i_clk;

initial begin
  log_file = $fopen("compressor.log", "w");
  if (log_file == 0) begin
    $fatal("Failed to open log file");
  end
end

initial begin
  i_clk = 0;
  i_reset = 0;
  i_word = 0;
  // Apply reset
  #15 i_reset = 1;
  wait_clk(1);
  // Initialize dictionary
  init_dictionary();
// Test Case 1: zzzz (All Zero)
  i_word <= {32'h00000000, 32'h00000000}; //4
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  i_word <= {32'h556677FF, 32'h99AAABCD}; //mmmx and mmxx //40 //total 40
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 2: mmmm (All Matched)
  i_word <= {32'hAABBCCDD, 32'h11223344}; // Already in dictionary //12 //52
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 2: mmmm (All Matched)
  i_word <= {32'hAABBCCDD, 32'h11223344}; // Already in dictionary //12 //64
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);


  // Test Case 3: zzzx (Single Byte Difference)
  i_word <= {32'h00000012, 32'h000000AB}; //24 //88
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 4: mmmx (Three Byte Match)
  i_word <= {32'hAABBCC12, 32'h11223399}; // Matches first 3 bytes in dictionary //32 //120
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);
  
    // Test Case 7: Alternating Patterns
  i_word <= {32'h00000000, 32'h11223344}; // zzzz and mmmm //8 //128
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 5: mmxx (Two Byte Match)
  i_word <= {32'hAABB0012, 32'h11220099}; // Matches first 2 bytes in dictionary //48 //48
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 7: Alternating Patterns
  i_word <= {32'h00000000, 32'h11223344}; // zzzz and mmmm //8 //56
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 6: xxxx (Unmatched Word)
  i_word <= {32'hFACEB00C, 32'hDEADBEEF}; // Completely new words //68 //124
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);
  
  i_word <= {32'h00000000, 32'h00000000}; //4 //128
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  i_word <= {32'h000000AA, 32'h55667788}; // zzzx and mmmm //12 //12
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  i_word <= {32'hAABBCCDD, 32'h00000000}; // mmmm and zzzz //8 //20
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  i_word <= {32'h556677FF, 32'h99AAABCD}; //mmmx and mmxx //40 //60
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 8: Dictionary Updates
  i_word <= {32'hAAAABBBB, 32'hCCCCDDDD}; // New entries //128
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);
  
  i_word <= {32'hEEEFFFFF, 32'h12345678}; // One new, one existing
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  // Test Case 9: Edge Cases (Minimum and Maximum Values)
  i_word <= {32'hFFFFFFFF, 32'h00000000}; // Max and Min values
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

  i_word <= {32'h80000000, 32'h7FFFFFFF}; // Min Signed and Max Signed
  wait_clk(SETUP_WAIT);
  predict_compressed_word_pre(i_word);
  wait_clk(1);

    // Print scoreboard results
  // $display("\n=================== Scoreboard Report ===================");
  // $display("Total Test Cases: %0d", total_tests);
  // $display("Passed: %0d", passed_tests);
  // $display("Failed: %0d", failed_tests);

  // if (failed_tests > 0) begin
  //   $display("\n=================== Failed Cases Log ===================");
  //   foreach (failed_cases_log[i]) $display("%s", failed_cases_log[i]);
  // end else $display("PASS ALL");
  // if (fifo_wr_failed_tests > 0) begin
  //   $display("\n=================== FIFO Failed Cases Log ===================");
  //   foreach (fifo_wr_failed_cases_log[i]) $display("%s", fifo_wr_failed_cases_log[i]);
  // end else $display("PASS FIFO_WR");
// Finish simulation
#20 $finish;
end

endmodule
