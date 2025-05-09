`timescale 1ns/1ps

module stage1and2and3_tb;

  //===========================================================================
  // 1. Global Parameters and Signal Declarations
  //===========================================================================
  parameter WIDTH          = 64;
  parameter CACHE_LINE     = 128;
  parameter DATA_WIDTH     = 32;
  parameter DICT_ENTRY     = 16;
  parameter COMPRESSED     = 34;
  parameter TOTAL_BITS     = 34;
  parameter TOTAL_WIDTH    = 136;
  parameter SETUP_WAIT     = 0;
  parameter INTERNAL_WAIT  = 0;
  parameter HOLD_WAIT      = 0;
  parameter OUT_SHIFT_BIT  = 7;

  // Clock & Reset, and DUT Input/Output Signals
  logic i_clk;
  logic i_reset;
  logic [WIDTH-1:0] i_word;

  // Internal dictionary memory and related signals
  logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
  logic [511:0] dictionary_data; // Packed dictionary data (16 x 32 bits)
  logic [15:0] dict_index;

  // DUT output signals (for debug and check)
  logic stop_flag, i_output_flag;
  logic [127:0] o_mux_array2;
  logic [127:0] o_backup_buffer3;
  logic [127:0] o_mux_array3;
  logic [127:0] o_latch;
  logic [127:0] o_reg_array2;
  logic [TOTAL_WIDTH-1:0] o_reg_array1;
  logic [135:0] o_barrel2_shifted;
  logic [127:0] o_barrel3_shifted;
  logic [7:0] o_shift_amount;
  logic [127:0] o_or_gate;
  logic [OUT_SHIFT_BIT-1:0] i_out_shift;
  
  // Various internal signals for encoding, matching, shifting, etc.
  logic [2:0] i_encoded2, i_encoded1;
  logic [3:0] i_location2, i_location4, wr_addr;
  logic [1:0] fifo_wr_signal;
  logic [31:0] total_compressed_bits = 0;
  logic [31:0] total_words_compressed = 0;
  logic [127:0] final_output_check = 0;
  logic [127:0] accumulator_g = 0;
  logic [COMPRESSED*2-1:0] g_concatenated;
  logic [127:0] final_backup_buffer = 0;
  logic [$clog2(DICT_ENTRY)-1:0] i_idx1;
  logic [2:0] i_code1;
  logic [$clog2(DICT_ENTRY)-1:0] i_idx2;
  logic [2:0] i_code2;
  logic [3:0] i_type_matched2, i_type_matched1;
  logic [COMPRESSED-1:0] compressed1, compressed2;
  logic i_store_flag;

  // Test counters and logs
  integer passed_tests = 0;
  integer failed_tests = 0;
  integer failed_final_tests = 0;
  integer fifo_wr_failed_tests = 0;
  integer total_tests  = 0;
  integer total_word   = 0;
  string failed_cases_log[$]; 
  string fifo_wr_failed_cases_log[$]; 

  //===========================================================================
  // 2. Utility Tasks
  //===========================================================================

  // Wait for a given number of clock cycles
  task wait_clk(input integer cycle);
    integer k;
    begin
      k = 0;
      while (k < cycle) begin
        @(posedge i_clk);
        k = k + 1;
      end
    end
  endtask

  // Update the FIFO dictionary (internal dict_mem) with a new word
  task update_fifo_dictionary(input logic [DATA_WIDTH-1:0] word);
    logic [DATA_WIDTH-1:0] old_word;
    begin
      old_word = dict_mem[dict_index];
      $display("[FIFO Update] Old word: %h New word: %h inserted at index %0d", old_word, word, dict_index);
      dict_mem[dict_index] = word;
      dict_index = dict_index + 1;
    end
  endtask

  //===========================================================================
  // 3. Dictionary Initialization and Word Preload Tasks
  //===========================================================================

  // Preload two 32-bit words into the DUT’s dictionary, and call prediction
  task preload_word(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      // Combine two 32-bit words into a 64-bit input
      i_word <= {word1, word0}; // Lower word is word0, upper is word1
      predict_compressed_word(i_word);
      dict_mem[dict_index]   = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10; // Wait one cycle for update
    end
  endtask

  // Initialize the dictionary by preloading all entries
  task init_dictionary();
    begin
      preload_word(32'hAABBCCDD, 32'h11223344); // words 0 & 1 
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

  //===========================================================================
  // 4. Prediction and Verification Tasks
  //===========================================================================

  // Check pattern and compute expected compressed parameters:
  task check_pattern(
      input  [31:0] first_word, 
      input  [31:0] second_word, 
      output logic [6:0] exp_length1, 
      output logic [6:0] exp_length2,
      output logic [2:0] exp_code1, 
      output logic [2:0] exp_code2,
      output logic [3:0] dict_idx1, 
      output logic [3:0] dict_idx2, 
      output logic update_dict
  );
    integer j;
    logic found1, found2;
    logic update_dict1, update_dict2;
    begin
      // Process first_word
      found1 = 0;
      dict_idx1 = 4'b1111; // Default invalid index
      if (first_word == 32'd0) begin // zzzz
          found1 = 1;
          exp_length1 = 7'd2;
          exp_code1   = 3'b000;
      end else if (first_word[31:8] == 24'd0) begin // zzzx
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
      
      // Process second_word
      found2 = 0;
      dict_idx2 = 4'b1111;
      if (second_word == 32'd0) begin // zzzz
          found2 = 1;
          exp_length2 = 7'd2;
          exp_code2   = 3'b000;
      end else if (second_word[31:8] == 24'd0) begin // zzzx
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
      end
      
      update_dict = update_dict1 | update_dict2;
    end
  endtask

  // Track the compressed bits totals
  task track_compression(input [6:0] exp_length1, input [6:0] exp_length2);
    begin
      total_compressed_bits += exp_length1 + exp_length2;
      $display("Compressed lengths: %d, %d; Total compressed bits: %d",
               exp_length1, exp_length2, total_compressed_bits);
      total_words_compressed += 2;  // Two words processed per cycle
    end
  endtask

  // Generate predicted compressed word for checking
  task generate_prediction(
      input logic [31:0] i_word,
      input logic [2:0]  i_code,
      input logic [3:0]  i_dict_idx,
      output logic [127:0] temp
  );
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

  // Predict final compressor output (simplified)
  task predict_final_compressor_output(
      input logic [31:0] word1,
      input logic [31:0] word2,
      input logic [COMPRESSED-1:0] comp_word1,    
      input logic [COMPRESSED-1:0] comp_word2,
      input integer              total_words_compressed,     
      input logic [6:0]          total_compressed_bits
  );
    logic [127:0] accumulator;
    begin
      final_backup_buffer = final_backup_buffer | ({word2, word1} << (total_words_compressed * 32));
      if (total_compressed_bits > CACHE_LINE) begin
        final_output_check = final_backup_buffer;
      end else begin
        accumulator = 0;
        g_concatenated = {comp_word2, comp_word1};
        accumulator = accumulator | ({comp_word2, comp_word1} << total_compressed_bits);
        accumulator_g = accumulator;
        final_output_check = final_output_check | accumulator;
      end

      if (total_compressed_bits >= CACHE_LINE) begin
        if (final_output_check == o_mux_array2)
          $display("PASS: Final output matches expected.");
        else begin
          $display("FAIL: Expected: %h, Actual: %h", final_output_check, o_mux_array2);
          failed_final_tests++;
        end
        total_compressed_bits -= CACHE_LINE;
      end
    end
  endtask

  // Predict the compressed word by processing the 64-bit input word.
  task predict_compressed_word(input logic [63:0] in_word);
    logic [6:0] exp_length1, exp_length2;
    logic [2:0] exp_code1, exp_code2;
    logic [3:0] dict_idx1, dict_idx2;
    logic [33:0] expected_compressed_word1;
    logic [33:0] expected_compressed_word2;
    logic update_dict;

    begin
      total_tests++;
      total_word += 2;
      $display("Input word: %h", in_word);

      // Check pattern for two 32-bit words extracted from the 64-bit in_word
      check_pattern(in_word[31:0], in_word[63:32],
                    exp_length1, exp_length2,
                    exp_code1, exp_code2,
                    dict_idx1, dict_idx2,
                    update_dict);
      generate_prediction(in_word[31:0], exp_code1, dict_idx1, expected_compressed_word1);
      track_compression(exp_length1, exp_length2);
      wait_clk(INTERNAL_WAIT);
      if(update_dict) begin
          update_dict = 0;
      end
      generate_prediction(in_word[63:32], exp_code2, dict_idx2, expected_compressed_word2);

      predict_final_compressor_output(in_word[31:0], in_word[63:32],
                                      expected_compressed_word1, expected_compressed_word2,
                                      total_words_compressed, total_compressed_bits);
    end
  endtask

  //===========================================================================
  // 5. Main Test Sequence
  //===========================================================================

  // Clock generation
  always #5 i_clk = ~i_clk;

  // Main initial block for simulation
  initial begin
    i_clk = 0;
    i_reset = 0;
    i_word = 0;
    
    // Apply reset
    #15 i_reset = 1;
    wait_clk(1);
    
    // Initialize the internal dictionary
    init_dictionary();
    wait_clk(SETUP_WAIT);

    // Test Cases:
    // Case 1: zzzz (All Zero)
    i_word <= {32'h00000000, 32'h00000000};
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);

    // Case 2: mmmm (All Matched)
    i_word <= {32'hAABBCCDD, 32'h11223344}; // already in dictionary
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);

    // Case 3: zzzx (Single Byte Difference)
    i_word <= {32'h00000012, 32'h000000AB};
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);

    // Case 4: mmmx (Three Byte Match)
    i_word <= {32'hAABBCC12, 32'h11223399}; // Matches first 3 bytes in dictionary
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);

    // Case 5: mmxx (Two Byte Match)
    i_word <= {32'hAABB0012, 32'h11220099}; // Matches first 2 bytes in dictionary
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);

    // Case 6: xxxx (Completely unmatched)
    i_word <= {32'hFACEB00C, 32'hDEADBEEF}; 
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    // Additional test cases...
    // Case 7: Alternating Patterns
    i_word <= {32'h00000000, 32'h11223344};
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    i_word <= {32'h000000AA, 32'h55667788};
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    i_word <= {32'hAABBCCDD, 32'h00000000};
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    i_word <= {32'h556677FF, 32'h99AAABCD}; // mmmx and mmxx
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    // Case 8: Dictionary Updates
    i_word <= {32'hAAAABBBB, 32'hCCCCDDDD}; // New entries
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    i_word <= {32'hEEEFFFFF, 32'h12345678}; // One new, one existing
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    // Case 9: Edge Cases
    i_word <= {32'hFFFFFFFF, 32'h00000000}; // Maximum and minimum
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    i_word <= {32'h80000000, 32'h7FFFFFFF}; // Min (signed) and max (signed)
    wait_clk(SETUP_WAIT);
    predict_compressed_word(i_word);
    wait_clk(1);
    
    #20 $finish;
  end

endmodule
