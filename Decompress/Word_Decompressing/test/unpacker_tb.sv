`timescale 1ns/1ps

module unpacker_tb;

  parameter WIDTH  = 128;
  parameter CODE   = 2;
  parameter WORD   = 16;
  parameter LENGTH = 6;

  logic                       clk;
  logic                       reset;
  logic                       update;
  logic [WIDTH - 1 : 0]       data_in;

  logic [CODE - 1 : 0]        first_code, second_code;
  logic [CODE - 1 : 0]        first_code_bak, second_code_bak;
  logic [$clog2(WORD)-1 : 0]  idx1, idx2;
  logic [LENGTH - 1 : 0]      first_length, second_length;
  logic [WIDTH-1:0] shifted_data_r, second_shifted, shifted_data_n;
  //logic [$clog2(WIDTH)-1:0] total_length_reg;
  logic [$clog2(WIDTH)-1:0] total_length_next;
  // DUT
  unpacker #(
    .WIDTH(WIDTH),
    .CODE(CODE),
    .WORD(WORD),
    .LENGTH(LENGTH)
  ) dut (
    .i_clk(clk),
    .i_reset(reset),
    .i_update(update),
    .i_data(data_in),
    .o_first_code(first_code),
    .o_first_code_bak(first_code_bak),
    .o_idx1(idx1),
    .o_second_code(second_code),
    .o_second_code_bak(second_code_bak),
    .o_idx2(idx2),
    .o_first_length(first_length),
    .o_second_length(second_length)
  );
 
assign shifted_data_r = dut.shifted_data_r;
assign shifted_data_n = dut.shifted_data_n;
assign second_shifted = dut.second_shifted;
//assign total_length_reg = dut.total_length_reg;
assign total_length_next = dut.total_length_next;
  // Clock generation
  always #5 clk = ~clk;

task check_word(input [WIDTH-1:0] word_data, input logic wword , output logic [LENGTH-1:0] ref_length);
// Decode first word fields from word_data
logic [1:0] ref_code, check_code;
logic [1:0] ref_code_bak, check_code_bak;
logic [$clog2(WORD)-1:0] ref_idx, check_idx;
logic [LENGTH - 1 : 0] check_length;

// First word decoding: lower bits of word_data
ref_code = word_data[1:0];
if (&ref_code) begin
  ref_code_bak = word_data[3:2];
  ref_idx = word_data[7:4];
end else begin
  ref_code_bak = 2'b00;
  ref_idx = word_data[5:2];
end

length_lookup_task(ref_code, ref_code_bak, ref_length);
$display("Word_in_tb: %b , HEX: %h", word_data, word_data);
// Scoreboard assertions for first word
if(wword) begin 
  $display("Second");
  $display("Word_in_dut: %b", dut.second_shifted);
  check_code = second_code;
  check_code_bak = second_code_bak;
  check_idx =idx2;
  check_length = second_length;
end
else begin
  $display("First");
  $display("Word_in_dut: %b", dut.shifted_data_r);
  check_code = first_code;
  check_code_bak = first_code_bak;
  check_idx =idx1;
  check_length = first_length;
end

assert(check_code == ref_code) $display("[%0t ns] code check passed.", $realtime);
  else $fatal("[%0t ns] code mismatch: expected %b, got %b", $time, ref_code, check_code);
assert(check_code_bak == ref_code_bak) $display("[%0t ns] code_bak check passed.", $realtime);
  else $fatal("[%0t ns] code_bak mismatch: expected %b, got %b", $time, ref_code_bak, check_code_bak );
assert(check_idx == ref_idx) $display("[%0t ns] index check passed.", $realtime);
  else $fatal("[%0t ns] idx mismatch: expected %0d, got %0d", $time, ref_idx, check_idx);
assert(check_length == ref_length) $display("[%0t ns] length check passed.", $realtime);
  else $fatal("[%0t ns] length mismatch: expected %0d, got %0d", $time, ref_length, check_length );

endtask

  // Fake length lookup function (mimics length_generator)
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
  
task run_testcase(input [WIDTH-1:0] packed_data);
    integer i;
    logic [LENGTH-1:0] offset, first_word_length, second_word_length;
    logic [WIDTH - 1 :0] shift_data;
    begin
    i = 0;
    data_in <= packed_data;
    offset = 0;
    shift_data <= packed_data ;
    update = 1;
    @(posedge clk);
    update = 0;
    @(posedge clk);
    $display("%d",offset );
    while (offset < WIDTH && i < 64) begin
      check_word(shift_data, 0, first_word_length);
      shift_data = shift_data >> first_word_length;
      check_word(shift_data, 1, second_word_length);
      shift_data = shift_data >> second_word_length;
      offset= first_word_length + second_word_length + offset;
      $display("shift_data: %b\ndut_data:   %b ", shift_data, dut.shifted_data_n);
      $display("current: %d",offset );
      i++;
      @(posedge clk);  
    end
    end
  endtask

  // === STIMULUS ===
  initial begin
    clk = 0;
    reset = 0;
    update = 0;
    data_in = 0;

    #10 reset = 1;
    @(posedge clk);
    $display("\n=== Testcase 1 ===");
    run_testcase(128'h_0000_0000_0000_00F3_0000_0000_0000_0000);
    @(posedge clk);
    $display("\n=== Testcase 2 ===");
    run_testcase(128'h_02AA_3F00_00B3_8891_1122_AABB_CC00_DD00);
    @(posedge clk);
    $display("\n=== Testcase 3 ===");
    run_testcase(128'h_03FF_0001_0022_3344_5566_7788_99AA_BBCC);
    @(posedge clk);
    $display("\n=== Testcase 4 ===");
    run_testcase(128'h_FFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000);
    @(posedge clk);
    $display("\n=== Testcase 5 ===");
    run_testcase(128'h_1234_5678_9ABC_DEF0_0F0F_0A0A_BABA_C0C0);
    @(posedge clk);
    $display("\nAll tests completed!");
    $finish;
  end

endmodule

