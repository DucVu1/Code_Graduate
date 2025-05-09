module comparator_array4#(parameter INPUT_WORD = 32, DICT_ENTRY = 16, DICT_WORD = 32)(
    input  logic                                   i_reset,
    input  logic [INPUT_WORD - 1 : 0]              i_input,
    input  logic [INPUT_WORD - 1 : 0]              i_first_word,
    input  logic [INPUT_WORD * DICT_ENTRY - 1 : 0] i_dict,
    input  logic                                   i_match_s1,
    output logic [1:0]                             o_type_matched,
    output logic                                   o_align,
    output logic [$clog2(DICT_ENTRY) - 1 : 0]      o_location
);
localparam WIDTH_MATCH_BYTE = 2;

logic [DICT_ENTRY * 2 - 1 : 0] no_match;
logic [DICT_ENTRY - 1: 0]      align;
logic [1:0]                    first_word_no_match;
logic                          first_word_align;
logic [1:0]                    pre_type_matched, pre_type_matched2;
logic [3:0]                    pre_location;
logic                          pre_align;

word_comparator #(.INPUT_WORD(INPUT_WORD),
                .COMPARE_WORD(DICT_WORD)) comparator_first_word (
                    .i_input(i_input),
                    .i_dict(i_first_word),
                    .o_no_match(first_word_no_match),
                    .o_align(first_word_align));
generate
 genvar i;
  for (i = 0; i < 16; i = i + 1) begin : gen_compare
   word_comparator #(.INPUT_WORD(INPUT_WORD),
                .COMPARE_WORD(DICT_WORD)) comparator_inst (
                .i_input(i_input),
                .i_dict(i_dict[(i+1)*DICT_WORD - 1 : i*DICT_WORD]),
                .o_no_match(no_match[(i+1)*2 - 1: i*2]),
                .o_align(align[i]));
  end
endgenerate

max_selector #(.WIDTH_MATCH_BYTE(WIDTH_MATCH_BYTE), .NO_WORD(DICT_ENTRY)) max_selector (
        .i_no_byte_matched(no_match),
        .i_align(align),
        .max_val(pre_type_matched),
        .max_idx(pre_location),
        .max_align(pre_align));

max2_with_index m_final (
        .i_a(first_word_no_match),
        .i_b(pre_type_matched),
        .idxA(4'd0),
        .idxB(pre_location),
        .alignA(first_word_align),
        .alignB(pre_align),
        .max_out(pre_type_matched2),
        .max_idx(o_location),
        .max_align(o_align)
    );

always_comb begin
 if (~i_reset) o_type_matched = 2'b11;
 else if((&first_word_no_match) & i_match_s1) o_type_matched = 2'b00; 
 else o_type_matched = pre_type_matched2;
end

endmodule