module comparator_array2#(parameter INPUT_WORD = 32, DICT_ENTRY = 16, DICT_WORD = 32)(
    input  logic [INPUT_WORD - 1 : 0]              i_input,
    input  logic [INPUT_WORD * DICT_ENTRY - 1 : 0] i_dict,
    output logic [1:0]                             o_type_matched, //11 = full word, 10 = 3 byte, 01 = 2 byte
    output logic                                   o_align,
    output logic [$clog2(DICT_ENTRY) - 1 : 0]      o_location
);
localparam WIDTH_MATCH_BYTE = 2;

logic [DICT_ENTRY * 2 - 1 : 0] no_match;
logic [DICT_ENTRY - 1: 0] align;

//logic [1:0]               max_val;
 
generate
 genvar i;
  for (i = 0; i < 16; i = i + 1) begin : gen_compare
   word_comparator #(.INPUT_WORD(INPUT_WORD),
                .COMPARE_WORD(DICT_WORD)) comparator_inst (
                .i_input(i_input),
                .i_dict(i_dict[(i+1)*DICT_WORD - 1 : i*DICT_WORD]),
                .o_no_match(no_match[(i+1)*2 - 1: i*2]),
                .o_align(align[i])
               );
  end
endgenerate

//selecting the block with highest match
  max_selector #(.WIDTH_MATCH_BYTE(WIDTH_MATCH_BYTE), .NO_WORD(DICT_ENTRY)) max_selector (
        .i_no_byte_matched(no_match),
        .i_align(align),
        .max_val(o_type_matched),
        .max_idx(o_location),
        .max_align(o_align)
    );


endmodule