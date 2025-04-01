module barrel_shifter_3 #(
    parameter TOTAL_LENGTH = 7,
    parameter WIDTH = 136,
    parameter O_WIDTH = 128
) (
    input logic [WIDTH - 1 :0]        i_word,
    input logic [TOTAL_LENGTH - 1 :0] i_amt,
    output logic [O_WIDTH - 1 :0]     o_word
);

    logic [WIDTH -1 :0] s0;
    logic [WIDTH -1 :0] s1;    
    logic [WIDTH -1 :0] s2;
    logic [WIDTH -1 :0] s3;
    logic [WIDTH -1 :0] s4;
    logic [WIDTH -1 :0] s5;
    logic [WIDTH -1 :0] s6;

    //stage 0, shift 0 or 1 bit
    assign s0 = i_amt[0]? {i_word[WIDTH - 2 : 0], 1'b0} : i_word ;
    //stage 1, shift 0 or 2 bits
    assign s1 = i_amt[1]? {s0[WIDTH - 3 : 0], 2'b00} : s0 ;
    //stage 2, shift 0 or 4 bits
    assign s2 = i_amt[2]? {s1[WIDTH - 5 : 0], 4'h0} : s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = i_amt[3]? {s2[WIDTH - 9 : 0], 8'h0} : s2;
    //stage 4, shift 0 or 16 bits
    assign s4 = i_amt[4]? {s3[WIDTH - 17 : 0], 16'h0} :s3;
    //stage 5, shift 0 or 32 bits
    assign s5 = i_amt[5]? {s4[WIDTH - 33 : 0], 32'h0} : s4;
    //stage 6, shift 0 or 64 bits
    assign s6 = i_amt[6]? {s5[WIDTH - 65 : 0], 64'h0} : s5;

    assign o_word = s6[WIDTH -1 : 8];

endmodule