module comparator_array1 #(
    parameter WIDTH = 32,         // Width of in_word
    parameter WORDS = 16,         // Dictionary contains 16 words (i.e. 16*32 = 512 bits)
    parameter BYTE  = 8           // Each byte is 8 bits
)(
    input  logic [31:0]                  i_word,
    input  logic [WORDS*WIDTH-1:0]       i_dictionary,
    output logic                         o_type_matched,
    output logic                         o_match_s,
    output logic [11:0]                  o_code  // 12-bit output
);

 logic match_zzzz;
 logic MSB_24_match;

 assign match_zzzz = ~(|i_word);
 assign MSB_24_match = ~(|i_word[31:8]);

    always_comb begin
       if (match_zzzz) begin
           o_code = 12'b0000_00000000;
           o_match_s = 1'b1;
       end else if (MSB_24_match) begin
           o_code = {4'b1101, i_word[7:0]};
           o_match_s = 1'b1;
       end else begin
           o_code = 12'b0;
           o_match_s = 1'b0;
       end
    end

endmodule
