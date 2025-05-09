module register_array #(
    parameter TOTAL_WIDTH = 128
)(
    input  logic i_clk,
    input  logic i_reset,
    input  logic [TOTAL_WIDTH - 1:0] i_word,
    output logic [TOTAL_WIDTH - 1:0] o_word
);

always_ff @(posedge i_clk, negedge i_reset) begin
 if(~i_reset) o_word <= '0;
 else o_word <= i_word;
end

endmodule