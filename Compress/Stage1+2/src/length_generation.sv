module length_generation #(parameter CACHE_LINE = 128, WORD_SIZE = 64)
(
 input  logic         i_clk,
 input  logic         i_reset,
 input  logic [3:0]   i_type_matched2,
 input  logic [1:0]   i_type_matched1,
 input  logic [1:0]   i_match_s,
 output logic         o_store_flag,  
 output logic [6:0]   o_shift_amount,
 output logic         o_send_back 
);

logic [1:0] i_type_matched21, i_type_matched22;
logic       i_type_matched11, i_type_matched12;
logic       i_match_s1, i_match_s2;
logic [5:0] o_length1;
logic [5:0] o_length2;
logic [6:0] total_length;
logic [2:0] o_encoded1;
logic [2:0] o_encoded2;

assign i_type_matched21 = i_type_matched2[1:0];
assign i_type_matched22 = i_type_matched2[3:2];
assign i_type_matched11 = i_type_matched1[0];
assign i_type_matched12 = i_type_matched1[1];
assign i_match_s1 = i_match_s[0];
assign i_match_s2 = i_match_s[1];

length_accumulator #(
.CACHE_LINE(CACHE_LINE),
.WORD_SIZE(WORD_SIZE)    
) length_accumulator (
.i_clk(i_clk),
.i_reset(i_reset),      
.i_total_length(total_length), 
.o_store_flag(o_store_flag),  
.o_shift_amount(o_shift_amount),
.o_send_back(o_send_back) 
);

total_length_generator total_length_generator(
.i_word1_length(o_length1),
.i_word2_length(o_length2),
.o_total_length(total_length)
);

word_length_genetator word_length_generator1(
.i_type_matched1(i_type_matched11),
.i_match_s1(i_match_s1),
.i_type_matched2(i_type_matched21),
.o_length(o_length1),
.o_encoded(o_encoded1)
);

word_length_genetator word_length_generator2(
.i_type_matched1(i_type_matched12),
.i_match_s1(i_match_s2),
.i_type_matched2(i_type_matched22),
.o_length(o_length2),
.o_encoded(o_encoded2)
);
endmodule

