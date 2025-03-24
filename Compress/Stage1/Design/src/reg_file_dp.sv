module reg_file_single_dp #(
    parameter DATA_WIDTH = 32,
    parameter WORDS_PER_ENTRY = 16
)(
    input  logic clk,
    input  logic w_en,
    input  logic w_en2,
    input  logic [$clog2(WORDS_PER_ENTRY)-1:0] word_index,
    input  logic [$clog2(WORDS_PER_ENTRY)-1:0] word_index2,
    input  logic [DATA_WIDTH-1:0] w_data,
    input  logic [DATA_WIDTH-1:0] w_data2,
    output logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data
);
    reg [DATA_WIDTH-1:0] memory [0:WORDS_PER_ENTRY-1];

    genvar i;
    generate
        for (i = 0; i < WORDS_PER_ENTRY; i = i + 1) begin : mem_loop
            always_ff @(posedge clk) begin
                // Priority: port1 if its index matches, else port2 if its index matches.
                if (w_en && (word_index == i))
                    memory[i] <= w_data;
                else if (w_en2 && (word_index2 == i))
                    memory[i] <= w_data2;
                else
                    memory[i] <= memory[i]; // Hold current value.
            end
        end
    endgenerate

    assign r_data = { memory[15], memory[14], memory[13], memory[12],
                      memory[11], memory[10], memory[9],  memory[8],
                      memory[7],  memory[6],  memory[5],  memory[4],
                      memory[3],  memory[2],  memory[1],  memory[0] };

endmodule
