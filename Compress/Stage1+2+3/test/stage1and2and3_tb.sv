`timescale 1ns/1ps

module stage1and2and3_tb;

parameter WIDTH = 64;
parameter CACHE_LINE = 128;
parameter DATA_WIDTH = 32;
parameter DICT_ENTRY = 16;
parameter COMPRESSED = 34;
parameter TOTAL_BITS = 34;


parameter SETUP_WAIT = 0;
parameter INTERNAL_WAIT = 2;
parameter HOLD_WAIT = 1;


logic i_clk;
logic i_reset;
logic [WIDTH - 1:0] i_word;
logic [CACHE_LINE - 1:0] o_mux_array2;
logic [3:0] dict_index = 0;
logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
logic stop_flag, i_output_flag;
logic [127:0] o_mux_array3;
logic [127:0] o_reg_array2;
logic [127:0] o_mux_array1;
logic [COMPRESSED - 1 :0] compressed1, compressed2;
string failed_cases_log[$]; 
string fifo_wr_failed_cases_log[$]; 
logic [2:0] i_encoded2, i_encoded1;
logic [3:0] i_location2, i_location4, wr_addr;
logic [1:0] fifo_wr_signal;
logic [31:0] total_compressed_bits = 0;
logic [31:0] total_words_compressed = 0;
logic [127:0] final_output_check;
logic [127:0] final_backup_buffer;

// Internal dictionary
logic [511:0] dictionary_data;

integer passed_tests = 0;
integer failed_tests = 0;
integer fifo_wr_failed_tests = 0;
integer total_tests  = 0;
integer total_word   = 0;

// Instantiate DUT
stage1and2and3 dut (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_word(i_word),
  .o_mux_array2(o_mux_array2),
  .dictionary_data(dictionary_data)
);

assign stop_flag = dut.o_stop_flag;
assign i_encoded2 = dut.i_encoded2;
assign i_encoded1 = dut.i_encoded1;
assign i_location2 = dut.i_location2;
assign i_location4 = dut.i_location4;
assign o_mux_array3 = dut.stage3.o_mux_array3;
assign o_reg_array2 = dut.stage3.o_reg_array2;
assign o_mux_array1 = dut.stage3.o_mux_array1;
assign i_output_flag = dut.stage3.i_output_flag;
assign compressed1 =  dut.stage3.o_compressed_word1;
assign compressed2 =  dut.stage3.o_compressed_word2;
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

task update_fifo_dictionary(input logic [DATA_WIDTH-1:0] word);
 logic [DATA_WIDTH - 1 : 0] old_word;
  begin
    old_word = dict_mem[dict_index];
    $display("[FIFO Update] Old word: %h New word %h inserted at index %0d",old_word, word, dict_index);
    dict_mem[dict_index] = word;
    dict_index = dict_index + 1;
  end
endtask

task preload_word(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
  begin
    i_word <= {word1, word0}; // Lower word is word0, upper word is word1
    dict_mem[dict_index]   = word0;
    dict_mem[dict_index+1] = word1;
    dict_index += 2;
    #10; // Wait one clock cycle for the dictionary to update.
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
                    output logic [3:0] dict_idx1, output logic [3:0] dict_idx2, output logic update_dict);
  integer j;
  logic found1, found2;
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
          update_fifo_dictionary(first_word);
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
          update_fifo_dictionary(second_word);
      end

      update_dict = update_dict1 | update_dict2;
      case ({update_dict2, update_dict1})
      2'b00: i_fifo_wr_signal = 2'b00;
      2'b01: i_fifo_wr_signal = 2'b01;
      2'b10: i_fifo_wr_signal = 2'b10;
      2'b11: i_fifo_wr_signal = 2'b11;
      endcase
      if(i_fifo_wr_signal == fifo_wr_signal) $display("[FIFO_WR_SIGNAL] PASS");
      else begin 
          fifo_wr_failed_tests ++;
          $display("[FIFO_WR_SIGNAL] FAIL expected: %b, actual: %b", i_fifo_wr_signal, fifo_wr_signal);
          $sformat(log_entry, "FAIL - Word: %h | Expected: %h, Got: %h", i_word, i_fifo_wr_signal, fifo_wr_signal);
          fifo_wr_failed_cases_log.push_back(log_entry);
          $display("%s", log_entry);
      end
      #2;
   
  end
endtask

task track_compression(input [6:0] exp_length1, input [6:0] exp_length2);
  begin
    total_compressed_bits += exp_length1 + exp_length2;
    total_words_compressed += 2;  // Processing two words at a time
  end
endtask

task predict_final_compressor_output(
  input  logic [6:0] exp_length1,   
  input  logic [6:0] exp_length2,     
  input  logic [COMPRESSED-1:0] comp_word1, 
  input  logic [COMPRESSED-1:0] comp_word2
);
  logic [CACHE_LINE-1:0] shifted_result;
  logic [COMPRESSED*2 - 1 : 0] compressed_total;
  logic [6:0] total_length;   
  logic [CACHE_LINE-1:0] backup_buffer; 
  logic [CACHE_LINE-1:0] final_output;   
  begin
    total_length = exp_length1 + exp_length2;
    compressed_total = {comp_word1, comp_word2};
    shifted_result  = compressed_total <<< total_length;
    final_output_check = final_output_check | shifted_result;
  end
endtask

task generate_prediction(input logic [31:0] i_word, input logic [2:0] i_code, input logic [3:0] i_dict_idx, output logic [127:0] temp);
begin
  case (i_code)
    3'b000: temp = 32'd0; // zzzz
    3'b001: temp = {{(TOTAL_BITS-6){1'b0}}, 2'b10, i_dict_idx}; // mmmm
    3'b010: temp = {{(TOTAL_BITS-12){1'b0}}, 4'b1101, i_word[7:0]}; // zzzx
    3'b011: temp = {{(TOTAL_BITS-16){1'b0}}, 4'b1110, i_dict_idx, i_word[7:0]}; // mmmx
    3'b100: temp = {{(TOTAL_BITS-24){1'b0}}, 4'b1100, i_dict_idx, i_word[15:0]}; // mmxx
    3'b101: temp = {2'b01, i_word}; // xxxx
    default: temp = {32{1'b1}};
  endcase
end
endtask

integer capture_time [DICT_ENTRY];  
task check_fifo_dictionary();
  integer i;
  integer mismatch_found = 0;
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

    if (!mismatch_found)
      $display("PASS MEM - FIFO dictionary matches expected memory.");
    
    $display("============================================================\n");
  end
endtask

task predict_compressed_word();
logic [6:0] exp_length1, exp_length2;
logic [2:0] exp_code1, exp_code2;
logic [3:0] dict_idx1, dict_idx2;
logic [33:0] expected_compressed_word1;
logic [33:0] expected_compressed_word2;
logic update_dict;
integer capture_time;
string log_entry;
begin
#5;
  total_tests++;
  total_word = total_word + 2;
  $display("Word_in: %h", i_word);
  check_pattern(i_word[31:0], i_word[63:32], exp_length1, exp_length2, exp_code1, exp_code2, dict_idx1, dict_idx2, update_dict);
  generate_prediction(i_word[31:0], exp_code1, dict_idx1, expected_compressed_word1);
  track_compression(exp_length1, exp_length2);
  wait_clk(INTERNAL_WAIT);
  if(update_dict) begin
    check_fifo_dictionary();
    update_dict = 0;
  end
  $display("[Prediction] Expected Compressed Word1: %h", expected_compressed_word1);
  #2;
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

  generate_prediction(i_word[63:32], exp_code2, dict_idx2, expected_compressed_word2);
  $display("[Prediction] Expected Compressed Word2: %h", expected_compressed_word2);
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
  predict_final_compressor_output(exp_length1, exp_length2, expected_compressed_word1, expected_compressed_word2);
end
endtask


// Clock generation
always #5 i_clk = ~i_clk;


initial begin
  i_clk = 0;
  i_reset = 0;
  i_word = 0;
  
  // Apply reset
  #10 i_reset = 1;
  wait_clk(1);
  // Initialize dictionary
  init_dictionary();
  wait_clk(SETUP_WAIT);
// Test Case 1: zzzz (All Zero)
  i_word <= {32'h00000000, 32'h00000000};
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 2: mmmm (All Matched)
  i_word <= {32'hAABBCCDD, 32'h11223344}; // Already in dictionary
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 3: zzzx (Single Byte Difference)
  i_word <= {32'h00000012, 32'h000000AB};
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 4: mmmx (Three Byte Match)
  i_word <= {32'hAABBCC12, 32'h11223399}; // Matches first 3 bytes in dictionary
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 5: mmxx (Two Byte Match)
  i_word <= {32'hAABB0012, 32'h11220099}; // Matches first 2 bytes in dictionary
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 6: xxxx (Unmatched Word)
  i_word <= {32'hFACEB00C, 32'hDEADBEEF}; // Completely new words
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);
  
  // Test Case 7: Alternating Patterns
  i_word <= {32'h00000000, 32'h11223344}; // zzzz and mmmm
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  i_word <= {32'h000000AA, 32'h55667788}; // zzzx and mmmm
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  i_word <= {32'hAABBCCDD, 32'h00000000}; // mmmm and zzzz
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 8: Dictionary Updates
  i_word <= {32'hAAAABBBB, 32'hCCCCDDDD}; // New entries
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);
  
  i_word <= {32'hEEEFFFFF, 32'h12345678}; // One new, one existing
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  // Test Case 9: Edge Cases (Minimum and Maximum Values)
  i_word <= {32'hFFFFFFFF, 32'h00000000}; // Max and Min values
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

  i_word <= {32'h80000000, 32'h7FFFFFFF}; // Min Signed and Max Signed
  wait_clk(SETUP_WAIT);
  predict_compressed_word();
  wait_clk(1);

    // Print scoreboard results
  $display("\n=================== Scoreboard Report ===================");
  $display("Total Test Cases: %0d", total_tests);
  $display("Passed: %0d", passed_tests);
  $display("Failed: %0d", failed_tests);

  if (failed_tests > 0) begin
    $display("\n=================== Failed Cases Log ===================");
    foreach (failed_cases_log[i]) $display("%s", failed_cases_log[i]);
  end else $display("PASS ALL");
  if (fifo_wr_failed_tests > 0) begin
    $display("\n=================== FIFO Failed Cases Log ===================");
    foreach (fifo_wr_failed_cases_log[i]) $display("%s", fifo_wr_failed_cases_log[i]);
  end else $display("PASS FIFO_WR");
// Finish simulation
#20 $finish;
end

endmodule
