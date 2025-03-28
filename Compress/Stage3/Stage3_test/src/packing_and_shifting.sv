module packing_and_shifting #(
    parameter TOTAL_WIDTH           = 136,
    parameter TOTAL_BITS_COMPRESSED = 34,
    parameter CACHE_LINE            = 64,
    parameter WORD_WIDTH            = 32,
    parameter SHIFT_WIDTH           = 68,
    parameter WORD2_LENGTH          = 6,
    parameter TOTAL_LENGTH          = 7,
    parameter DICT_WORD             = 16,
    parameter OUT_SHIFT_BIT         = 7
)(
    input logic                                 i_clk,
    input logic [2:0]                           i_code1,
    input logic [2:0]                           i_code2,
    input logic [TOTAL_LENGTH - 1 :  0]         i_total_length,
    input logic [OUT_SHIFT_BIT - 1 : 0]         i_out_shift,
    input logic [WORD2_LENGTH - 1 : 0]          i_word2_length,
    input logic [WORD_WIDTH - 1 :0]             i_word1,
    input logic [WORD_WIDTH - 1 :0]             i_word2,
    input logic [DICT_WORD * WORD_WIDTH - 1 :0] i_dict,
    input logic [$clog2(DICT_WORD) - 1 :0]      i_idx1,
    input logic [$clog2(DICT_WORD) - 1 :0]      i_idx2
);
 
logic [TOTAL_BITS_COMPRESSED - 1 :0]   o_compressed_word1;
logic [TOTAL_BITS_COMPRESSED - 1 :0]   o_compressed_word2;
logic [TOTAL_BITS_COMPRESSED*2 - 1 :0] o_shifted; 
logic [TOTAL_WIDTH - 1 :0]             o_or_gate;
logic [TOTAL_WIDTH - 1 :0]             o_barrel2_shifted;
logic [CACHE_LINE - 1 :0]              o_barrel3_shifted;
logic [TOTAL_WIDTH - 1 :0]             o_combined;
logic [CACHE_LINE - 1 :0]              o_barrel4_shifted;
logic [TOTAL_WIDTH - 1 :0]             reg_array2;

// Code Concatenation
code_concatenator #(
    .DATA_WIDTH(WORD_WIDTH),
    .TOTAL_BITS(TOTAL_BITS_COMPRESSED),
    .TOTAL_WORDS(DICT_WORD)
) code_concatenator1 (
    .i_dict_idx(i_idx1), 
    .i_code(i_code1),     
    .i_word(i_word1),     
    .i_dict(i_dict),     
    .o_compressed_word(o_compressed_word1)
);

code_concatenator #(
    .DATA_WIDTH(WORD_WIDTH),
    .TOTAL_BITS(TOTAL_BITS_COMPRESSED),
    .TOTAL_WORDS(DICT_WORD)
) code_concatenator2 (
    .i_dict_idx(i_idx2), 
    .i_code(i_code2),     
    .i_word(i_word2),     
    .i_dict(i_dict),     
    .o_compressed_word(o_compressed_word2)
);

// Barrel Shifter 1 (Shift Right)
barrel_shifter_1 #(
    .WIDTH(TOTAL_BITS_COMPRESSED * 2),
    .SHIFT_BIT(WORD2_LENGTH) 
) barrel_shifter1 (
    .data(o_compressed_word1),
    .type_shift(1'b0),
    .amt(i_word2_length),
    .out(o_shifted)
);

// Multiplexer Array 1
multiplexer_array1 mux_array1_inst (
    .i_first_word(o_shifted),
    .i_second_word(o_compressed_word2),
    .o_selected_word(o_or_gate)
);

// Barrel Shifter 2 (Shift Left)
barrel_shifter_2 #(
    .TOTAL_LENGTH(TOTAL_LENGTH),
    .WIDTH(TOTAL_WIDTH)
) barrel_shifter_2 (
    .i_word(o_or_gate),
    .i_amt(i_total_length),
    .o_word(o_barrel2_shifted)
);

// Latch Register
latch_reg latch_reg_inst (
    .i_clk(i_clk),
    .i_data(o_barrel2_shifted),
    .o_data(reg_array2)
);

// Multiplexer Array 2
mux_array2 mux_array2_inst (
    .i_data(reg_array2),
    .o_selected_word(o_combined)
);

// Barrel Shifter 3
barrel_shifter_3 #(
    .TOTAL_LENGTH(OUT_SHIFT_BIT),
    .WIDTH(TOTAL_WIDTH),
    .O_WIDTH(CACHE_LINE)
) barrel_shifter_3(
    .i_word(o_combined),
    .i_amt(i_out_shift),
    .o_word(o_barrel3_shifted)
);

// Combine Module
combine_module combine_inst (
    .i_word(o_barrel3_shifted),
    .o_combined(o_combined)
);

// Multiplexer Array 3
multiplexer_array3 mux_array3_inst (
    .i_data(o_combined),
    .o_selected_word(o_barrel4_shifted)
);

// Barrel Shifter 4
barrel_shifter_4 #(
    .TOTAL_LENGTH(OUT_SHIFT_BIT),
    .WIDTH(CACHE_LINE),
    .O_WIDTH(CACHE_LINE)
) barrel_shifter_4 (
    .i_word(o_barrel4_shifted),
    .i_amt(i_out_shift),
    .o_word(o_barrel4_shifted)
);

endmodule
// Module Definitions
module multiplexer_array1 #(
    parameter TOTAL_BITS_COMPRESSED = 34,
    parameter TOTAL_WIDTH = 68 
) (
    input logic [TOTAL_BITS_COMPRESSED*2-1:0] i_word1,
    input logic [TOTAL_BITS_COMPRESSED-1:0] i_word2,
    output logic [TOTAL_WIDTH-1:0] o_selected_word
);
    assign o_selected_word = {i_word1, i_word2};
endmodule

module multiplexer_array2 #(
    parameter TOTAL_WIDTH = 68 
) (
    input logic [TOTAL_WIDTH-1:0] i_data,
    output logic [TOTAL_WIDTH-1:0] o_data
);
    assign o_data = i_data;
endmodule

module multiplexer_array3 #(
    parameter TOTAL_WIDTH = 64,
    parameter CACHE_LINE = 128
) (
    input logic [TOTAL_WIDTH-1:0] i_data,
    output logic [CACHE_LINE-1:0] o_data
);
    assign o_data = i_data[CACHE_LINE-1:0];
endmodule

module latch_reg #(
    parameter TOTAL_WIDTH = 128
)(
    input logic i_clk,
    input logic [TOTAL_WIDTH-1:0] i_data,
    output logic [TOTAL_WIDTH-1:0] o_data
);
    always_ff @(posedge i_clk) begin
        o_data <= i_data;
    end
endmodule

module combine #(
    parameter CACHE_LINE = 128
) (
    input logic [CACHE_LINE-1:0] i_data,
    output logic [CACHE_LINE-1:0] o_data
);
    assign o_data = i_data;
endmodule

module barrel_shifter_4 #(
    parameter TOTAL_LENGTH = 7,
    parameter WIDTH = 136,
    parameter O_WIDTH = 64
)(
    input logic [WIDTH-1:0] i_word,
    input logic [TOTAL_LENGTH-1:0] i_amt,
    output logic [O_WIDTH-1:0] o_word
);
    assign o_word = i_word >> i_amt;
endmodule

