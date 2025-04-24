module three_input_carry_save_adder #(
    parameter WORD_LENGTH = 6,
    parameter REMAIN_LENGTH = 8,
    parameter RESULT_LENGTH = 7
)
(
 input logic [WORD_LENGTH - 1 : 0] i_first_len,
 input logic [WORD_LENGTH - 1 : 0] i_second_len,
 input logic [REMAIN_LENGTH - 1 : 0] i_remain_len, // number of remaining bits in reg_array1
 output logic [RESULT_LENGTH - 1 :0] o_len_r
);
logic [REMAIN_LENGTH - 1 : 0] temp_value;
assign temp_value = i_remain_len - (i_first_len + i_second_len);
assign o_len_r = temp_value[6:0];

endmodule