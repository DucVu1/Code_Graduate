module barrel_shifter_d1 #(
  parameter WIDTH = 196,
  parameter I_WIDTH = 128,
  parameter SHIFT_BIT = $clog2(WIDTH)
)(
  input  logic [I_WIDTH-1:0]   i_word,
  input  logic [SHIFT_BIT-1:0] i_amt,
  output logic [WIDTH-1:0]     o_word
);

  logic [WIDTH-1:0] stage [$clog2(WIDTH):0];

  assign stage[0] = i_word;

  // Generate shifts: stage[i+1] is stage[i] shifted right by 2^i if i_amt[i] is set
  genvar i;
  generate
    for (i = 0; i < SHIFT_BIT; i++) begin : gen_shift_stage
      assign stage[i+1] = i_amt[i] ? { {2**i{1'b0}}, stage[i][WIDTH-1:2**i] } : stage[i];
    end
  endgenerate

  assign o_word = stage[SHIFT_BIT];

endmodule
