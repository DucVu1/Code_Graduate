`timescale 1ns / 1ps

module tb_decoder;

  // Parameters
  localparam CODES = 2;
  localparam WORD  = 16;
  localparam WIDTH = 32;
  localparam I_WORD = 196;
  localparam I_WORD2 = 34;

  // DUT inputs
  logic [CODES - 1 : 0]        i_codes;
  logic [CODES - 1 : 0]        i_codes_bak;
  logic [I_WORD2 - 1 : 0]      i_word;
  logic [$clog2(WORD) - 1 : 0] i_idx;
  logic [WORD * WIDTH - 1 : 0] i_dict;

  // DUT output
  logic [WIDTH - 1 : 0]        o_word;

  // DUT instantiation
  decoder #(
    .CODES(CODES),
    .WORD(WORD),
    .WIDTH(WIDTH),
    .I_WORD(I_WORD),
    .I_WORD2(I_WORD2)
  ) dut (
    .i_codes(i_codes),
    .i_codes_bak(i_codes_bak),
    .i_word(i_word),
    .i_idx(i_idx),
    .i_dict(i_dict),
    .o_word(o_word)
  );

  // Function to build a temporary 512-bit dictionary
  function automatic [WORD * WIDTH - 1 : 0] generate_dict();
    logic [WORD * WIDTH - 1 : 0] dict;
    integer i;
    begin
      for (i = 0; i < WORD; i++) begin
        dict[i * WIDTH +: WIDTH] = i * 100; // unique pattern for visibility
      end
      return dict;
    end
  endfunction

  // Test sequence
  initial begin
    $display("===== Starting Decoder Testbench =====");

    // Load 512-bit dictionary inline
    i_dict = generate_dict();

    // CASE 1: i_codes = 2'b00 => expect 0
    i_codes = 2'b00;
    i_word = 34'h123456789;
    i_idx = 4;
    #1 $display("i_codes=00 -> o_word = %h (expected 00000000)", o_word);

    // CASE 2: i_codes = 2'b01 => expect lower 32-bit of i_word
    i_codes = 2'b01;
    i_word = 34'hDEADBEEF1;
    #1 $display("i_codes=01 -> o_word = %h (expected %h)", o_word, i_word[31:0]);

    // CASE 3: i_codes = 2'b10 => expect i_dict[i_idx]
    i_codes = 2'b10;
    i_idx = 7; // dict[7] = 700
    i_dict = generate_dict();
    #1 $display("i_codes=10 -> o_word = %h (expected 000002BC)", o_word); // 700 in hex = 0x2BC

    // CASE 4: i_codes = 2'b11 and i_codes_bak = 2'b00 => {16'b0, i_word[15:0]}
    i_codes = 2'b11;
    i_codes_bak = 2'b00;
    i_word = 34'hABCDEF123;
    #1 $display("i_codes=11, i_codes_bak=00 -> o_word = %h (expected 0000123)", o_word);

    // CASE 5: i_codes = 2'b11 and i_codes_bak = 2'b01 => {24'b0, i_word[7:0]}
    i_codes_bak = 2'b01;
    #1 $display("i_codes=11, i_codes_bak=01 -> o_word = %h (expected 00000023)", o_word);

    // CASE 6: i_codes = 2'b11 and i_codes_bak = 2'b10 => {temp_data[31:8], i_word[7:0]}
    i_codes_bak = 2'b10;
    i_idx = 3;
    i_dict = generate_dict(); // dict[3] = 300 = 0x12C
    #1 $display("i_codes=11, i_codes_bak=10 -> o_word = %h", o_word);

    // CASE 7: i_codes = 2'b11 and i_codes_bak = 2'b11 => i_word[31:0]
    i_codes_bak = 2'b11;
    #1 $display("i_codes=11, i_codes_bak=11 -> o_word = %h (expected %h)", o_word, i_word[31:0]);

    $display("===== Decoder Testbench Finished =====");
    $stop;
  end

endmodule
