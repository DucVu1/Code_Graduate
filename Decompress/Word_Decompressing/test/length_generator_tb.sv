`timescale 1ns/1ps

module tb_length_generator;

  // Parameters
  localparam CODE   = 2;
  localparam LENGTH = 6;

  // DUT Inputs
  logic [CODE - 1:0] i_codes;
  logic [CODE - 1:0] i_codes_bak;
  logic [CODE - 1:0] i_codes2;
  logic [CODE - 1:0] i_codes_bak2;

  // DUT Outputs
  logic [LENGTH - 1:0] o_length1;
  logic [LENGTH - 1:0] o_length2;

  // Scoreboard counters
  int pass_count = 0;
  int fail_count = 0;

  // DUT instantiation
  length_generator #(
    .CODE(CODE),
    .LENGTH(LENGTH)
  ) dut (
    .i_codes(i_codes),
    .i_codes_bak(i_codes_bak),
    .i_codes2(i_codes2),
    .i_codes_bak2(i_codes_bak2),
    .o_length1(o_length1),
    .o_length2(o_length2)
  );

  // Function to return expected length from code and backup
  function automatic [LENGTH-1:0] expected_length(input logic [1:0] code, input logic [1:0] code_bak);
    begin
      case (code)
        2'b00: expected_length = 6'd2;   // zzzz
        2'b01: expected_length = 6'd34;  // xxxx
        2'b10: expected_length = 6'd6;   // mmmmm
        2'b11: begin
          case (code_bak)
            2'b00: expected_length = 6'd24; // mmxx
            2'b01: expected_length = 6'd12; // zzzx
            2'b10: expected_length = 6'd16; // mmmmx
            2'b11: expected_length = 6'd32; // default
            default: expected_length = 6'd0;
          endcase
        end
        default: expected_length = 6'd0;
      endcase
    end
  endfunction

  // Task to run and check one case
  task automatic run_case(
    input logic [1:0] code1,
    input logic [1:0] bak1,
    input logic [1:0] code2,
    input logic [1:0] bak2
  );
    logic [LENGTH-1:0] exp_len1, exp_len2;
    begin
      i_codes = code1;
      i_codes_bak = bak1;
      i_codes2 = code2;
      i_codes_bak2 = bak2;
      exp_len1 = expected_length(code1, bak1);
      exp_len2 = expected_length(code2, bak2);

      #1; // wait for output

      if (o_length1 === exp_len1 && o_length2 === exp_len2) begin
        $display("PASS: c1=%b b1=%b -> o1=%0d | c2=%b b2=%b -> o2=%0d",
                 code1, bak1, o_length1, code2, bak2, o_length2);
        pass_count++;
      end else begin
        $display("FAIL: c1=%b b1=%b -> o1=%0d (exp %0d) | c2=%b b2=%b -> o2=%0d (exp %0d)",
                 code1, bak1, o_length1, exp_len1, code2, bak2, o_length2, exp_len2);
        fail_count++;
      end
    end
  endtask

  // Test all combinations
  initial begin
    $display("===== Starting length_generator Scoreboard Testbench =====");
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        run_case(i[1:0], j[1:0], j[1:0], i[1:0]);
      end
    end

    $display("===== Test Complete =====");
    $display("Total Passed: %0d", pass_count);
    $display("Total Failed: %0d", fail_count);

    if (fail_count == 0)
      $display("🎉 All test cases passed!");
    else
      $display("❌ Some test cases failed. Check above logs.");

    $stop;
  end

endmodule
