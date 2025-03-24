module total_length_generator (
 input  logic [5:0] i_word1_length,
 input  logic [5:0] i_word2_length,
 output logic [6:0] o_total_length
);

assign o_total_length = i_word1_length + i_word2_length;

endmodule