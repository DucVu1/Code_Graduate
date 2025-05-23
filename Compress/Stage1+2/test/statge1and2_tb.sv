`timescale 1ns / 1ps

module tb_stage1and2;
  parameter WIDTH      = 64;   
  parameter DICT_ENTRY = 16;
  parameter DICT_WORD  = 32;
  parameter WORD       = 32;
  parameter CACHE_LINE = 128;
  parameter DATA_WIDTH = 32;
  
  // DUT inputs
  logic               i_clk;
  logic               i_reset;    // active-low reset
  logic [WIDTH-1:0]   i_word;
  
  // DUT outputs
  logic               o_store_flag;  
  logic [6:0]         o_shift_amount;
  logic               o_send_back;
  logic [511:0]       dictionary_data;
  logic [2:0]         o_encoded1;
  logic [2:0]         o_encoded2;
  logic [5:0]         o_length1;
  logic [5:0]         o_length2;
  logic [6:0]         o_total_length;
  logic               o_fill_flag;  // Determines whether to select the padded signal
  logic               o_output_flag; // Raised when there are 128 compressed bits in Reg2
  logic               o_fill_ctrl;   
  logic               o_stop_flag;   // Raised when the number of compressed bits exceeds 128
  
  logic [DICT_ENTRY-1:0][DATA_WIDTH-1:0] dict_mem;
  int dict_index = 0;
  
  // Instantiate the DUT: stage1and2.
  stage1and2 #(
    .WIDTH(WIDTH),
    .DICT_ENTRY(DICT_ENTRY),
    .DICT_WORD(DICT_WORD),
    .WORD(WORD),
    .CACHE_LINE(CACHE_LINE)
  ) uut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_word(i_word),
    .o_store_flag(o_store_flag),
    .o_shift_amount(o_shift_amount),
    .o_send_back(o_send_back),
    .dictionary_data(dictionary_data),
    .o_encoded1(o_encoded1),
    .o_encoded2(o_encoded2),
    .o_length1(o_length1),
    .o_length2(o_length2),
    .o_total_length(o_total_length),
    .o_fill_flag(o_fill_flag),   // Determines whether to select the padded signal
    .o_output_flag(o_output_flag), // Raised when there are 128 compressed bits in Reg2
    .o_fill_ctrl(o_fill_ctrl),   
    .o_stop_flag(o_stop_flag)     // Raised when the number of compressed bits exceeds 128 
  );

  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end
  
  initial begin
    $dumpfile("tb_stage1and2.vcd");
    $dumpvars(0, tb_stage1and2);
  end

 task update_fifo_dictionary(input logic [DATA_WIDTH-1:0] word);
    begin
      dict_mem[dict_index] = word;
      $display("[FIFO Update] New word %h inserted at index %0d", word, dict_index);
      dict_index = (dict_index + 1) % DICT_ENTRY;
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
  
  task preload_word(input logic [DATA_WIDTH-1:0] word0, input logic [DATA_WIDTH-1:0] word1);
    begin
      i_word <= {word1, word0}; // Lower word is word0, upper word is word1
      dict_mem[dict_index]   = word0;
      dict_mem[dict_index+1] = word1;
      dict_index += 2;
      #10; // Wait one clock cycle for the dictionary to update.
    end
  endtask
  
task check_pattern(input [31:0] first_word, input [31:0] second_word);
    logic [6:0] exp_length1, exp_length2;
    logic [2:0] exp_code1, exp_code2;
    integer j;
    logic found1, found2;
    
    // Check first word
    if (first_word == 32'd0) begin // zzzz
        exp_length1 = 7'd2;
        exp_code1   = 3'b000;
    end else if (first_word[31:8] == 24'd0) begin
        exp_length1 = 7'd12;
        exp_code1   = 3'b010;
    end else begin
        found1 = 0;
        for (j = 0; j < DICT_ENTRY; j = j + 1) begin
            if (dict_mem[j] == first_word) begin // mmmm
                found1 = 1;
                exp_length1 = 7'd6;
                exp_code1   = 3'b001;
                break;
            end else if (dict_mem[j][31:8] == first_word[31:8]) begin  // mmmx
                exp_length1 = 7'd16;
                exp_code1   = 3'b011;
                found1 = 1;
            end else if (dict_mem[j][31:16] == first_word[31:16]) begin // mmxx
                exp_length1 = 7'd24;
                exp_code1   = 3'b100;
                found1 = 1;
            end
        end
        if (!found1) begin
            exp_length1 = 7'd34;
            exp_code1   = 3'b101;
            update_fifo_dictionary(first_word);
        end
    end
    
    // Check second word
    if (second_word == 32'd0) begin
        exp_length2 = 7'd2;
        exp_code2   = 3'b000;
    end else if (second_word[31:8] == 24'd0) begin
        exp_length2 = 7'd12;
        exp_code2   = 3'b010;
    end else begin
        found2 = 0;
        for (j = 0; j < DICT_ENTRY; j = j + 1) begin
            if (dict_mem[j] == second_word) begin // mmmm
                found2 = 1;
                exp_length2 = 7'd6;
                exp_code2   = 3'b001;
                break;
            end else if (dict_mem[j][31:8] == second_word[31:8]) begin  // mmmx
                exp_length2 = 7'd16;
                exp_code2   = 3'b011;
                found2 = 1;
            end else if (dict_mem[j][31:16] == second_word[31:16]) begin // mmxx
                exp_length2 = 7'd24;
                exp_code2   = 3'b100;
                found2 = 1;
            end
        end
        if (!found2) begin
            exp_length2 = 7'd34;
            exp_code2   = 3'b101;
            update_fifo_dictionary(second_word);
        end
    end
    
    // Display results
    $display("[Pattern Check] First Word = %h, Second Word = %h", first_word, second_word);
    if ((o_encoded1 !== exp_code1) || (o_length1 !== exp_length1))
        $display("[ERROR] First word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code1, exp_length1, o_encoded1, o_length1);
    else
        $display("[PASS] First word pattern OK.");
    
    if ((o_encoded2 !== exp_code2) || (o_length2 !== exp_length2))
        $display("[ERROR] Second word mismatch: Expected code=%b, length=%d; Got code=%b, length=%d",
                 exp_code2, exp_length2, o_encoded2, o_length2);
    else
        $display("[PASS] Second word pattern OK.");
endtask

  task check_length(input logic exp_store_flag, input logic [6:0] exp_shift_amount, input logic exp_send_back);
    begin
      $display("[Length Check] store_flag=%b, shift_amount=%d, send_back=%b", o_store_flag, o_shift_amount, o_send_back);
      if (o_store_flag !== exp_store_flag)
        $display("[ERROR] store_flag mismatch: Expected %b, Got %b", exp_store_flag, o_store_flag);
      if (o_shift_amount !== exp_shift_amount)
        $display("[ERROR] shift_amount mismatch: Expected %d, Got %d", exp_shift_amount, o_shift_amount);
      if (o_send_back !== exp_send_back)
        $display("[ERROR] send_back mismatch: Expected %b, Got %b", exp_send_back, o_send_back);
    end
  endtask
  
  // ---------------------------
  // Test Sequence
  // ---------------------------
  initial begin
    $dumpfile("tb_stage1and2.vcd");
    $dumpvars(0, tb_stage1and2);

    i_reset = 0; 
    i_word = 64'd0;
    #15;
    i_reset = 1; 
    #10;
    
    // Initialize dictionary by preloading known words.
    init_dictionary();
    
    i_word <= {32'h11223344, 32'hAABBCCDD};
    #20;
    $display("Test Case 1: Dictionary Match");
    check_pattern(32'hAABBCCDD, 32'h11223344);
    check_length(0, 7'd8, 0); 
    
    i_word <= {32'h00000000, 32'h00000000};
    #20;
    $display("Test Case 2: ZZZZ Pattern");
    check_pattern(32'h00000000, 32'h00000000);
    check_length(0, 7'd8, 0); 
  
    i_word <= {32'hDEADBEEF, 32'hFACECAFE};
    #20;
    $display("Test Case 3: Non-Matching Pattern");
    check_pattern(32'hDEADBEEF, 32'hFACECAFE);
    check_length(1, 7'd8, 0);
    
    $display("All tests completed.");
    #20;
    $finish;
  end
  


endmodule
