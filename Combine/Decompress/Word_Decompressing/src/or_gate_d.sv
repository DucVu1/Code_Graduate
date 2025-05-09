module or_gate_d #(
 parameter WIDTH = 196
)
(
 input logic [WIDTH - 1 : 0] i_first_word,
 input logic [WIDTH - 1 : 0] i_second_word,
 output logic [WIDTH - 1 :0] o_word
);

assign o_word = i_first_word | i_second_word;

endmodule