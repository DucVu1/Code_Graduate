module stage1and2and3 #(
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
 parameter OUT_SHIFT_BIT         = 7
)
(
 input  logic                     i_clk,
 input  logic                     i_reset,
 input  logic [WIDTH - 1:0]       i_word,
 output logic [CACHE_LINE - 1 :0] o_mux_array2,
 output logic                     o_finish_final,
 output logic [DICT_WORD * DICT_ENTRY - 1 :0] dictionary_data
);
 logic               i_finish_final;
 logic               i_push_flag, o_push_flag;
 logic               o_done_flag, i_done_flag;
 logic               i_store_flag, o_store_flag; 
 logic [7:0]         i_shift_amount, o_shift_amount;
 logic [7:0]         i_push_amount, o_push_amount;
 logic [3:0]         i_location2, i_location4;
 logic [3:0]         o_location2, o_location4;
 logic               i_send_back,o_send_back;
 //logic [511:0]       dictionary_data;
 logic [2:0]         i_encoded1, o_encoded1;
 logic [2:0]         i_encoded2, o_encoded2;
 logic [5:0]         i_length1, o_length1;
 logic [5:0]         i_length2, o_length2;
 logic [6:0]         i_total_length, o_total_length;
 logic               i_fill_flag, o_fill_flag;   // Determines whether to select the padded signal
 logic               i_output_flag, o_output_flag; // Raised when there are 128 compressed bits in Reg2
 logic               i_fill_ctrl, o_fill_ctrl;   
 logic               i_stop_flag, o_stop_flag;    // Raised when the number of compressed bits exceeds 128
 logic [WIDTH - 1:0] i_reg_word, o_word;
 logic [DICT_WORD - 1 : 0] i_word1, i_word2;
 logic [CACHE_LINE - 1 :0] o_backup_buffer3;
 logic [WIDTH - 1 :0] o_backup_buffer2;
 logic [WIDTH - 1 :0] o_backup_buffer;

 assign i_word1 = o_word[31:0];
 assign i_word2 = o_word[63:32];

register_array #(
 .TOTAL_WIDTH(WIDTH)
) pipeline_reg_for_backup_buffer1
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(i_word),
 .o_word(o_backup_buffer)
);

register_array #(
 .TOTAL_WIDTH(WIDTH)
) pipeline_reg_for_backup_buffer2
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(o_backup_buffer),
 .o_word(o_backup_buffer2)
);

backup_buffer #(
 .WIDTH(CACHE_LINE),
 .WORD_WIDTH(WIDTH)
) backup_buffer
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(o_backup_buffer),
 .o_backup_buffer(o_backup_buffer3)
);

stage1and2#(
 .WIDTH(WIDTH),
 .DICT_ENTRY(DICT_ENTRY), 
 .DICT_WORD(DICT_WORD), 
 .WORD(WORD),
 .CACHE_LINE(CACHE_LINE)
) stage1and2
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(i_word),
 .o_store_flag(i_store_flag),  
 .o_shift_amount(i_shift_amount),
//  .o_send_back(i_send_back),
 .dictionary_data(dictionary_data),
 .o_encoded1(i_encoded1),
 .o_encoded2(i_encoded2),
 .o_length1(i_length1),
 .o_length2(i_length2),
 .o_total_length(i_total_length),
 .o_fill_flag(i_fill_flag),   // Determines whether to select the padded signal
 .o_output_flag(i_output_flag), // Raised when there are 128 compressed bits in Reg2
 .o_fill_ctrl(i_fill_ctrl),   
 .o_stop_flag(i_stop_flag),    // Raised when the number of compressed bits exceeds 128
 .o_word(i_reg_word),
 .o_done_flag(i_done_flag),
 .o_push_flag(i_push_flag),
 .o_finish_final(i_finish_final),
 .o_location2(i_location2),
 .o_location4(i_location4)
 //.o_push_amount(i_push_amount)
);


