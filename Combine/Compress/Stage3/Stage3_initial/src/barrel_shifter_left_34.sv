module barrel_shifter_left_34 #(
    parameter WIDTH = 68,
    parameter SHIFT_BIT = 6 
)(
    input  logic [WIDTH -1 :0]     data,
    input  logic [SHIFT_BIT -1 :0] amt,
    output logic [WIDTH -1 :0]     out
);

    logic [WIDTH -1 :0] s0;
    logic [WIDTH -1 :0] s1;    
    logic [WIDTH -1 :0] s2;
    logic [WIDTH -1 :0] s3;
    logic [WIDTH -1 :0] s4;

    //stage 0, shift 0 or 1 bit
    assign s0 = amt[0]? {data[WIDTH - 2 : 0], 1'b0} :data ;
    //stage 1, shift 0 or 2 bits
    assign s1 = amt[1]? {s0[WIDTH - 3 : 0], 2'b00} : s0 ;
    //stage 2, shift 0 or 4 bits
    assign s2 = amt[2]? {s1[WIDTH - 5 : 0], 4'h0} : s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = amt[3]? {s2[WIDTH - 9 : 0], 8'h0} : s2;
    //stage 4, shift 0 or 16 bits
    assign s4 = amt[4]? {s3[WIDTH - 17 : 0], 16'h0} :s3;
    //stage 5, shift 0 or 32 bits
    assign out = amt[5]? {s4[WIDTH - 33 : 0], 32'h0} : s4;
endmodule
