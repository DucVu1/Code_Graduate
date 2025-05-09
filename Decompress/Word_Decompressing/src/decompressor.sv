module decompressor #(
 parameter WIDTH_DATA_IN = 128,
 parameter INPUT_LENGTH = 9,
 parameter WORD  = 16,
 parameter WIDTH = 32,
 parameter I_WORD = 196,
 parameter I_WORD2 = 34,
 parameter LENGTH_CODE = 2,
 parameter LENGTH = 6,
 parameter REMAIN_LENGTH = 8,
 parameter RESULT_LENGTH = 7
) 
(
 input  logic                         i_clk,
 input  logic                         i_decompressor_en,
 input  logic                         i_reset,
 input  logic                         i_update,
 input  logic                         i_comp_flag,
 input  logic [WIDTH_DATA_IN - 1 : 0] i_data,
 output logic [WIDTH_DATA_IN - 1 : 0] o_data
);

logic [LENGTH_CODE - 1 : 0]  o_first_code;
logic [LENGTH_CODE - 1 : 0]  o_first_code_bak;
logic [LENGTH_CODE - 1 : 0]  o_second_code;
logic [LENGTH_CODE - 1 : 0]  o_second_code_bak;
logic [I_WORD2 - 1 : 0]      i_compressed_word1, i_compressed_word2;
logic [$clog2(WORD) - 1 :0]  o_idx1, o_idx2;
logic [LENGTH - 1 : 0]       o_first_length, o_second_length;
logic [WORD * WIDTH - 1 :0]  dictionary_data;
logic [WIDTH - 1 : 0]        first_word;
logic [WIDTH - 1 : 0]        second_word;
logic [REMAIN_LENGTH - 1 : 0]o_remain_length;
logic [REMAIN_LENGTH - 1 : 0]o_remain_length_n;
logic [RESULT_LENGTH - 1 : 0]o_len_r;
logic [RESULT_LENGTH - 1 : 0]o_mux_1;
logic [LENGTH_CODE - 1 : 0]  ctrl_signal;
logic [I_WORD - 1 : 0]       o_barrel_shifter2; 
logic [I_WORD - 1 : 0]       o_barrel_shifter1; 
logic [I_WORD - 1 : 0]       o_or_gate; 
logic [I_WORD - 1 : 0]       reg_array1_out; 
logic [WIDTH_DATA_IN - 1 : 0]o_reg_array3;
logic [WIDTH_DATA_IN - 1 : 0]o_latch; 
logic [I_WORD - 1 : 0]       o_mux_2; 
logic                        o_comp_signal;
logic                        latch_en;
logic [$clog2(WIDTH_DATA_IN)-1:0]    o_total_length_n;

logic [I_WORD - 1 : 0]       i_decoder2;
logic mux2_sel;

assign i_decoder2 = reg_array1_out >> o_first_length;

logic o_comp_signal_r;

always_ff @(posedge i_clk or negedge i_reset) begin
   if (~i_reset) begin
     o_comp_signal_r <= '0;
   end else begin
     o_comp_signal_r <= o_comp_signal;
   end
 end
assign mux2_sel = i_update | o_comp_signal;
unpacker #(
 .WIDTH(WIDTH_DATA_IN), //128 i_data, log o_remain_length/total_length
 .CODE(LENGTH_CODE), //2
 .WORD(WORD), //16
 .LENGTH(LENGTH)) // 6
unpacker
(
 .i_clk(i_clk),
 .i_decompressor_en(i_decompressor_en),
 .i_reset(i_reset),
 .i_update(o_comp_signal_r),
 .i_data(o_mux_2),
 .o_first_code(o_first_code),
 .o_first_code_bak(o_first_code_bak),
 .o_idx1(o_idx1),
 .o_second_code(o_second_code),
 .o_second_code_bak(o_second_code_bak),
 .o_idx2(o_idx2),
 .o_first_length(o_first_length),
 .o_second_length(o_second_length),
 .o_remain_length(o_remain_length),
 .o_total_length_n(o_total_length_n),
 .o_remain_length_n(o_remain_length_n)
);

control_signal_generator control_signal_gen (
 .i_first_code(o_first_code),
 .i_first_code_bak(o_first_code_bak),
 .i_second_code(o_second_code),
 .i_second_code_bak(o_second_code_bak),
 .ctrl_signal(ctrl_signal)
);  

fifo_dict #(.DATA_WIDTH(WIDTH),
            .TOTAL_WORDS(WORD)
) dictionary 
(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .wr(ctrl_signal[0]),
 .wr2(ctrl_signal[1]),
 .w_data(first_word),
 .w_data2(second_word),
 .o_data(dictionary_data)
);

