module matching_stage #(parameter WIDTH = 64, DICT_ENTRY = 16, DICT_WORD = 32, WORD = 32) (
 input  logic               i_clk,
 input  logic               i_reset,
 input  logic [WIDTH - 1:0] i_word,
 output logic [3:0]         o_location2,
 output logic [3:0]         o_location4,
 output logic [11:0]        o_codeded1,
 output logic [11:0]        o_codeded3,
 output logic               type_matched1, //first_word
 output logic               type_matched3, //second word
 output logic               match_s1, //first_word
 output logic               match_s3, //second_word
 
 output logic [1:0]         type_matched2, //first_word
 output logic [1:0]         type_matched4, //second_word
 //fifo_dict
 output logic [1:0]         fifo_wr_signal,
 output logic [31:0]        first_word,
 output logic [31:0]        second_word,
 input  logic [511:0]       dictionary_data
);

logic         align2;
logic         align4;



assign first_word  = i_word[31:0];
assign second_word = i_word[63:32];

//First Word
comparator_array2 #(.INPUT_WORD(WORD), .DICT_ENTRY(DICT_ENTRY), .DICT_WORD(DICT_WORD)) comparator_array2(
                    .i_reset(i_reset),
                    .i_input(first_word),
                    .i_dict(dictionary_data),
                    .o_type_matched(type_matched2),
                    .o_align(align2),
                    .o_location(o_location2)
);

comparator_array1 #(.WIDTH(WORD)) comparator_array1 (
                    .i_reset(i_reset),
                    .i_word(first_word),
                    .o_type_matched(type_matched1),
                    .o_match_s(match_s1),
                    .o_code(o_codeded1)
);

//Second Word
comparator_array4 #(.INPUT_WORD(WORD), .DICT_ENTRY(DICT_ENTRY), .DICT_WORD(DICT_WORD)) comparator_array4(
                    .i_reset(i_reset),
                    .i_input(second_word),
                    .i_first_word(first_word),
                    .i_match_s1(match_s1),
                    .i_dict(dictionary_data),
                    .o_type_matched(type_matched4),
                    .o_align(align4),
                    .o_location(o_location4)
);

comparator_array1 #(.WIDTH(WORD)) comparator_array3 (
                    .i_reset(i_reset),
                    .i_word(second_word),
                    .o_type_matched(type_matched3),
                    .o_match_s(match_s3),
                    .o_code(o_codeded3)
);



//Dictionary

// fifo_dict #(.DATA_WIDTH(WORD), .TOTAL_WORDS(DICT_ENTRY)) dictionary (
//             .i_clk(i_clk),
//             .i_reset(i_reset),
//             .wr(fifo_wr_signal[0]),
//             .wr2(fifo_wr_signal[1]),
//             .w_data(first_word),
//             .w_data2(second_word),
//             .o_data(dictionary_data)
// );

//control_signal_generator
control_signal_generator_compress control_signal_generator (
    .i_match_s1(match_s1),
    .i_match_s3(match_s3),
    .i_type_matched2(type_matched2),
    .i_type_matched4(type_matched4),
    .o_wr_control(fifo_wr_signal) 
);
//word_length_generator first_word
/*word_length_genetator word_length_generator1(
    .i_type_matched1(type_matched1),
    .i_match_s1(match_s1),
    .i_type_matched2(type_matched2),
    .o_length(o_length1),
    .o_encoded(o_code1)
);

word_length_genetator word_length_generator2(
    .i_type_matched1(type_matched3),
    .i_match_s1(match_s3),
    .i_type_matched2(type_matched4),
    .o_length(o_length2),
    .o_encoded(o_code2)
);*/

endmodule

