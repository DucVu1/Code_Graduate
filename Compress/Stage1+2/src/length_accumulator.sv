module length_accumulator #(
  parameter CACHE_LINE = 128,
  parameter WORD_SIZE  = 64    
)(
  input  logic         i_clk,
  input  logic         i_reset,      
  input  logic [6:0]   i_total_length, 
  output logic         o_store_flag,  
  output logic [6:0]   o_shift_amount,
  output logic         o_send_back 
);
  
logic [7:0] sum_partial_reg;  
logic [8:0] sum_total_reg;  

logic [7:0] next_sum_partial;
logic [8:0] next_sum_total;
always_comb begin
 next_sum_partial = sum_partial_reg + i_total_length;
 next_sum_total   = sum_total_reg   + i_total_length;
end

always_ff @(posedge i_clk, negedge i_reset) begin
 if (~i_reset) begin
  sum_partial_reg <= 0;
  sum_total_reg   <= 0;
 end else begin
  if(o_store_flag) sum_partial_reg <= next_sum_partial - WORD_SIZE;
  else sum_partial_reg <= next_sum_partial;
  if (o_send_back) sum_total_reg   <= next_sum_total - CACHE_LINE;
  else sum_total_reg   <= next_sum_total;
 end
end

always_comb begin
o_store_flag = 1'b0;
 if (next_sum_partial >= WORD_SIZE) begin
  o_store_flag   = 1'b1;
  o_shift_amount = next_sum_partial - WORD_SIZE;
 end else begin
  o_store_flag   = 1'b0;
  o_shift_amount = next_sum_partial;
end
 if (next_sum_total >= CACHE_LINE) o_send_back = 1'b1;
 else o_send_back = 1'b0;
end

endmodule
