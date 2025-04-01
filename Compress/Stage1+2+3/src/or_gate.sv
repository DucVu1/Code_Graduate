module or_gate #(
 parameter I_WIDTH1 = 68,
 parameter I_WIDTH2 = 34,
 parameter TOTAL_WIDTH = 136
)
(
 input logic [I_WIDTH1 - 1 : 0] i_first_word,
 input logic [I_WIDTH2 - 1 : 0] i_second_word,
 input logic [TOTAL_WIDTH - 1 : 0] i_reg_array,
 output logic [TOTAL_WIDTH - 1 :0] o_word
);

assign o_word = {i_reg_array[TOTAL_WIDTH-1:68], 
                         ({i_second_word | i_first_word[67:34], i_first_word[33:0]} | i_reg_array[67:0])};

endmodule