module word_length_genetator(
    input  logic        i_type_matched1,
    input  logic        i_match_s1,
    input  logic  [1:0] i_type_matched2,
    output logic  [5:0] o_length,
    output logic  [2:0] o_encoded
);

assign o_encoded[0] = ~i_match_s1 &(~i_type_matched2[0] | i_type_matched2[1]);
//assign o_encoded[1] = i_match_s1 & (i_type_matched2[1] & ~i_type_matched2[0] | ~i_type_matched1);
assign o_encoded[1] = (i_match_s1 & (~i_type_matched1) &(~i_type_matched2[0] | ~i_type_matched2[1])) | 
                      ~i_match_s1 & (~i_type_matched2[0]) & i_type_matched2[1];
assign o_encoded[2] = ~i_match_s1&~i_type_matched2[1];


always_comb begin
    case (o_encoded)
    3'b000: o_length = 6'd2;
    3'b001: o_length = 6'd6;
    3'b010: o_length = 6'd12;
    3'b011: o_length = 6'd16;
    3'b100: o_length = 6'd24;
    3'b101: o_length = 6'd34;
    default: o_length = 6'd0;
    endcase
end

endmodule