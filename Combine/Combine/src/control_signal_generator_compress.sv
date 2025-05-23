module control_signal_generator_compress (
    input  logic [1:0] i_type_matched2,
    input  logic       i_match_s1,
    input  logic       i_match_s3,
    input  logic [1:0] i_type_matched4,
    output logic [1:0] o_wr_control 
);

assign o_wr_control[0] = (~(i_type_matched2[0] | i_type_matched2[1]) & ~i_match_s1);
assign o_wr_control[1] = (~(i_type_matched4[0] | i_type_matched4[1]) & ~i_match_s3);

endmodule