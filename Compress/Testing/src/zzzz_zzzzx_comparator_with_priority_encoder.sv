module zzzz_zzzx_comparator2 #(
    parameter WIDTH = 32,          
    parameter WORDS = 16,          
    parameter BYTE  = 8           
)(
    input  logic [31:0]                  in_word,
    input  logic [WORDS*WIDTH-1:0]       dictionary_i,
    output logic [5:0]                   dictionary_index, 
    output logic [7:0]                   matched_byte,     
    output logic [11:0]                  out_code          
);

    logic match_zzzz;
    assign match_zzzz = (in_word == 32'd0);

    logic msb24_match;
    assign msb24_match = (in_word[31:8] == 24'd0);

    logic [63:0] cmp_vec;
    genvar i;
    generate 
        for (i = 0; i < 64; i = i + 1) begin : cmp_gen
            assign cmp_vec[i] = (dictionary_i[(i+1)*BYTE - 1 : i*BYTE] == in_word[7:0]);
        end
    endgenerate
    
    // Extract the matched byte using the dictionary_index.
    assign matched_byte = dictionary_i[((dictionary_index+1)*BYTE)-1 -: BYTE];

    always_comb begin
        if (match_zzzz) begin
            out_code = 12'b0000_00000000;
        end else if (msb24_match && (|cmp_vec)) begin
            out_code = {4'b1101, matched_byte};
        end else begin
            out_code = 12'b0;
        end
    end


priority_encoder_64 pe_inst (
        .vec(cmp_vec),
        .index(dictionary_index)
    );

endmodule

// Tree-based priority encoder for a 64-bit vector.
// It divides the 64-bit vector into eight 8-bit groups, finds the first (lowest–order)
// group with any '1', then finds the first '1' in that group, and outputs the 6-bit index.
module priority_encoder_64(
    input  logic [63:0] vec,   // 64-bit input vector (one bit per dictionary byte)
    output logic [5:0]  index  // 6-bit index output (0 to 63)
);
    // Divide vec into eight groups of 8 bits.
    logic [7:0] group_valid;
    assign group_valid[0] = |vec[7:0];
    assign group_valid[1] = |vec[15:8];
    assign group_valid[2] = |vec[23:16];
    assign group_valid[3] = |vec[31:24];
    assign group_valid[4] = |vec[39:32];
    assign group_valid[5] = |vec[47:40];
    assign group_valid[6] = |vec[55:48];
    assign group_valid[7] = |vec[63:56];

    // Determine which group (0 to 7) is the first to have a match.
    logic [2:0] group_index;
    always_comb begin
        if (group_valid[0])
            group_index = 3'd0;
        else if (group_valid[1])
            group_index = 3'd1;
        else if (group_valid[2])
            group_index = 3'd2;
        else if (group_valid[3])
            group_index = 3'd3;
        else if (group_valid[4])
            group_index = 3'd4;
        else if (group_valid[5])
            group_index = 3'd5;
        else if (group_valid[6])
            group_index = 3'd6;
        else if (group_valid[7])
            group_index = 3'd7;
        else
            group_index = 3'd0;  // Default if no match (should not occur if at least one match exists)
    end

    // Select the 8-bit group corresponding to group_index.
    logic [7:0] group_vec;
    assign group_vec = vec[group_index*8 +: 8];

    // Within that group, determine the local index of the first matching bit.
    logic [2:0] local_index;
    always_comb begin
        if (group_vec[0])
            local_index = 3'd0;
        else if (group_vec[1])
            local_index = 3'd1;
        else if (group_vec[2])
            local_index = 3'd2;
        else if (group_vec[3])
            local_index = 3'd3;
        else if (group_vec[4])
            local_index = 3'd4;
        else if (group_vec[5])
            local_index = 3'd5;
        else if (group_vec[6])
            local_index = 3'd6;
        else if (group_vec[7])
            local_index = 3'd7;
        else
            local_index = 3'd0; // Should never happen if group_valid is true
    end

    // The full dictionary index is the concatenation of the group index and the local index.
    assign index = {group_index, local_index};

endmodule
