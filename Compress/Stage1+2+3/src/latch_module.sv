module latch_module #(
    parameter WIDTH = 128
)
(
    input  logic                i_clk,
    input  logic                i_reset,
    input  logic                i_enable,
    input  logic [WIDTH - 1 :0] i_word,
    output logic [WIDTH - 1 :0] o_word
);

always_latch begin
    if(~i_reset) o_word <= 128'd0;
    else if (i_enable) o_word <= i_word;
    else o_word <= o_word;
end
    
endmodule