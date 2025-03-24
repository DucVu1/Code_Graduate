module barrel_shifter_right_32(
    input logic [31:0] data,
	 input logic type_shift, //1 arithmetic , 0 logical
    input logic [4:0] amt,
    output logic [31:0] out
); 

    logic [31:0] s0;
    logic [31:0] s1;    
    logic [31:0] s2;
    logic [31:0] s3;

    //stage 0, shift 0 or 1 bit
    assign s0 =  amt[0]? type_shift ? {data[31], data[31:1]} :{1'b0, data[31:1]} :data ;
    //stage 1, shift 0 or 2 bits
    assign s1 =  amt[1]? type_shift ? {{2{s0[31]}},s0[31:2]} :{2'b00, s0[31:2]} :s0 ;
    //stage 2, shift 0 or 4 bits
    assign s2 = amt[2]? type_shift ? {{4{s1[31]}} ,s1[31:4]} :{4'h0, s1[31:4]} :s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = amt[3]? type_shift ? {{8{s2[31]}}, s2[31:8]}:{8'h0, s2[31:8]} :s2;
    //stage 4, shift 0 or 16 bits
    assign out = amt[4]? type_shift ? {{16{s3[31]}}, s3[31:16]}:{16'h0, s3[31:16]} :s3;

endmodule
