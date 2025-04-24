module reg_array2 #(
    parameter TOTAL_WIDTH = 128
)(
    input  logic i_clk,
    input  logic i_reset,
    input  logic i_enable,
    input  logic [63:0] i_word,
    output logic [TOTAL_WIDTH-1:0] o_word
);

    logic toggle_half;

    always_ff @(posedge i_clk or negedge i_reset) begin
        if (~i_reset) begin
            o_word <= '0;
            toggle_half <= 1'b0;
        end else if (i_enable) begin
            if (!toggle_half)
                o_word[63:0] <= i_word;         // First update: lower 64 bits
            else
                o_word[127:64] <= i_word;       // Second update: upper 64 bits
            toggle_half <= ~toggle_half;        // Toggle for next time
        end
    end

endmodule
