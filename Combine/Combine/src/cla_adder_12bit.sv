module cla_adder_12bit #(
    parameter I_WIDTH = 6,
    parameter O_WIDTH = 7
)

(
 input logic [I_WIDTH  - 1 : 0] i_first_len,
 input logic [I_WIDTH  - 1 : 0] i_second_len,
 output logic [O_WIDTH - 1 : 0] o_total_len
);

assign o_total_len = i_first_len + i_second_len;



endmodule