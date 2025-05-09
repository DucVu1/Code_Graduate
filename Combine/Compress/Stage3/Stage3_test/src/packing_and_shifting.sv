can you design for me
module packing_and_shifting #(
    parameter TOTAL_WIDTH           = 136,
    parameter TOTAL_BITS_COMPRESSED = 34,
    parameter CACHE_LINE            = 64,
    parameter WORD_WIDTH            = 32,
    parameter SHIFT_WIDTH           = 68,
    parameter WORD2_LENGTH          = 6,
    parameter TOTAL_LENGTH          = 7,
    parameter DICT_WORD             = 16,
    parameter OUT_SHIFT_BIT         = 7
)
(
    input logic                                 i_clk,
    input logic                                 i_reset,
    input logic                                 i_store_flag,
    input logic                                 i_output_flag,
    input logic                                 i_fill_flag,
    input logic                                 i_stop_flag, //number of compressed bits has exceed the uncompressed line size
    input logic [2:0]                           i_code1,
    input logic [2:0]                           i_code2,
    input logic [TOTAL_LENGTH - 1 :  0]         i_total_length,
    input logic [OUT_SHIFT_BIT - 1 : 0]         i_out_shift,
    input logic [WORD2_LENGTH - 1 : 0]          i_word2_length,
    input logic [WORD_WIDTH - 1 :0]             i_word1,
    input logic [WORD_WIDTH - 1 :0]             i_word2,
    input logic [CACHE_LINE * 2 - 1 :0]         i_backup_buffer,
    input logic [DICT_WORD * WORD_WIDTH - 1 :0] i_dict,
    input logic [$clog2(DICT_WORD) - 1 :0]      i_idx1,
    input logic [$clog2(DICT_WORD) - 1 :0]      i_idx2

);
 
logic [TOTAL_BITS_COMPRESSED - 1 :0]   o_compressed_word1;
logic [TOTAL_BITS_COMPRESSED - 1 :0]   o_compressed_word2;
logic [TOTAL_BITS_COMPRESSED*2 - 1 :0] o_shifted; 
logic [TOTAL_WIDTH - 1 :0]             o_or_gate;
logic [TOTAL_WIDTH - 1 :0]             o_reg_array1;
logic [TOTAL_WIDTH - 1 :0]             o_barrel2_shifted;
logic [CACHE_LINE*2 - 1 :0]            o_barrel3_shifted;
logic [CACHE_LINE*2 - 1 :0]            shifted_and_or;
logic [CACHE_LINE*2 - 1 :0]            o_reg_array2;
logic [CACHE_LINE*2 - 1 :0]            o_mux_array1;
logic [CACHE_LINE*2 - 1 :0]            o_mux_array3;
logic [CACHE_LINE*2 - 1 :0]            o_latch;

code_concatenator #(
.DATA_WIDTH(WORD_WIDTH),
.TOTAL_BITS(TOTAL_BITS_COMPRESSED),
.TOTAL_WORDS(DICT_WORD)
) code_concatenator1 (
.i_dict_idx(i_idx1), 
.i_code(i_code1),     
.i_word(i_word1),     
.i_dict(i_dict),     
.o_compressed_word(o_compressed_word1)
);

code_concatenator #(
.DATA_WIDTH(WORD_WIDTH),
.TOTAL_BITS(TOTAL_BITS_COMPRESSED),
.TOTAL_WORDS(DICT_WORD)
) code_concatenator2 (
.i_dict_idx(i_idx2), 
.i_code(i_code2),     
.i_word(i_word2),     
.i_dict(i_dict),     
.o_compressed_word(o_compressed_word2)
);

//shift right
barrel_shifter_1 #(
.WIDTH(TOTAL_BITS_COMPRESSED * 2),
.SHIFT_BIT(WORD2_LENGTH) 
) barrel_shifter1 (
 .data(o_compressed_word1),
 .type_shift(1'b0),
 .amt(i_word2_length),
 .out(o_shifted)
);

or_gate #(
.I_WIDTH1(SHIFT_WIDTH),
.I_WIDTH2(TOTAL_BITS_COMPRESSED),
.TOTAL_WIDTH(TOTAL_WIDTH)
) or_gate (
.i_first_word(o_shifted),
.i_second_word(o_compressed_word2),
.i_reg_array(o_reg_array1),
.o_word(o_or_gate)
);

register_array #(
 .TOTAL_WIDTH(TOTAL_WIDTH)
) reg_array1
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(o_or_gate),
 .o_word(o_reg_array1)
);

//shift_left
barrel_shifter_2 #(
 .TOTAL_LENGTH(TOTAL_LENGTH),
 .WIDTH(TOTAL_WIDTH)
) barrel_shifter_2 (
 .i_word(o_or_gate),
 .i_amt(i_total_length),
 .o_word(o_barrel2_shifted)
);

barrel_shifter_3 #(
 .TOTAL_LENGTH(OUT_SHIFT_BIT),
 .WIDTH(TOTAL_WIDTH),
 .O_WIDTH(CACHE_LINE)
) barrel_shifter_3(
 .i_word(o_reg_array1),
 .i_amt(i_out_shift),
 .o_word(o_barrel3_shifted)
);

asssign shifted_and_or = o_barrel3_shifted | o_reg_array2;

mux2_1#(
 .N(CACHE_LINE * 2)
) multiplexer_array1
(
 .i_a(shifted_and_or),
 .i_b(o_reg_array2),
 .i_option(i_store_flag),
 .o_word(o_mux_array1)
);

register_array #(
 .TOTAL_WIDTH(TOTAL_WIDTH)
) reg_array2
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(o_mux_array1),
 .o_word(o_reg_array2)
);

latch #(
 .WIDTH(CACHE_LINE * 2),
) latch
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_enable(i_output_flag),
    .i_word(o_reg_array2),
    .o_word(o_latch)
);

mux2_1#(
 .N(CACHE_LINE * 2)
) multiplexer_array3
(
 .i_a(o_latch),
 .i_b(o_reg_array2), //fill_data
 .i_option(i_fill_flag),
 .o_word(o_mux_array3)
);

mux2_1#(
 .N(CACHE_LINE * 2)
) multiplexer_array2
(
 .i_a(o_mux_array3),
 .i_b(128'd0), //fill_data
 .i_option(i_stop_flag),
 .o_word(o_mux_array2)
);

endmodule