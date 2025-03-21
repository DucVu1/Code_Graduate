module word_decoder (
    input  logic [3:0] i_compare_vec,  // 4-bit compare vector (one bit per byte)
    output logic [1:0] o_match_count,  // Number of matched bytes (0 to 4)
    output logic       o_align       // 1 if ones are contiguous, 0 otherwise
);
    always_comb begin
        case (i_compare_vec)
            4'b0000: begin
                o_match_count = 2'd0;
                o_align     = 1'b0;
            end
            4'b0001: begin
                o_match_count = 2'd0;
                o_align     = 1'b1;
            end
            4'b0010: begin
                o_match_count = 2'd0;
                o_align     = 1'b1;
            end
            4'b0100: begin
                o_match_count = 2'd0;
                o_align     = 1'b1;
            end
            4'b1000: begin
                o_match_count = 2'd0;
                o_align     = 1'b1;
            end
            4'b0011: begin
                o_match_count = 2'd1;
                o_align     = 1'b1; // contiguous: bits 0 & 1
            end
            4'b0110: begin
                o_match_count = 2'd1;
                o_align     = 1'b1; // contiguous: bits 1 & 2
            end
            4'b1100: begin
                o_match_count = 2'd1;
                o_align     = 1'b1; // contiguous: bits 2 & 3
            end
            4'b0101: begin
                o_match_count = 2'd1;
                o_align     = 1'b0; // noncontiguous: bits 0 & 2
            end
            4'b1010: begin
                o_match_count = 2'd1;
                o_align     = 1'b0; // noncontiguous: bits 1 & 3
            end
            4'b1001: begin
                o_match_count = 2'd1;
                o_align     = 1'b0; // noncontiguous: bits 0 & 3
            end
            4'b0111: begin
                o_match_count = 2'd2;
                o_align     = 1'b1; // contiguous: bits 0,1,2
            end
            4'b1110: begin
                o_match_count = 2'd2;
                o_align     = 1'b1; // contiguous: bits 1,2,3
            end
            4'b1011: begin
                o_match_count = 2'd2;
                o_align     = 1'b0; // noncontiguous: bits 0,1,3
            end
            4'b1101: begin
                o_match_count = 2'd2;
                o_align     = 1'b0; // noncontiguous: bits 0,2,3
            end
            4'b1111: begin
                o_match_count = 2'd3;
                o_align     = 1'b1; // all bytes match
            end
            default: begin
                o_match_count = 2'd0;
                o_align     = 1'b0;
            end
        endcase
    end
endmodule
