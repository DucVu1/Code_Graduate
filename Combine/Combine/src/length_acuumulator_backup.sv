/* shift_amount = to algin word in reg1 with word in reg2
   i_total_length = to next compressed word with current compressed word.
*/
module length_accumulator #(
  parameter CACHE_LINE = 128,
  parameter WORD_SIZE  = 64    
)(
  input  logic         i_clk,
  input  logic         i_reset,      
  input  logic [6:0]   i_total_length, 
  output logic         o_store_flag,  // number of accumulated compressed bits has exceeded 64 bits
  output logic [7:0]   o_shift_amount, // number of bits regiter array 1 should shift to algin with Reg2
  //output logic [7:0]   o_push_amount, 
  // output logic         o_send_back,  
  output logic         o_fill_flag,   // Determines whether to select the padded signal
  output logic         o_output_flag, // Raised when there are 128 compressed bits in Reg2
  output logic         o_fill_ctrl,   
  output logic         o_stop_flag,    // Raised when the number of compressed bits exceeds 128
  output logic         o_done_flag,
  output logic         o_finish_final,
  output logic         o_compressed_flag,
  output logic         o_push_flag
);

//logic compressed_flag;
logic [7:0] sum_partial_reg;  
//logic [7:0] push_amount;
//logic [7:0] temp_shift_amount;  
logic [7:0] sum_total_reg;  
logic [7:0] sum64_reg;
logic [7:0] next_sum64;
logic [7:0] next_sum_partial;
logic [7:0] next_sum_total;
//logic [7:0] padd_amount;
logic o_full_flag, push_flag_n, push_flag_n2;

assign o_done_flag = o_full_flag || o_stop_flag;


always_comb begin
  if(~i_reset) begin
      next_sum_partial = 0;
      next_sum_total   = 0;
      next_sum64       = 0;
      //padd_amount      = 0;
      //push_amount      = 0;
		push_flag_n = 1'b0;
  end else begin
    push_flag_n = 1'b0;
    next_sum_partial = sum_partial_reg + i_total_length;
    next_sum_total   = sum_total_reg   + i_total_length;
    next_sum64       = sum64_reg + i_total_length;
    //padd_amount      = '0;
    //push_amount      = '0;
    if(i_total_length >= WORD_SIZE) begin
      if(sum_total_reg <= WORD_SIZE - 4) begin
      next_sum64 = next_sum_total;
      push_flag_n = 1'b1;
      //push_amount = next_sum_total;
      end else begin
		next_sum64 = next_sum_total;
      push_flag_n = 1'b1;
      //padd_amount = i_total_length;
      end
    end else begin
      next_sum_partial = sum_partial_reg + i_total_length;
      next_sum_total   = sum_total_reg   + i_total_length;
      if (push_flag_n2) next_sum64 = sum64_reg - 8'd64 + i_total_length;
      else next_sum64 = sum64_reg + i_total_length;
    end
  end
end

always_ff @(posedge i_clk or negedge i_reset) begin
  if (~i_reset) begin
    sum_partial_reg <= 0;
    sum_total_reg   <= 0;
    sum64_reg <=0;
    //temp_shift_amount <= 0;
    o_push_flag <= 1'b0;
    push_flag_n2 <= 1'b0;
    //o_push_amount <= 0;
  end else begin
    push_flag_n2 <= push_flag_n;
    o_push_flag  <= push_flag_n2;
    //o_push_amount <= push_amount;
    if (o_store_flag) begin
      sum_partial_reg <= next_sum_partial - next_sum_partial;
      if(push_flag_n2) 
        if (o_stop_flag)sum64_reg <= sum64_reg - sum64_reg + i_total_length;
        else sum64_reg <= sum64_reg - 8'd64 + i_total_length;
      else sum64_reg <= sum64_reg - sum64_reg + i_total_length;
    end
    else begin 
      sum_partial_reg <= next_sum_partial;
      sum64_reg <= next_sum64;
    end
    if (o_full_flag)  sum_total_reg <= next_sum_total - next_sum_total + i_total_length;
    else if (o_stop_flag)  sum_total_reg <= next_sum_total - next_sum_total;
    else sum_total_reg   <= next_sum_total;
  end
end

always_comb begin 
 o_store_flag   = (sum64_reg >= WORD_SIZE) ? 1'b1 : 1'b0;
 o_shift_amount = sum64_reg;
 // When the total number of compressed bits reaches 128, output flag is raised.
 o_output_flag = (sum_total_reg >= CACHE_LINE) ? 1'b1 : 1'b0;
 o_stop_flag  = o_full_flag ? 1'b0 : (next_sum_total > CACHE_LINE) ? 1'b1 : 1'b0;
 o_compressed_flag = o_stop_flag ? 1'b0 : 1'b1;
end

always_ff @(posedge i_clk) begin
 o_fill_flag <= (sum_partial_reg < WORD_SIZE) ? 1'b1 : 1'b0;
  
 o_fill_ctrl <= (sum_partial_reg < WORD_SIZE && sum_total_reg + sum_partial_reg >= CACHE_LINE) ? 1'b1 : 1'b0;

 o_full_flag <= (next_sum_total == CACHE_LINE) ? 1'b1 : 1'b0;

 o_finish_final <= o_done_flag ? 1'b1 : 1'b0;
end

endmodule
 