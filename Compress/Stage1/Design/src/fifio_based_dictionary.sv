module fifo_based_dict #(
    parameter DATA_WIDTH = 32,         // 32-bit per word
    parameter WORDS_PER_ENTRY = 16     // 16 words per entry total size 64 bytes
)(
    input  logic                                  i_clk,
    input  logic                                  i_reset,
    input  logic                                  wr,      // Write enable (one 32-bit word per cycle)
    input  logic [DATA_WIDTH-1:0]                 w_data,  // 32-bit input data
    output logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data, // 512-bit (64B) output
    output logic                                  full     // Indicates that a full entry has been written
);
    logic [$clog2(WORDS_PER_ENTRY)-1:0] word_index; //4 bit
    
    assign full = (word_index == (WORDS_PER_ENTRY - 1));

    logic w_en;
    assign w_en = wr;
    
    reg_file_single #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_ENTRY(WORDS_PER_ENTRY)
    ) reg_file_inst (
        .clk(i_clk),
        .w_en(w_en),
        .word_index(word_index),
        .w_data(w_data),
        .r_data(r_data)
    );
    
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset)
            word_index <= 0;
        else if (wr) begin
            if (word_index == (WORDS_PER_ENTRY - 1))
                word_index <= 0;  // Wrap around when full 64B entry is written.
            else
                word_index <= word_index + 1'b1;
        end
    end
endmodule
