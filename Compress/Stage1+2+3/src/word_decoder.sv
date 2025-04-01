module word_decoder (
    input  logic [3:0] i_compare_vec,  // 4-bit compare vector (one bit per byte)
    output logic [1:0] o_match_count,  // Number of matched bytes (0 to 4)
    output logic       o_align       // 1 if ones are contiguous, 0 otherwise
);
    always_comb begin
        case (i_compare_vec)
            4'b0000: begin //xxxx
                o_match_count = 2'd0;
                o_align     = 1'b0;
            end
            4'b1100: begin //mmxx
                o_match_count = 2'd1; //matched_type also
                o_align     = 1'b1;
            end
            4'b1110: begin
                o_match_count = 2'd2; //matched_type also 
                o_align     = 1'b1;
            end
            4'b1111: begin //mmmm
                o_match_count = 2'd3; // matched_type also
                o_align     = 1'b1;
            end
            default: begin
                o_match_count = 2'd0;
                o_align     = 1'b0;
            end
        endcase
    end
endmodule
