module fifo_dict #(
    parameter DATA_WIDTH = 32,         // 32-bit per word
    parameter WORDS_PER_ENTRY = 16     // 16 words per entry (512 bits total)
)(
    input  logic                                  i_clk,
    input  logic                                  i_reset,
    input  logic                                  wr,      
    input  logic                                  wr2,     
    input  logic [DATA_WIDTH-1:0]                 w_data,  
    input  logic [DATA_WIDTH-1:0]                 w_data2, 
    output logic [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data,  
    output logic                                  full     
);

logic [$clog2(WORDS_PER_ENTRY)-1:0] current_ptr;
logic [$clog2(WORDS_PER_ENTRY)-1:0] next_ptr;
logic [DATA_WIDTH-1:0] memory [0:WORDS_PER_ENTRY-1];

assign full = (wr && wr2) ? (word_ptr == (WORDS_PER_ENTRY - 2))
                          : (word_ptr == (WORDS_PER_ENTRY - 1));
 
always_ff @(posedge i_clk, negedge i_reset) begin
  if (~i_reset) begin
		for (int i = 0; i < 16; i++) begin
			 memory[i] <= 32'b0;
		end
  end else begin
  if (wr & wr2) begin
		memory[current_ptr] <= w_data;
        memory[current_ptr + 1] <= w_data2;
  end else if (wr) memory[current_ptr] <= w_data;
  else if (wr2) memory[current_ptr] <= w_data2;
  else memory[current_ptr] <= memory[current_ptr];
  end
end


assign r_data = { memory[15], memory[14], memory[13], memory[12],
                  memory[11], memory[10], memory[9],  memory[8],
                  memory[7],  memory[6],  memory[5],  memory[4],
                  memory[3],  memory[2],  memory[1],  memory[0] };

endmodule
