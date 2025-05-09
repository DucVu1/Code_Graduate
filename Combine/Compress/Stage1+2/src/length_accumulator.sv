module length_accumulator #(
  parameter CACHE_LINE = 128,
  parameter WORD_SIZE  = 64    
)(
  input  logic         i_clk,
  input  logic         i_reset,      
  input  logic [6:0]   i_total_length, 
  output logic         o_store_flag,  
  output logic [7:0]   o_shift_amount, // number of bits regiter array 1 should shift to algin with Reg2
  output logic         o_send_back,  
  output logic         o_fill_flag,   // Determines whether to select the padded signal
  output logic         o_output_flag, // Raised when there are 128 compressed bits in Reg2
  output logic         o_fill_ctrl,   
  output logic         o_stop_flag    // Raised when the number of compressed bits exceeds 128
);

  logic [7:0] sum_partial_reg;  
  logic [8:0] sum_total_reg;  

  logic [7:0] next_sum_partial;
  logic [8:0] next_sum_total;

  always_comb begin
    next_sum_partial = sum_partial_reg + i_total_length;
    next_sum_total   = sum_total_reg   + i_total_length;
  end

  always_ff @(posedge i_clk or negedge i_reset) begin
    if (~i_reset) begin
      sum_partial_reg <= 0;
      sum_total_reg   <= 0;
    end else begin
      if (o_store_flag) 
        sum_partial_reg <= next_sum_partial - WORD_SIZE;
      else 
        sum_partial_reg <= next_sum_partial;
      
      if (o_send_back) 
        sum_total_reg   <= next_sum_total - CACHE_LINE;
      else 
        sum_total_reg   <= next_sum_total;
    end
  end

  always_comb begin
    o_store_flag   = (next_sum_partial >= WORD_SIZE) ? 1'b1 : 1'b0;
    o_shift_amount = next_sum_partial;
    o_send_back    = (next_sum_total >= CACHE_LINE) ? 1'b1 : 1'b0;
    
    // When the total number of compressed bits reaches 128, output flag is raised.
    o_output_flag = (sum_total_reg >= CACHE_LINE) ? 1'b1 : 1'b0;
    
    // o_fill_flag determines if we need to pad to reach the required word size.
    o_fill_flag = (sum_partial_reg < WORD_SIZE) ? 1'b1 : 1'b0;
    
    // o_fill_ctrl is used to control the padding mechanism
    o_fill_ctrl = (sum_partial_reg < WORD_SIZE && sum_total_reg + sum_partial_reg >= CACHE_LINE) ? 1'b1 : 1'b0;
    
    // Stop flag is set when the compressed data exceeds 128 bits
    o_stop_flag = (sum_total_reg > CACHE_LINE) ? 1'b1 : 1'b0;
  end

endmodule
