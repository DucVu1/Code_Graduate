module length_packing_reg#(
 parameter WIDTH = 64
)(
 input  logic               i_clk,
 input  logic               i_reset,
 input  logic               i_store_flag,
 input  logic               i_done_flag,  
 input  logic               i_finish_final,
 input  logic               i_compressed_flag,
 input  logic [7:0]         i_shift_amount,
//  input  logic               i_send_back,
 input  logic [2:0]         i_encoded1,
 input  logic [2:0]         i_encoded2,
 input  logic [5:0]         i_length1,
 input  logic [5:0]         i_length2,
 input  logic [3:0]         i_location2,
 input  logic [3:0]         i_location4,
 input  logic [6:0]         i_total_length,
// input  logic [7:0]         i_push_amount, 
 input  logic               i_fill_flag,   // Determines whether to select the padded signal
 input  logic               i_output_flag, // Raised when there are 128 compressed bits in Reg2
 input  logic               i_fill_ctrl,   
 input  logic               i_push_flag,
 input  logic               i_stop_flag,    // Raised when the number of compressed bits exceeds 128
 input  logic [WIDTH - 1:0] i_word,
 output logic               o_store_flag,  
 output logic               o_compressed_flag,
 output logic               o_done_flag,
 output logic [7:0]         o_shift_amount,
 //output logic [7:0]         o_push_amount,
//  output logic               o_send_back,
 output logic [2:0]         o_encoded1,
 output logic [2:0]         o_encoded2,
 output logic [5:0]         o_length1,
 output logic [5:0]         o_length2,
 output logic [3:0]         o_location2,
 output logic [3:0]         o_location4,
 output logic [6:0]         o_total_length,
 output logic               o_fill_flag,   // Determines whether to select the padded signal
 output logic               o_output_flag, // Raised when there are 128 compressed bits in Reg2
 output logic               o_fill_ctrl,   
 output logic               o_push_flag,
 output logic               o_finish_final,
 output logic               o_stop_flag,    // Raised when the number of compressed bits exceeds 128
 output logic [WIDTH - 1:0] o_word
);

always_ff @(posedge i_clk, negedge i_reset) begin
 if(~i_reset) begin
  o_store_flag   <= 1'b0;
  o_shift_amount <= 7'd0;
//   o_send_back    <= 1'd0;
  o_encoded1     <= 3'd0;
  o_encoded2     <= 3'd0;
  o_length1      <= 6'd0;
  o_length2      <= 6'd0;
  o_total_length <= 7'd0;
  o_fill_flag    <= 1'b0;
  o_output_flag  <= 1'b0;
  o_fill_ctrl    <= 1'b0;
  o_stop_flag    <= 1'b0;
  o_word         <= 64'd0;
  o_location2    <= 4'd0;
  o_location4    <= 4'd0;
  o_finish_final  <= 1'b0;
  o_done_flag    <= 1'b0;
  o_push_flag    <= 1'b0; 
  o_compressed_flag <= 1'b0;
 // o_push_amount  <= 8'd0;
 end else begin
  o_compressed_flag <= i_compressed_flag;
  o_finish_final <= i_finish_final;
  //o_push_amount  <= i_push_amount;
  o_push_flag    <= i_push_flag;
  o_done_flag    <= i_done_flag;
  o_store_flag   <= i_store_flag;
  o_shift_amount <= i_shift_amount;
//   o_send_back    <= i_send_back;
  o_encoded1     <= i_encoded1;
  o_encoded2     <= i_encoded2;
  o_length1      <= i_length1;
  o_length2      <= i_length2;
  o_total_length <= i_total_length;
  o_fill_flag    <= i_fill_flag;
  o_output_flag  <= i_output_flag;
  o_fill_ctrl    <= i_fill_ctrl;
  o_stop_flag    <= i_stop_flag;
  o_word         <= i_word;
  o_location2    <= i_location2;
  o_location4    <= i_location4;
;
 end

end





endmodule