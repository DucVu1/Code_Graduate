module max_selector #(parameter WIDTH_MATCH_BYTE = 2, parameter NO_WORD = 16)(
    input  logic [WIDTH_MATCH_BYTE * NO_WORD - 1 :0] i_no_byte_matched,      
    input  logic [NO_WORD - 1 :0]                    i_align,  
    output logic [WIDTH_MATCH_BYTE - 1 : 0]          max_val,
    output logic [$clog2(NO_WORD) - 1:0]             max_idx,
    output logic                                     max_align     
);
    wire [WIDTH_MATCH_BYTE - 1 : 0] v   [0: NO_WORD - 1];
    wire [$clog2(NO_WORD) -1 : 0]   idx [0: NO_WORD - 1]; 
    wire                            a   [0:15];

    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1) begin : stage0
            assign v[i]   = i_no_byte_matched[(i+1)*WIDTH_MATCH_BYTE - 1 : i*WIDTH_MATCH_BYTE]; //3-16 bit  
            assign idx[i] = i[3:0]; //0-16               
            assign a[i]   = i_align[i];               
        end
    endgenerate

    // Stage 1: 8 comparators compare pairs of candidates.
    wire [WIDTH_MATCH_BYTE -1 : 0] s1_val  [0:7];
    wire [$clog2(NO_WORD) - 1 : 0] s1_idx  [0:7];
    wire                           s1_align[0:7];

    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1) begin : stage1
            max2_with_index m_inst (
                .i_a(v[2*j]), 
                .i_b(v[2*j+1]),
                .idxA(idx[2*j]),
                .idxB(idx[2*j+1]),
                .alignA(a[2*j]),
                .alignB(a[2*j+1]),
                .max_out(s1_val[j]),
                .max_idx(s1_idx[j]),
                .max_align(s1_align[j])
            );
        end
    endgenerate

    // Stage 2: Compare pairs among stage 1 outputs (4 comparators).
    wire [WIDTH_MATCH_BYTE - 1: 0] s2_val  [0:3];
    wire [$clog2(NO_WORD) - 1: 0]  s2_idx  [0:3];
    wire                           s2_align[0:3];

    genvar k;
    generate
        for(k = 0; k < 4; k = k + 1) begin : stage2
            max2_with_index m_inst (
                .i_a(s1_val[2*k]),
                .i_b(s1_val[2*k+1]),
                .idxA(s1_idx[2*k]),
                .idxB(s1_idx[2*k+1]),
                .alignA(s1_align[2*k]),
                .alignB(s1_align[2*k+1]),
                .max_out(s2_val[k]),
                .max_idx(s2_idx[k]),
                .max_align(s2_align[k])
            );
        end
    endgenerate

    // Stage 3: Compare pairs among stage 2 outputs (2 comparators).
    wire [WIDTH_MATCH_BYTE - 1 : 0] s3_val  [0:1];
    wire [$clog2(NO_WORD) -1 : 0]   s3_idx  [0:1];
    wire                            s3_align[0:1];

    genvar m;
    generate
        for(m = 0; m < 2; m = m + 1) begin : stage3
            max2_with_index m_inst (
                .i_a(s2_val[2*m]),
                .i_b(s2_val[2*m+1]),
                .idxA(s2_idx[2*m]),
                .idxB(s2_idx[2*m+1]),
                .alignA(s2_align[2*m]),
                .alignB(s2_align[2*m+1]),
                .max_out(s3_val[m]),
                .max_idx(s3_idx[m]),
                .max_align(s3_align[m])
            );
        end
    endgenerate

    // Stage 4: Final comparison between the two stage 3 outputs.
    max2_with_index m_final (
        .i_a(s3_val[0]),
        .i_b(s3_val[1]),
        .idxA(s3_idx[0]),
        .idxB(s3_idx[1]),
        .alignA(s3_align[0]),
        .alignB(s3_align[1]),
        .max_out(max_val),
        .max_idx(max_idx),
        .max_align(max_align)
    );
    
endmodule
