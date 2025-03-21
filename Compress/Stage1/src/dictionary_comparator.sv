module dictionary_comparator #(parameter WIDTH = 32, WORDS = 16)(
    input  logic [WIDTH - 1 : 0]     word_i,
    input  logic [(16*32) - 1 : 0]   dictionary_i,
    output logic                     match_o
);

logic [15:0] compare_vec;

generate
    genvar i;
    for (i = 0; i < WORDS; i = i + 1) begin : generate_64bit_adder
        comparator #(.N(WIDTH))comparator(.input_i(word_i),
		                                  .compare_value_i(dictionary_i[(i+1)*WIDTH - 1: i*WIDTH]),
										  .match_o(compare_vec[i]));
    end
endgenerate

assign match_o = |compare_vec; // OR-reduction of compare_vec

endmodule