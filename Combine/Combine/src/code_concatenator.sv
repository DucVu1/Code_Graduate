module code_concatenator #(
  parameter DATA_WIDTH = 32,
  parameter TOTAL_BITS = 34,
  parameter TOTAL_WORDS = 16
)(
  input  logic [3:0]                           i_dict_idx, 
  input  logic [2:0]                           i_code,     
  input  logic [DATA_WIDTH - 1:0]              i_word,     
//   input  logic [DATA_WIDTH * TOTAL_BITS -1:0]  i_dict,     
  output logic [TOTAL_BITS-1:0]                o_compressed_word
);

//logic [DATA_WIDTH -1:0] dict_word;

//assign dict_word = i_dict[i_dict_idx * DATA_WIDTH +: DATA_WIDTH];


logic [TOTAL_BITS-1:0] temp;
//bytes idx code
always_comb begin
case (i_code)
    3'b000: begin //zzzz
        temp =  32'd0;
    end
    3'b001: begin //mmmm
        temp = {{(TOTAL_BITS-6){1'b0}}, i_dict_idx, 2'b10}; //index, code
    end
    3'b010: begin //zzzx
        temp = {{(TOTAL_BITS-12){1'b0}}, i_word[7:0], 4'b0111}; //bytes, code
    end
    3'b011: begin // mmmx
        temp = {{(TOTAL_BITS-16){1'b0}},  i_word[7:0], i_dict_idx, 4'b1011}; //byte(s), index,code
    end
    3'b100: begin //mmxx
        temp = {{(TOTAL_BITS-24){1'b0}},  i_word[15:0], i_dict_idx, 4'b0011 };
    end
    3'b101: begin //xxxx
        temp = {i_word, 2'b01}; 
    end
    default: begin
        temp = {TOTAL_BITS{1'b0}};
    end
endcase
end

assign o_compressed_word = temp;

endmodule
