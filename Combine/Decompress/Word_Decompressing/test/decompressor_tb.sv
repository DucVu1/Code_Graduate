`timescale 1ns/1ps

module decompressor_tb;
  parameter WIDTH_DATA_IN = 128;
  parameter WIDTH128      = 128;
  parameter WIDTH196      = 196;
  parameter CODE          = 2;
  parameter WORD          = 16;
  parameter SIZE          = 8; 
  parameter WIDTH         = 32;
  parameter LENGTH        = 6;


  integer log_file;
  logic                        clk, reset;
  logic                        update, comp_flag, i_decompressor_en;
  logic [WIDTH_DATA_IN-1:0]    data_in, data_out;

  // DUT instantiation
  decompressor #(
    .WIDTH_DATA_IN(WIDTH_DATA_IN),
    .WORD         (WORD),
    .WIDTH        (WIDTH),
    .LENGTH_CODE  (CODE),
    .LENGTH       (LENGTH),
    .REMAIN_LENGTH(8),
    .RESULT_LENGTH(7)
  ) dut (
    .i_clk      (clk),
    .i_decompressor_en(i_decompressor_en),
    .i_reset    (reset),
    .i_update   (update),
    .i_comp_flag(comp_flag),
    .i_data     (data_in),
    .o_data     (data_out)
  );
//unpacker
logic [CODE - 1 : 0]       first_code, second_code;
logic [CODE - 1 : 0]       first_code_bak, second_code_bak;
logic [$clog2(WORD)-1 : 0] idx1, idx2;
logic [LENGTH - 1 : 0]     first_length, second_length;
logic [WIDTH196 - 1 : 0]   second_shifted;
logic [WIDTH196 - 1 : 0]   shifted_data_r;
logic [7 : 0]o_remain_length;
logic [7 : 0]o_remain_length_n;
logic [7 : 0]o_len_r, remaining_length;
//logic        reg_reset;
//decoder
logic [WIDTH - 1 : 0]      first_word, second_word;
logic [WORD*WIDTH - 1 : 0] dictionary_data;
logic [WIDTH196 -1 : 0 ]   i_decoder2;
//check signal
logic [WIDTH196 - 1 : 0]   reg_array1_out;
logic [WIDTH196 - 1 : 0]   o_barrel_shifter1;
logic [WIDTH196 - 1 : 0]   o_or_gate;
logic [WIDTH196 - 1 : 0]   shift_data_g;
logic [WIDTH_DATA_IN - 1 : 0]o_latch; 

logic mux2_sel;
logic o_comp_signal;
logic latch_en;

//unpacker output
assign o_latch        = dut.o_latch;
assign first_code     = dut.o_first_code;
assign second_code    = dut.o_second_code;
assign idx1           = dut.o_idx1;
assign idx2           = dut.o_idx2;
assign first_length   = dut.o_first_length;
assign second_length  = dut.o_second_length;
assign first_code_bak = dut.o_first_code_bak;
assign second_code_bak= dut.o_second_code_bak;
assign o_remain_length= dut.o_remain_length;
assign o_remain_length_n= dut.unpacker.o_remain_length_n;
//assign reg_reset = dut.unpacker.reg_reset2;
assign o_len_r        = dut.o_len_r;
//decoder
assign first_word  = dut.first_word;
assign second_word = dut.second_word;
assign dictionary_data = dut.dictionary_data;
assign i_decoder2 = dut.i_decoder2;
//check signal
assign reg_array1_out = dut.reg_array1_out;
assign o_or_gate = dut.o_or_gate;
assign o_barrel_shifter1 = dut.o_barrel_shifter1;

assign second_shifted = dut.unpacker.second_shifted;
assign shifted_data_r = dut.unpacker.shifted_data_r;
assign mux2_sel = dut.mux2_sel;
assign o_comp_signal = dut.o_comp_signal;
assign latch_en = dut.latch_en;

task decode_word(
  input  logic [1:0]             code,
  input  logic [1:0]             code_bak,
  input  logic [WIDTH128-1:0]    i_word,
  input  logic [$clog2(WORD)-1:0]idx,
  input  logic                   wword,
  input  logic [WORD*WIDTH-1:0]  dict_flat
);
  logic [WIDTH-1:0] temp_data;
  logic [WIDTH-1:0] ref_word;
  logic [WIDTH-1:0] word_out;
begin
  temp_data = dict_flat[idx * WIDTH +: WIDTH];
  $display("code: %b", code);
  case (code)
    2'b00: word_out = 32'd0; 
    2'b01: word_out = i_word[33:2];
    2'b10: word_out = temp_data; 
    2'b11: begin
      case (code_bak)
        2'b00: word_out = {temp_data[31:16], i_word[23:8]}; // mmxx
        2'b01: word_out = {24'd0, i_word[11:4]};            // zzzx
        2'b10: word_out = {temp_data[WIDTH - 1 : 8], i_word[11:4]}; // mmmmx
        2'b11: word_out = i_word[31:0];                     // xxxx (backup case)
        default: word_out = 'x; // safety
      endcase
    end
    default: word_out = 'x;
  endcase
  if(~wword) ref_word = first_word;
  else ref_word = second_word;

  if(word_out == ref_word) $fdisplay(log_file, "[%0t ns][PASS] word check passed, dut_word: %h expected_word %h.", 
                                      $realtime, ref_word, word_out);
    else begin
       $fdisplay(log_file,"[%0t ns][FAIL] word mismatch: expected %h, got %h", $time, word_out, ref_word ); 
       $fatal("[%0t ns] word mismatch: expected %h, got %h", $time, word_out, ref_word ); 
      end
  // #0 assert(word_out == ref_word) $display("[%0t ns] word check passed.", $realtime);
  //   else $fatal("[%0t ns] word mismatch: expected %h, got %h", $time, word_out, ref_word );
end
endtask

//extract code 
task check_word(input [WIDTH128-1:0] word_data, input logic wword , output logic [LENGTH-1:0] ref_length);
  logic [1:0] ref_code, check_code;
  logic [1:0] ref_code_bak, check_code_bak;
  logic [$clog2(WORD)-1:0] ref_idx, check_idx;
  logic [LENGTH - 1 : 0] check_length;
  logic [WIDTH128 - 1 : 0] shifted_data_local;
  shifted_data_local = shifted_data_r[127:0];
  ref_code = word_data[1:0];
  if (&ref_code) begin
    ref_code_bak = word_data[3:2];
    ref_idx = word_data[7:4];
  end else begin
    ref_code_bak = 2'b00;
    ref_idx = word_data[5:2];
  end

  length_lookup_task(ref_code, ref_code_bak, ref_length);
  $display("Word_in_tb:  %b , HEX: %h", word_data, word_data);
  $display("Word_in_dut: %b , HEX: %h", shifted_data_local, shifted_data_local);
  // Scoreboard assertions for first word
  if(wword) begin 
    $display("Second");
    check_code = second_code;
    check_code_bak = second_code_bak;
    check_idx =idx2;
    check_length = second_length;
  end
  else begin
    $display("First");
    check_code = first_code;
    check_code_bak = first_code_bak;
    check_idx =idx1;
    check_length = first_length;
  end
  $fdisplay(log_file,"Word_in_tb:  %b , HEX: %h", word_data, word_data);
  $fdisplay(log_file,"Word_in_dut: %b , HEX: %h", shifted_data_local, shifted_data_local);
  if(check_code == ref_code) $fdisplay(log_file,"[%0t ns][PASS] code check passed.", $realtime);
    else begin 
      $fdisplay(log_file,"[%0t ns][FAIL] code mismatch: expected %b, got %b", $time, ref_code, check_code );
      $fatal("[%0t ns] code mismatch: expected %b, got %b", $time, ref_code, check_code );
    end
  // #0 assert(check_code == ref_code) $display("[%0t ns] code check passed.", $realtime);
  //   else $fatal("[%0t ns] code mismatch: expected %b, got %b", $time, ref_code, check_code);
  if(check_code_bak == ref_code_bak) $fdisplay(log_file,"[%0t ns][PASS] code_bak check passed.", $realtime);
    else begin
      $fdisplay(log_file,"[%0t ns][FAIL] code_bak mismatch: expected %b, got %b", $time, ref_code_bak, check_code_bak );
      $fatal("[%0t ns] code_bak mismatch: expected %b, got %b", $time, ref_code_bak, check_code_bak );
    end
  // #0 assert(check_code_bak == ref_code_bak) $display("[%0t ns] code_bak check passed.", $realtime);
  //   else $fatal("[%0t ns] code_bak mismatch: expected %b, got %b", $time, ref_code_bak, check_code_bak );
  if(check_idx == ref_idx) $fdisplay(log_file,"[%0t ns][PASS] index check passed.", $realtime);
    else begin
      $fdisplay(log_file,"[%0t ns][FAIL] idx mismatch: expected %0d, got %0d", $time, ref_idx, check_idx );
      $fatal("[%0t ns] idx mismatch: expected %0d, got %0d", $time, ref_idx, check_idx );
    end
  // #0 assert(check_idx == ref_idx) $display("[%0t ns] index check passed.", $realtime);
  //   else $fatal("[%0t ns] idx mismatch: expected %0d, got %0d", $time, ref_idx, check_idx);
  if(check_length == ref_length) $fdisplay(log_file,"[%0t ns][PASS] length check passed.", $realtime);
    else begin
      $fdisplay(log_file,"[%0t ns][FAIL] length mismatch: expected %0d, got %0d", $time, ref_length, check_length ); 
      $fatal("[%0t ns] length mismatch: expected %0d, got %0d", $time, ref_length, check_length ); 
    end
  // #0 assert(check_length == ref_length) $display("[%0t ns] length check passed.", $realtime);
  //   else $fatal("[%0t ns] length mismatch: expected %0d, got %0d", $time, ref_length, check_length );
  
  decode_word(ref_code, ref_code_bak, word_data, ref_idx, wword, dictionary_data);

endtask

//extract_length
  task length_lookup_task(
    input [1:0] code,
    input [1:0] code_bak,
    output [LENGTH - 1 : 0] length_lookup
  );
  $display("code: %b, code_bak: %b", code, code_bak);
    case (code)
      2'b00: length_lookup = 2; // zzzz
      2'b01: length_lookup = 34; // xxxx
      2'b10: length_lookup = 6; // mmmm
      2'b11: begin
        case (code_bak)
          2'b00: length_lookup = 24; // mmmx
          2'b01: length_lookup = 12; // zzzx
          2'b10: length_lookup = 16; // mmmx
          default: length_lookup = 32;
        endcase
      end
    endcase
  endtask
  
task run_testcase(input [127:0] test_vector [0:14]);
    integer offset, idx,j;
    logic [LENGTH-1:0]  first_word_length, second_word_length;
    logic [WIDTH196 - 1 :0]shift_data;
    integer  cycles;
    begin
    idx = 0;
    cycles = 0;
    remaining_length = 128;
    j = 0;
    data_in <= test_vector[0];
    offset = 0;
    shift_data <= test_vector[0];
    shift_data_g = shift_data;
    update = 1;
    @(posedge clk);
    update = 0;
    i_decompressor_en = 1;
    @(posedge clk);
    //$display("%d",offset );
    while(idx < 15 ) begin
      data_in <= test_vector[idx + 1];
      check_word(shift_data, 0, first_word_length);
      shift_data = shift_data >> first_word_length;
      check_word(shift_data, 1, second_word_length);
      shift_data = shift_data >> second_word_length;
      offset = first_word_length + second_word_length;
      shift_data_g = shift_data;
      $display("Offset: %d",offset);
      remaining_length = remaining_length - offset;
      $display("Current length: %d", remaining_length );
      if((remaining_length < 8'd68) && idx < 14) begin
       idx++;
       data_in <= test_vector[idx + 1];
       shift_data = (test_vector[idx] << remaining_length) | shift_data;
       shift_data_g = shift_data;
       remaining_length = remaining_length + 8'd128;
      end
      @(posedge clk);  
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

initial begin
  log_file = $fopen("decompressor.log", "w");
  if (log_file == 0) begin
    $fatal("Failed to open log file");
  end
end

always #5 clk = ~clk;

logic [127:0] test_vector [0:14];

initial begin
  clk = 0;
  reset = 0;
  update = 0;
  data_in = 0;

  #15 reset = 1;
  @(posedge clk);

    test_vector[0]  = 128'h0123_4567_89AB_CDEF_FEDC_BA98_7654_3210;
    test_vector[1]  = 128'hDEAD_BEEF_CAFE_BABE_0000_0000_0000_0000;
    test_vector[2]  = 128'h03FF_0001_0022_3344_5566_7788_99AA_BBCC;
    test_vector[3]  = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    test_vector[4]  = 128'h0002_0001_0000_0000_0003_0004_0005_0006;
    test_vector[5]  = 128'hF0F1_F2F3_F4F5_F6F7_F8F9_FAFA_FBFC_FDFE;
    test_vector[6]  = 128'h0000_0001_0002_F0F1_F2F3_ABC0_1234_DEAD_BEEF;
    test_vector[7]  = 128'h0000_0000_0010_0000_0000_00F0_0F00_0000;
    test_vector[8]  = 128'h3000_0002_1000_0000_1000_0002_4000_0000;
    test_vector[9]  = 128'hC000_0123_4567_89AB_0CDE_0F12_0789_ABCD;
    test_vector[10] = 128'h0000_1001_3002_C110_C220_C001_0001_0000;
    test_vector[11] = 128'h0123_4567_89AB_CDEF_0001_0011_0022_0033;
    test_vector[12] = 128'h0000_0000_0000_0000_0000_0000_FFFF_FFFF;
    test_vector[13] = 128'hDEAD_BEEF_CAFE_BABE_0000_1234_5678_9000;
    test_vector[14] = 128'h03FF_0001_0022_3344_5566_7788_99AA_BBFF;
  run_testcase(test_vector);
  $fdisplay(log_file,"All tests complete.");
  $finish;
end
endmodule
