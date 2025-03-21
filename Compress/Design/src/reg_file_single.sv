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
