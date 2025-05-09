module priority_encoder_64(
    input  logic [63:0] vec,             // 64-bit compare vector (one bit per dictionary byte)
    output logic [3:0]  dict_word_index,   // Dictionary word index (0 to 15)
    output logic [1:0]  local_byte_index  // Byte offset within the word (0 to 3)
    //output logic [5:0]  overall_index      // Overall index = {dict_word_index, local_byte_index}
);

    // Divide vec into 16 groups of 4 bits.
    logic [15:0] group_valid;
    genvar j;
    generate
      for (j = 0; j < 16; j = j + 1) begin : group_valid_gen
         assign group_valid[j] = |vec[j*4 +: 4];
      end
    endgenerate
    
    // Determine which group (0 to 15) is the first to have a match.
    always_comb begin
        if (group_valid[0])
            dict_word_index = 4'd0;
        else if (group_valid[1])
            dict_word_index = 4'd1;
        else if (group_valid[2])
            dict_word_index = 4'd2;
        else if (group_valid[3])
            dict_word_index = 4'd3;
        else if (group_valid[4])
            dict_word_index = 4'd4;
        else if (group_valid[5])
            dict_word_index = 4'd5;
        else if (group_valid[6])
            dict_word_index = 4'd6;
        else if (group_valid[7])
            dict_word_index = 4'd7;
        else if (group_valid[8])
            dict_word_index = 4'd8;
        else if (group_valid[9])
            dict_word_index = 4'd9;
        else if (group_valid[10])
            dict_word_index = 4'd10;
        else if (group_valid[11])
            dict_word_index = 4'd11;
        else if (group_valid[12])
            dict_word_index = 4'd12;
        else if (group_valid[13])
            dict_word_index = 4'd13;
        else if (group_valid[14])
            dict_word_index = 4'd14;
        else if (group_valid[15])
            dict_word_index = 4'd15;
        else
            dict_word_index = 4'd0; // Default if no match (should not occur if at least one match exists)
    end

    // Select the 4-bit group corresponding to dict_word_index.
    logic [3:0] group_vec;
    assign group_vec = vec[dict_word_index*4 +: 4];

    // Within that group, determine the local index of the first matching bit.
    always_comb begin
        if (group_vec[0])
            local_byte_index = 2'd0;
        else if (group_vec[1])
            local_byte_index = 2'd1;
        else if (group_vec[2])
            local_byte_index = 2'd2;
        else if (group_vec[3])
            local_byte_index = 2'd3;
        else
            local_byte_index = 2'd0; // Should never occur if group_valid is true.
    end

    // Overall dictionary byte index: concatenation of the dictionary word index and local byte index.
    //assign overall_index = {dict_word_index, local_byte_index};

endmodule
