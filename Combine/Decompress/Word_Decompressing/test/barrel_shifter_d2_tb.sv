module tb_barrel_shifter;

  // Parameters
  parameter WIDTH = 196;
  parameter SHIFT_BIT = $clog2(WIDTH);

  // DUT signals
  logic [WIDTH-1:0] i_word;
  logic [SHIFT_BIT-1:0] i_amt;
  logic [WIDTH-1:0] o_word;

  // Expected output
  logic [WIDTH-1:0] expected;

  // Instantiate DUT
  barrel_shifter_d2 #(
    .WIDTH(WIDTH),
    .SHIFT_BIT(SHIFT_BIT)
  ) dut (
    .i_word(i_word),
    .i_amt(i_amt),
    .o_word(o_word)
  );

  // Test
  initial begin
    $display("Starting Barrel Shifter Testbench...");
    for (int i = 0; i < 100; i++) begin
      i_word = $urandom;
      i_word = {i_word, $urandom, $urandom}; // Extend to 196 bits
      i_amt  = $urandom_range(0, WIDTH-1);

      #1; // wait for combinational output

      expected = i_word << i_amt;

      // Scoreboard check
      if (o_word !== expected) begin
        $display("\n[ERROR] Mismatch at test %0d", i);
        $display("Input       : %b", i_word);
        $display("Shift Amt   : %0d", i_amt);
        $display("Expected    : %b", expected);
        $display("DUT Output  : %b", o_word);
        $fatal("[TB FAIL] Output mismatch.");
      end else begin
        $display("[PASS] Test %0d: shift %0d OK", i, i_amt);
      end
    end

    $display("All tests passed!");
    $finish;
  end

endmodule