length_packing_reg #(
 .WIDTH(WIDTH)
) pipeline_reg (
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_store_flag(i_store_flag),  
 .i_shift_amount(i_shift_amount),
 .i_done_flag(i_done_flag),
 .i_finish_final(i_finish_final),
//  .i_send_back(i_send_back),
 .i_encoded1(i_encoded1),
 .i_encoded2(i_encoded2),
 .i_length1(i_length1),
 .i_length2(i_length2),
 .i_location2(i_location2),
 .i_location4(i_location4),
 .i_total_length(i_total_length),
 //.i_push_amount(i_push_amount),
 .i_fill_flag(i_fill_flag),   // Determines whether to select the padded signal
 .i_output_flag(i_output_flag), // Raised when there are 128 compressed bits in Reg2
 .i_fill_ctrl(i_fill_ctrl),   
 .i_push_flag(i_push_flag),
 .i_stop_flag(i_stop_flag),    // Raised when the number of compressed bits exceeds 128
 .i_word(i_reg_word),
 .o_store_flag(o_store_flag),  
 .o_shift_amount(o_shift_amount),
//  .o_send_back(o_send_back),
 .o_done_flag(o_done_flag),
 .o_encoded1(o_encoded1),
 .o_encoded2(o_encoded2),
 .o_length1(o_length1),
 .o_length2(o_length2),
 //.o_push_amount(o_push_amount), 
 .o_location2(o_location2),
 .o_location4(o_location4),
 .o_total_length(o_total_length),
 .o_fill_flag(o_fill_flag),   // Determines whether to select the padded signal
 .o_output_flag(o_output_flag), // Raised when there are 128 compressed bits in Reg2
 .o_fill_ctrl(o_fill_ctrl),   
 .o_stop_flag(o_stop_flag),    // Raised when the number of compressed bits exceeds 128
 .o_finish_final(o_finish_final),
 .o_push_flag(o_push_flag),
 .o_word(o_word)
);


packing_and_shifting #(
 .TOTAL_WIDTH(TOTAL_WIDTH) ,
 .TOTAL_BITS_COMPRESSED(TOTAL_BITS_COMPRESSED),
 .CACHE_LINE(WIDTH),
 .WORD_WIDTH(DICT_WORD),
 .SHIFT_WIDTH(TOTAL_BITS_COMPRESSED*2) ,
 .WORD2_LENGTH(WORD2_LENGTH),
 .TOTAL_LENGTH (TOTAL_LENGTH),
 .DICT_WORD(DICT_WORD2),
 .OUT_SHIFT_BIT(OUT_SHIFT_BIT)
) stage3
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_store_flag(o_store_flag),
 .i_output_flag(o_output_flag),
 .i_push_flag(o_push_flag),
 //.i_push_amount(o_push_amount),
 .i_fill_flag(o_fill_flag),
 .i_stop_flag(o_stop_flag), //number of compressed bits has exceed the uncompressed line size
 .i_code1(o_encoded1),
 .i_code2(o_encoded2),
 .i_total_length(o_total_length),
 .i_out_shift(o_shift_amount),
 .i_word2_length(o_length1),
 .i_word1(i_word1),
 .i_word2(i_word2),
 .i_backup_buffer(o_backup_buffer3),
 .i_idx1(o_location2),
 .i_idx2(o_location4),
 .o_mux_array2(o_mux_array2)

);
 
// packing_and_shifting #(
//  .TOTAL_WIDTH(TOTAL_WIDTH) ,
//  .TOTAL_BITS_COMPRESSED(TOTAL_BITS_COMPRESSED),
//  .CACHE_LINE(WIDTH),
//  .WORD_WIDTH(DICT_WORD),
//  .SHIFT_WIDTH(TOTAL_BITS_COMPRESSED*2) ,
//  .WORD2_LENGTH(WORD2_LENGTH),
//  .TOTAL_LENGTH (TOTAL_LENGTH),
//  .DICT_WORD(DICT_WORD2),
//  .OUT_SHIFT_BIT(OUT_SHIFT_BIT)
// ) stage3
// (
//  .i_clk(i_clk),
//  .i_reset(i_reset),
//  .i_store_flag(i_store_flag),
//  .i_output_flag(i_output_flag),
//  .i_fill_flag(i_fill_flag),
//  .i_stop_flag(i_stop_flag), //number of compressed bits has exceed the uncompressed line size
//  .i_code1(i_encoded1),
//  .i_code2(i_encoded2),
//  .i_total_length(i_total_length),
//  .i_out_shift(i_shift_amount),
//  .i_word2_length(i_length1),
//  .i_word1(i_word1),
//  .i_word2(i_word2),
//  .i_backup_buffer(o_backup_buffer3),
//  .i_idx1(i_location2),
//  .i_idx2(i_location4),
//  .o_mux_array2(o_mux_array2)

// );






endmodule