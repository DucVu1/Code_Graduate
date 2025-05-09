module compressor_decompressor #(
 parameter WIDTH                 = 64,
 parameter DICT_ENTRY            = 16, 
 parameter DICT_WORD             = 32, 
 parameter WORD                  = 32,
 parameter CACHE_LINE            = 128,
 parameter TOTAL_WIDTH           = 136,
 parameter TOTAL_BITS_COMPRESSED = 34,
 parameter WORD2_LENGTH          = 6,
 parameter TOTAL_LENGTH          = 7,
 parameter DICT_WORD2            = 16,
 parameter OUT_SHIFT_BIT         = 7,
 parameter INPUT_LENGTH          = 9,
 parameter I_WORD                = 196,
 parameter LENGTH_CODE           = 2,
 parameter REMAIN_LENGTH         = 8
) (
 input  logic i_clk,
 input  logic i_reset,
 input  logic i_update_d,
 input  logic i_decompressor_en,
 input  logic i_compressor_en,
 input  logic i_compressed_flag,
 input  logic [WIDTH - 1:0]       i_word_c,
 input  logic [CACHE_LINE - 1 : 0] i_word_d,
 output logic [CACHE_LINE - 1 : 0] o_compressed_word,
 output logic [CACHE_LINE - 1 : 0] o_decompressed_word,
 output logic                      o_compressed_flag,
 output logic                      o_finish_c_flag
);

logic [1:0]   fifo_wr_signal, fifo_wr_signal_d;
logic [31:0]  first_word, second_word, third_word, fourth_word;
logic [511:0] dictionary_data;

stage1and2and3 #(
 .WIDTH(WIDTH),
 .DICT_ENTRY(DICT_ENTRY), 
 .DICT_WORD(DICT_WORD), 
 .WORD(WORD),
 .CACHE_LINE(CACHE_LINE),
 .TOTAL_WIDTH(TOTAL_WIDTH),
 .TOTAL_BITS_COMPRESSED(TOTAL_BITS_COMPRESSED),
 .WORD2_LENGTH(WORD2_LENGTH),
 .TOTAL_LENGTH(TOTAL_LENGTH),
 .DICT_WORD2(DICT_WORD2),
 .OUT_SHIFT_BIT(OUT_SHIFT_BIT)       
) compressor
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(i_word_c),
 .i_compressor_en(i_compressor_en),
 .o_mux_array2(o_compressed_word),
 .o_finish_final(o_finish_c_flag),
 .o_compressed_flag(o_compressed_flag),
 .fifo_wr_signal(fifo_wr_signal),
 .first_word(first_word),
 .second_word(second_word),
 .dictionary_data(dictionary_data)
);

decompressor #(
  .WIDTH_DATA_IN(CACHE_LINE),
  .INPUT_LENGTH(INPUT_LENGTH),
  .WORD(DICT_ENTRY),
  .WIDTH(WORD),
  .I_WORD(I_WORD),
  .I_WORD2(TOTAL_BITS_COMPRESSED),
  .LENGTH_CODE(LENGTH_CODE),
  .LENGTH(WORD2_LENGTH),
  .REMAIN_LENGTH(REMAIN_LENGTH),
  .RESULT_LENGTH(OUT_SHIFT_BIT) 
) decompressor
(
 .i_clk(i_clk),
 .i_decompressor_en(i_decompressor_en),
 .i_reset(i_reset),
 .i_update(i_update_d),
 .i_comp_flag(i_compressed_flag),
 .i_data(i_word_d),
 .o_data(o_decompressed_word),
 .ctrl_signal(fifo_wr_signal_d),
 .first_word(third_word),
 .second_word(fourth_word),
 .dictionary_data(dictionary_data)
);


fifo_dict #(.DATA_WIDTH(WORD), .TOTAL_WORDS(DICT_ENTRY)) dictionary (
            .i_clk(i_clk),
            .i_reset(i_reset),
            .wr(fifo_wr_signal[0]),
            .wr2(fifo_wr_signal[1]),
            .wr3(fifo_wr_signal_d[0]),
            .wr4(fifo_wr_signal_d[1]),
            .w_data(first_word),
            .w_data2(second_word),
            .w_data3(third_word),
            .w_data4(fourth_word),
            .o_data(dictionary_data)
);
endmodule