decoder #(
 .CODES(LENGTH_CODE), //2
 .WORD(WORD), //16
 .WIDTH(WIDTH), //32
 .I_WORD(I_WORD), //196
 .I_WORD2(I_WORD2) //34
) decoder1
(
 .i_codes(o_first_code),
 .i_codes_bak(o_first_code_bak),
 .i_word(reg_array1_out), //assume, evertime we input a 196 bit compressed word
 .i_idx(o_idx1),
 .i_dict(dictionary_data),
 .o_word(first_word)
);

decoder #(
 .CODES(LENGTH_CODE), //2
 .WORD(WORD), //16 
 .WIDTH(WIDTH), //32 
 .I_WORD(I_WORD), // 196
 .I_WORD2(I_WORD2) //34
) decoder2
(
 .i_codes(o_second_code),
 .i_codes_bak(o_second_code_bak),
 .i_word(i_decoder2), 
 .i_idx(o_idx2),
 .i_dict(dictionary_data),
 .o_word(second_word)
);

reg_out #(
 .WIDTH(WIDTH), // 32
 .O_WIDTH(WIDTH_DATA_IN) // 128
)register_array3(
 .i_clk(i_clk),
 .i_reset(i_reset),
 .i_word1(first_word),
 .i_word2(second_word),
 .o_word(o_reg_array3),
 .o_count(latch_en)
);

latch_module #(
 .WIDTH(WIDTH_DATA_IN) //128
) latch_module
(
 .i_reset(i_reset),
 .i_enable(latch_en),
 .i_word(o_reg_array3),
 .o_word(o_latch)
);


three_input_carry_save_adder #(
 .WORD_LENGTH(LENGTH), //6
 .REMAIN_LENGTH(REMAIN_LENGTH), //8
 .RESULT_LENGTH(RESULT_LENGTH) //7
) carry_save_adder
(
 .i_first_len(o_first_length),
 .i_second_len(o_second_length),
 .i_remain_len(o_remain_length), // number of remaining bits in reg_array1
 .o_len_r(o_len_r)
);

comparator substracter(
 .i_len_r(o_remain_length_n),
 .o_comp_signal(o_comp_signal) // 1 if o_len_r < 7'd68, else 0
);

mux2_1 #(
 .N(RESULT_LENGTH)) //7
mux1 (
 .i_option(o_comp_signal),
 .i_a(7'd0),
 .i_b(o_len_r),
 .o_word(o_mux_1)
);
//shift_left
barrel_shifter_d2 #(
 .WIDTH(I_WORD), //196
 .I_WIDTH(WIDTH_DATA_IN), //128
 .SHIFT_BIT(RESULT_LENGTH) //7
) barrel_shifter2 (
 .i_word(i_data),
 .i_amt(o_mux_1),
 .o_word(o_barrel_shifter2)
);

or_gate_d #(
 .WIDTH(I_WORD)) //196
 or_gate( 
 .i_first_word(o_barrel_shifter2),
 .i_second_word(o_barrel_shifter1), 
 .o_word(o_or_gate)
);

mux2_1 #(
 .N(I_WORD))
mux2 (  // select between currently shifted data and additional data
 .i_option(mux2_sel),
 .i_a(o_barrel_shifter1),
 .i_b(o_or_gate),
 .o_word(o_mux_2)
);

//shift_right
// barrel_shifter_d1 #(
//  .WIDTH(WIDTH_DATA_IN), //196
//  .I_WIDTH(WIDTH_DATA_IN) //128
// ) barrel_shifter1 (
//  .i_word(reg_array1_out),
//  .i_amt(o_total_length_n),
//  .o_word(o_barrel_shifter1)
// );

barrel_shifter_right #(
 .WIDTH(I_WORD)
) barrel_shifter1
(
 .i_data(reg_array1_out),
 .i_amt(o_total_length_n),        
 .o_data(o_barrel_shifter1)
); 
register_array #(
 .TOTAL_WIDTH(I_WORD))
register_array1 (
 .i_clk(i_clk),
 .i_reset(i_reset),  
 .i_word(o_mux_2),
 .o_word(reg_array1_out)
);

mux2_1 #(
 .N(WIDTH_DATA_IN)) //128
mux_out (  // select between currently shifted data and additional data
 .i_option(i_comp_flag),
 .i_a(i_data),
 .i_b(o_latch),
 .o_word(o_data)
);
endmodule