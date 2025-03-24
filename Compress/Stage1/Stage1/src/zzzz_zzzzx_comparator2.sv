module zzzz_zzzx_comparator2 #(
    parameter WIDTH = 32,          
    parameter WORDS = 16,          
    parameter BYTE  = 8           
)(
    input  logic [31:0]                  in_word,
    input  logic [WORDS*WIDTH-1:0]       dictionary_i,
    output logic [63:0]                  cmp_vec,     // One bit per dictionary byte (64 total)
    output logic                       match_zzzz,   // in_word is all zeros
    output logic                       msb24_match   // Upper 24 bits of in_word are zero (zzzx condition)    
);

    assign match_zzzz = (~(|in_word));

    assign msb24_match = ~(|in_word[31:8]);
    generate
        genvar i;
        for (i = 0; i < 64; i = i + 1) begin : gen_compare
            comparator #(.N(BYTE)) comparator_inst (
                .input_i(in_word[7:0]),
                .compare_value_i(dictionary_i[(i+1)*BYTE - 1 : i*BYTE]),
                .match_o(cmp_vec[i])
            );
        end
    endgenerate
   

endmodule



