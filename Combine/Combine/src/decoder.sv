module decoder #(
    parameter CODES = 2,
    parameter WORD  = 16,
    parameter WIDTH = 32,
    parameter I_WORD = 196,
    parameter I_WORD2 = 34

)(
    input  logic [CODES - 1 : 0]        i_codes,
    input  logic [CODES - 1 : 0]        i_codes_bak,
    input  logic [I_WORD - 1 : 0]       i_word, 
    input  logic [$clog2(WORD) - 1: 0]  i_idx,
    input  logic [WORD * WIDTH - 1 : 0] i_dict,
    output logic [WIDTH - 1 : 0]        o_word
);
logic [WIDTH - 1 : 0] temp_data;
assign temp_data = i_dict[i_idx * WIDTH +: WIDTH];

always_comb begin
 case(i_codes)
  2'b00: o_word = 32'd0; // zzzz
  2'b01: o_word = i_word[33:2]; //xxxx
  2'b10: o_word = temp_data; // mmmmm
  2'b11: begin
    case(i_codes_bak)
     2'b00: o_word = {temp_data[31:16], i_word[23:8]}; //mmxx
     2'b01: o_word = {24'd0, i_word[11:4]}; //zzzx
     2'b10: o_word = {temp_data[WIDTH -  1 : 8], i_word[15:8]}; //mmmmx
     2'b11: o_word = i_word[31:0];
    endcase
  end
 endcase
end

endmodule