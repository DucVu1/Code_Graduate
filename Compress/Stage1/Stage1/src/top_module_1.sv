module top_module_1 (
    input  logic [31:0]                 in_word,
    input  logic [16*32-1:0]            dictionary_i, // 16 words of 32 bits = 512 bits total
    output logic [3:0]                  dict_word_index, // Overall dictionary byte index (0 to 16)
    output logic [1:0]                  local_byte_index,
    output logic [7:0]                  matched_byte,     // The matched dictionary byte
    output logic [11:0]                 out_code          // 12-bit output code
);

    // Wires from the comparator_core.
    logic [63:0] cmp_vec;
    logic match_zzzz;
    logic msb24_match;
    
    // Instantiate the comparator core.
    zzzz_zzzx_comparator2 comp_core_inst (
        .in_word(in_word),
        .dictionary_i(dictionary_i),
        .cmp_vec(cmp_vec),
        .match_zzzz(match_zzzz),
        .msb24_match(msb24_match)
    );
    
    // Instantiate the new priority encoder.
    //logic [3:0] dict_word_index;
    priority_encoder_64 pe_new_inst (
        .vec(cmp_vec),
        .dict_word_index(dict_word_index),
        .local_byte_index(local_byte_index)
       // .overall_index(dictionary_index)
    );
    logic [5:0] dictionary_byte_index;
    assign dictionary_byte_index =  {dict_word_index , local_byte_index};
    // Extract the matched byte using the overall dictionary_index.
    // Since dictionary is 64 bytes (16 words of 4 bytes each), each byte is 8 bits.
    assign matched_byte = dictionary_i[((dictionary_byte_index+1)*8)-1 -: 8];

    always_comb begin
        if (match_zzzz)
            out_code = 12'b0000_00000000;
        else if (msb24_match && (|cmp_vec))
            out_code = {4'b1101, matched_byte};
        else
            out_code = 12'b0;
    end

endmodule
