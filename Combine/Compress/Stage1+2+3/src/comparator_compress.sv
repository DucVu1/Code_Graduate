module comparator_compress#(parameter N = 32) (
    input  logic [N -1 : 0]  input_i,
    input  logic [N - 1 : 0] compare_value_i,
    output logic             match_o
);
assign match_o = &(input_i ~^ compare_value_i);
endmodule