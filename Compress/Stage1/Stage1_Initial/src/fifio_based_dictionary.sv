module fifo_dict #(
    parameter DATA_WIDTH = 32,         // 32-bit per word
    parameter WORDS_PER_ENTRY = 16     // 16 words per entry total size 64 bytes
)(
    input  logic                                  clk,
    input  logic                                  reset,
    input  logic                                  wr,      // Write enable (one 32-bit word per cycle)
    input  logic [DATA_WIDTH-1:0]                 w_data,  // 32-bit input data
    output logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data, // 512-bit (64B) output
    output logic                                  full     // Indicates that a full entry has been written
);
    // Word index: tracks which word of the entry is being written.
    logic [$clog2(WORDS_PER_ENTRY)-1:0] word_index; //4 bit
    
    // When word_index reaches the last word, we consider the entry "full".
    assign full = (word_index == (WORDS_PER_ENTRY - 1));
    
    // Enable writing when wr is asserted.
    // (Depending on your application, you may decide whether to allow overwriting
    // when full or to stop accepting new writes until a reset.)
    logic w_en;
    assign w_en = wr;
    
    // Instantiate the single-entry register file.
    reg_file_single #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_ENTRY(WORDS_PER_ENTRY)
    ) reg_file_inst (
        .clk(clk),
        .w_en(w_en),
        .word_index(word_index),
        .w_data(w_data),
        .r_data(r_data)
    );
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            word_index <= 0;
        else if (wr) begin
            if (word_index == (WORDS_PER_ENTRY - 1))
                word_index <= 0;  // Wrap around when full 64B entry is written.
            else
                word_index <= word_index + 1'b1;
        end
    end
endmodule


module reg_file_single #(
    parameter DATA_WIDTH = 32,         // 32-bit per word
    parameter WORDS_PER_ENTRY = 16     // 16 words  16*32 = 512 bits (64 bytes)
)(
    input  logic                         clk,
    input  logic                         w_en,
    input  logic [$clog2(WORDS_PER_ENTRY)-1:0] word_index, // Position within the entry
    input  logic [DATA_WIDTH-1:0]        w_data,         // 32-bit word input
    output logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data   // Concatenated 512-bit output
);
    // Single-entry memory: an array of 16 words.
    logic [DATA_WIDTH-1:0] memory [WORDS_PER_ENTRY-1:0];
    
    // Write one 32-bit word at the given position.
    always_ff @(posedge clk) begin 
        if (w_en)
            memory[word_index] <= w_data;
    end
    
    // Concatenate the 16 words into a single 512-bit output.
    assign r_data = { memory[15], memory[14], memory[13], memory[12],
                      memory[11], memory[10], memory[9],  memory[8],
                      memory[7],  memory[6],  memory[5],  memory[4],
                      memory[3],  memory[2],  memory[1],  memory[0] };
endmodule
