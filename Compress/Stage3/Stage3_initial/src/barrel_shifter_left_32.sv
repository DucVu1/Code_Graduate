module barrel_shifter_left_32(
    input logic [31:0] data,
    input logic [4:0] amt,
    output logic [31:0] out
);

    logic [31:0] s0;
    logic [31:0] s1;    
    logic [31:0] s2;
    logic [31:0] s3;

    //stage 0, shift 0 or 1 bit
    assign s0 =  amt[0]? {data[30:0], 1'b0} :data ;
    //stage 1, shift 0 or 2 bits
    assign s1 =  amt[1]? {s0[29:0],2'b00} :s0 ;
    //stage 2, shift 0 or 4 bits
    assign s2 = amt[2]?{s1[27:0], 4'h0} :s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = amt[3]?{s2[23:0], 8'h0} :s2;
    //stage 4, shift 0 or 16 bits
    assign out = amt[4]?{s3[15:0], 16'h0} :s3;

endmodule
