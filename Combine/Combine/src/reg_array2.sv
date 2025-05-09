module reg_array2 #(
    parameter TOTAL_WIDTH = 128
)(
    input  logic i_clk,
    input  logic i_reset,
    input  logic i_enable,
    input  logic i_push_flag,
    input  logic [TOTAL_WIDTH-1:0] i_word,
    output logic [TOTAL_WIDTH-1:0] o_word
);
logic toggle_half;
always_ff @(posedge i_clk or negedge i_reset) begin
    if (~i_reset) begin
        o_word <= '0;
        toggle_half <= 1'b0;
    end else if (i_enable) begin
        if (!toggle_half)
            if(i_push_flag) begin
            o_word <= i_word;
            end else o_word[63:0] <= i_word[127:64];         // First update: lower 64 bits
        else
            if(i_push_flag) begin
            o_word <= i_word;
            end else o_word[127:64] <= i_word[127:64];       // Second update: upper 64 bits
        toggle_half <= ~toggle_half;        
    end
end

endmodule
