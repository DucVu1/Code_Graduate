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

  logic [$clog2(WORDS_PER_ENTRY)-1:0] word_ptr;
  logic [$clog2(WORDS_PER_ENTRY)-1:0] next_ptr;

  assign full = (wr && wr2) ? (word_ptr == (WORDS_PER_ENTRY - 2))
                            : (word_ptr == (WORDS_PER_ENTRY - 1));
  
  // Pointer update: increment word_ptr according to the write enables.
  always_ff @(posedge i_clk or posedge i_reset) begin
      if (i_reset)
          word_ptr <= 0;
      else if (wr && wr2) begin
          // When writing two words, increment pointer by 2 (wrap-around if necessary).
          if (word_ptr <= WORDS_PER_ENTRY - 2)
              word_ptr <= word_ptr + 2;
          else
              word_ptr <= 0;
      end else if (wr) begin
          // Single write: increment pointer by 1.
          if (word_ptr < WORDS_PER_ENTRY - 1)
              word_ptr <= word_ptr + 1;
          else
              word_ptr <= 0;
      end
      else begin
          word_ptr <= word_ptr; // Hold current pointer
      end
  end

  // Compute next pointer as (word_ptr+1) mod WORDS_PER_ENTRY.
  always_comb begin
      if (word_ptr == WORDS_PER_ENTRY - 1)
          next_ptr = 0;
      else
          next_ptr = word_ptr + 1;
  end

  // Memory array for one entry (16 words).
  reg [DATA_WIDTH-1:0] memory [0:WORDS_PER_ENTRY-1];
  integer i;
  always_ff @(posedge i_clk or posedge i_reset) begin
      if (i_reset) begin
          for (i = 0; i < WORDS_PER_ENTRY; i = i + 1)
              memory[i] <= '0;
      end else begin
          // For each memory element, update if the index matches one of the write ports.
          for (i = 0; i < WORDS_PER_ENTRY; i = i + 1) begin
              if ((i == word_ptr) && wr)
                  memory[i] <= w_data;
              else if ((i == next_ptr) && wr2)
                  memory[i] <= w_data2;
              else
                  memory[i] <= memory[i]; // Hold value
          end
      end
  end

  // Concatenate the memory into a single 512-bit output.
  assign r_data = { memory[15], memory[14], memory[13], memory[12],
                    memory[11], memory[10], memory[9],  memory[8],
                    memory[7],  memory[6],  memory[5],  memory[4],
                    memory[3],  memory[2],  memory[1],  memory[0] };

endmodule
