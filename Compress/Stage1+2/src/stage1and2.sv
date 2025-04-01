module stage1and2#(
 parameter WIDTH = 64,
 parameter DICT_ENTRY = 16, 
 parameter DICT_WORD = 32, 
 parameter WORD = 32,
 parameter CACHE_LINE = 128
)
(
 input  logic               i_clk,
 input  logic               i_reset,
 input  logic [WIDTH - 1:0] i_word,
 output logic               o_store_flag,  
 output logic [6:0]         o_shift_amount,
 output logic               o_send_back,
 output logic [511:0]       dictionary_data,
 output logic [2:0]         o_encoded1,
 output logic [2:0]         o_encoded2,
 output logic [5:0]         o_length1,
 output logic [5:0]         o_length2,
 output logic [6:0]         o_total_length,
 output logic               o_fill_flag,   // Determines whether to select the padded signal
 output logic               o_output_flag, // Raised when there are 128 compressed bits in Reg2
 output logic               o_fill_ctrl,   
 output logic               o_stop_flag    // Raised when the number of compressed bits exceeds 128
);


logic [3:0]  o_location2, o_location4;
logic [3:0]  i_type_matched2, o_type_matched2;
logic [11:0] o_codeded1, o_codeded3;
logic [1:0]  i_type_matched1, o_type_matched1;
logic [1:0]  i_match_s, o_match_s;
logic        type_matched1;
logic        type_matched3;
logic        match_s1;
logic        match_s3;
logic [1:0]  type_matched2;
logic [1:0]  type_matched4;
logic        o_dict_full;

assign i_type_matched2[1:0] = type_matched2;
assign i_type_matched2[3:2] = type_matched4;
assign i_type_matched1[0]   = type_matched1;
assign i_type_matched1[1]   = type_matched3;
assign i_match_s[0]         = match_s1;
assign i_match_s[1]         = match_s3;

matching_stage #(
 .WIDTH(WIDTH),
 .DICT_ENTRY(DICT_ENTRY), 
 .DICT_WORD(DICT_WORD),
 .WORD(WORD)) 
 stage1 (
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word(i_word),
 .o_location2(o_location2),
 .o_location4(o_location4),
 .o_codeded1(o_codeded1),
 .o_codeded3(o_codeded3),
 .o_dict_full(o_dict_full),
 .type_matched1(type_matched1), //first_word
 .type_matched3(type_matched3), //second word
 .match_s1(match_s1), //first_word
 .match_s3(match_s3), //second_word
 .type_matched2(type_matched2), //first_word
 .type_matched4(type_matched4), //second_word
 .dictionary_data(dictionary_data)
);

matching_length_reg pipeline_reg(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_type_matched2(i_type_matched2),
 .i_type_matched1(i_type_matched1),
 .i_match_s(i_match_s),
 .o_type_matched2(o_type_matched2),
 .o_type_matched1(o_type_matched1),
 .o_match_s(o_match_s)
);

length_generation #(
 .CACHE_LINE(CACHE_LINE),
 .WORD_SIZE(WIDTH)
)
 stage2 (
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_type_matched2(o_type_matched2),
 .i_type_matched1(o_type_matched1),
 .i_match_s(o_match_s),
 .o_store_flag(o_store_flag),  
 .o_shift_amount(o_shift_amount),
 .o_send_back(o_send_back),
 .o_encoded1(o_encoded1),
 .o_encoded2(o_encoded2),
 .o_length1(o_length1),
 .o_length2(o_length2),
 .o_total_length(o_total_length),
 .o_fill_flag(o_fill_flag),   // Determines whether to select the padded signal
 .o_output_flag(o_output_flag), // Raised when there are 128 compressed bits in Reg2
 .o_fill_ctrl(o_fill_ctrl),   
 .o_stop_flag(o_stop_flag)    // Raised when the number of compressed bits exceeds 128 
);


endmodule