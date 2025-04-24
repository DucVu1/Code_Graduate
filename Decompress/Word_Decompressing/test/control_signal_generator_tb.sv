module control_signal_generator_tb;

  // Inputs
  logic [1:0] i_first_code;
  logic [1:0] i_first_code_bak;
  logic [1:0] i_second_code;
  logic [1:0] i_second_code_bak;

  // Output
  logic [1:0] ctrl_signal;

  // DUT instance
  control_signal_generator dut (
    .i_first_code(i_first_code),
    .i_first_code_bak(i_first_code_bak),
    .i_second_code(i_second_code),
    .i_second_code_bak(i_second_code_bak),
    .ctrl_signal(ctrl_signal)
  );

  // Scoreboard task to predict ctrl_signal
  function [1:0] expected_ctrl_signal(
    input [1:0] fc,
    input [1:0] fb,
    input [1:0] sc,
    input [1:0] sb
  );
    logic [1:0] expected;
    logic first_code_all_ones, second_code_all_ones;
    logic first_code_bak_check, second_code_bak_check;

    first_code_all_ones = &fc;
    second_code_all_ones = &sc;
    first_code_bak_check = ~fb[1] & fb[0];
    second_code_bak_check = ~sb[1] & sb[0];

    expected[0] = (first_code_all_ones && !first_code_bak_check) ? 1'b1 : 1'b0;
    expected[1] = (second_code_all_ones && !second_code_bak_check) ? 1'b1 : 1'b0;

    return expected;
  endfunction

  // Task to apply test vector and compare
  task run_test(
    input [1:0] fc,
    input [1:0] fb,
    input [1:0] sc,
    input [1:0] sb
  );
    logic [1:0] expected;
    begin
      i_first_code = fc;
      i_first_code_bak = fb;
      i_second_code = sc;
      i_second_code_bak = sb;
      #1; // Allow logic to propagate

      expected = expected_ctrl_signal(fc, fb, sc, sb);
      $display("Inputs => FC: %b, FB: %b, SC: %b, SB: %b", fc, fb, sc, sb);
      $display("Expected: %b, DUT Output: %b", expected, ctrl_signal);

      assert(ctrl_signal == expected)
        else $fatal("[ERROR] Mismatch: expected %b, got %b", expected, ctrl_signal);
    end
  endtask

  initial begin
    $display("🏁 Starting control_signal_generator test with scoreboard...");

    // Exhaustive test for all combinations (optional: test specific cases only)
    for (int a = 0; a < 4; a++) begin
      for (int b = 0; b < 4; b++) begin
        for (int c = 0; c < 4; c++) begin
          for (int d = 0; d < 4; d++) begin
            run_test(a[1:0], b[1:0], c[1:0], d[1:0]);
          end
        end
      end
    end

    $display("✅ All tests passed successfully.");
    $finish;
  end

endmodule
