module barrel_shifter_1 #(
    parameter WIDTH = 68,
    parameter SHIFT_BIT = 6 
)
(
    input  logic [WIDTH -1:0]     i_word,
    input  logic [SHIFT_BIT -1:0] i_amt,
    output logic [WIDTH -1:0]     o_word
);


    logic [WIDTH -1 :0] s0;
    logic [WIDTH -1 :0] s1;    
    logic [WIDTH -1 :0] s2;
    logic [WIDTH -1 :0] s3;
    logic [WIDTH -1 :0] s4;
    logic [WIDTH -1 :0] s5;

    //stage 0, shift 0 or 1 bit
    assign s0 = i_amt[0]? {i_word[WIDTH - 2 : 0], 1'b0} :i_word ;
    //stage 1, shift 0 or 2 bits
    assign s1 = i_amt[1]? {s0[WIDTH - 3 : 0], 2'b00} : s0 ;
    //stage 2, shift 0 or 4 bits
    assign s2 = i_amt[2]? {s1[WIDTH - 5 : 0], 4'h0} : s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = i_amt[3]? {s2[WIDTH - 9 : 0], 8'h0} : s2;
    //stage 4, shift 0 or 16 bits
    assign s4 = i_amt[4]? {s3[WIDTH - 17 : 0], 16'h0} :s3;
    //stage 5, shift 0 or 32 bits
    assign o_word = i_amt[5]? {s4[WIDTH - 33 : 0], 32'h0} : s4;
    //stage 6, shift 0 or 64 bits
//    assign o_word = i_amt[6]? {s5[WIDTH - 65 : 0], 64'h0} : s5;

endmodule
