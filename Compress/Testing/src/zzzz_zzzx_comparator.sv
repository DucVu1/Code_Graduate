module zzzz_zzzx_comparator #(
    parameter WIDTH = 32,         // Width of in_word
    parameter WORDS = 16,         // Dictionary contains 16 words (i.e. 16*32 = 512 bits)
    parameter BYTE  = 8           // Each byte is 8 bits
)(
    input  logic [31:0]                  in_word,
    input  logic [WORDS*WIDTH-1:0]       dictionary_i,
    output logic [11:0]                  out_code  // 12-bit output
);

    // Condition for all-zero: in_word is 0.
    logic match_zzzz;
    assign match_zzzz = ~(|in_word);

    // Condition for zzzx: the upper 24 bits are zero...
    logic MSB_24_match;
    assign MSB_24_match = ~(|in_word[31:8]);

    // ...and at least one dictionary byte matches the lower 8 bits.
    logic [63:0] compare_vec;
    generate
        genvar i;
        for (i = 0; i < 64; i = i + 1) begin : gen_compare
            comparator #(.N(BYTE)) comparator_inst (
                .input_i(in_word[7:0]),
                .compare_value_i(dictionary_i[(i+1)*BYTE - 1 : i*BYTE]),
                .match_o(compare_vec[i])
            );
        end
    endgenerate

    logic byte_match;
    assign byte_match = |compare_vec;
    logic match_zzzx;
    assign match_zzzx = byte_match & MSB_24_match;

    // Priority encoder to get one matching byte’s index (0 to 63)
    // (Here we simply take the last index with a '1'; you could modify this to select the first match.)
    logic [5:0] match_index;
    integer j;
    always_comb begin
       match_index = 0;
       for (j = 0; j < 64; j = j + 1) begin
          if (compare_vec[j])
             match_index = j;
       end
    end

    // Extract the matching byte from the dictionary.
    // Using the SystemVerilog part-select syntax: [start -: width]
    logic [7:0] matched_byte;
    assign matched_byte = dictionary_i[((match_index+1)*BYTE) - 1 -: BYTE];

    // Now produce the final output code.
    // - If in_word is all zero, we output a 12-bit value with code "00" (here represented as 12'b0000_00000000).
    // - If zzzx is true, we output the 4-bit constant 1101 concatenated with the matched byte.
    always_comb begin
       if (match_zzzz) begin
           // All-zero: output code "00" (here padded to 12 bits)
           out_code = 12'b0000_00000000;
       end else if (match_zzzx) begin
           // zzzx case: output 1101 concatenated with the matching byte
           out_code = {4'b1101, matched_byte};
       end else begin
           out_code = 12'b0;
       end
    end

endmodule
