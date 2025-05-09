 module reg_out #(
  parameter WIDTH   = 32,
  parameter O_WIDTH = 128
)(
  input  logic                 i_clk,
  input  logic                 i_reset,
  input  logic [WIDTH - 1:0]   i_word1,
  input  logic [WIDTH - 1:0]   i_word2,
  output logic [O_WIDTH - 1:0] o_word,
  output logic                 o_count
);

logic [WIDTH-1:0] reg_array [3:0];
logic [O_WIDTH-1:0] o_word_temp;
logic               word_count_r, word_count_n;   

always_comb begin
 if(~i_reset) begin
  o_word_temp  = '0;
  o_count = '0;
  word_count_n = '0;
 end else begin
  o_count = 1'b0;
  o_word_temp  = {reg_array[3], reg_array[2], reg_array[1], reg_array[0]};
  word_count_n = ~word_count_r;
  if (word_count_r) begin
   o_count = 1'b1;
   word_count_n = '0;
  end else begin
   o_count = 1'b0;
   end
 end
end



always_ff @(posedge i_clk or negedge i_reset) begin
 if (~i_reset) begin
  reg_array[0] <= '0;
  reg_array[1] <= '0;
  reg_array[2] <= '0;
  reg_array[3] <= '0;
  word_count_r <= '0;
  end else begin
  reg_array[3] <= reg_array[1];
  reg_array[2] <= reg_array[0];
  reg_array[1] <= i_word2;
  reg_array[0] <= i_word1;
  word_count_r <= word_count_n;
  o_word <= o_word_temp;
 end
end

endmodule
