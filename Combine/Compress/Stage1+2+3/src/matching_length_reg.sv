module matching_length_reg #(
 parameter WIDTH = 64
)(
 input  logic               i_clk,
 input  logic               i_reset,
 input  logic [WIDTH - 1:0] i_word,
 input  logic [3:0]         i_type_matched2,
 input  logic [1:0]         i_type_matched1,
 input  logic [3:0]         i_location2,
 input  logic [3:0]         i_location4,
 input  logic [1:0]         i_match_s,
 output logic [3:0]         o_type_matched2,
 output logic [1:0]         o_type_matched1,
 output logic [1:0]         o_match_s,
 output logic [WIDTH - 1:0] o_word,
 output logic [3:0]         o_location2,
 output logic [3:0]         o_location4
);

always_ff @(posedge i_clk, negedge i_reset) begin
 if(~i_reset) begin
  o_type_matched1 <= 2'd0;
  o_type_matched2 <= 4'd0;
  o_match_s       <= 2'd0;
  o_location2     <= 4'd0;
  o_location4     <= 4'd0;
  o_word          <= 64'd0;
 end else begin
  o_type_matched1 <= i_type_matched1;
  o_type_matched2 <= i_type_matched2;
  o_match_s       <= i_match_s;
  o_word          <= i_word;
  o_location2     <= i_location2;
  o_location4     <= i_location4;
 end
end

endmodule