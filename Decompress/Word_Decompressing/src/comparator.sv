module comparator (
 input logic [7:0] i_len_r,
 output logic o_comp_signal
);

assign o_comp_signal = (i_len_r < 7'd68) ? 1'b1 : 1'b0;

endmodule : comparator