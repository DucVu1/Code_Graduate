module word_comparator#(parameter INPUT_WORD = 32, COMPARE_WORD = 32, BYTE = 8)(
 input  logic [INPUT_WORD - 1:0]   i_input,
 input  logic [COMPARE_WORD - 1:0] i_dict,
 output logic [1:0]                o_no_match,
 output logic                      o_align
);

logic [3:0] compare_vec;

//4 byte comparator
generate
 genvar i;
  for (i = 0; i < 4; i = i + 1) begin : gen_compare
   comparator #(.N(BYTE)) comparator_inst (
                .input_i(i_input[(i+1)*BYTE - 1 : i*BYTE]),
                .compare_value_i(i_dict[(i+1)*BYTE - 1 : i*BYTE]),
                .match_o(compare_vec[i])
               );
  end
endgenerate
 
word_decoder word_decoder_inst(.i_compare_vec(compare_vec), 
                               .o_match_count(o_no_match),
                               .o_align(o_align));

endmodule
