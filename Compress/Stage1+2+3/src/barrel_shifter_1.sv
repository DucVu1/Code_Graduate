module barrel_shifter_1 #(
    parameter WIDTH = 68,
    parameter SHIFT_BIT = 6 
)
(
    input  logic [WIDTH -1:0]     data,
	input  logic                  type_shift, //1 arithmetic , 0 logical
    input  logic [SHIFT_BIT -1:0] amt,
    output logic [WIDTH -1:0]     out
);

    logic [WIDTH -1:0] s0;
    logic [WIDTH -1:0] s1;    
    logic [WIDTH -1:0] s2;
    logic [WIDTH -1:0] s3;
    logic [WIDTH -1:0] s4;

    //stage 0, shift 0 or 1 bit
    assign s0 = amt[0]? type_shift ? {data[WIDTH -1], data[WIDTH - 2 :1]} : {1'b0, data[WIDTH -2:1]} :data;
    //stage 1, shift 0 or 2 bits
    assign s1 = amt[1]? type_shift ? {{2{s0[WIDTH -1]}},s0[WIDTH - 2 :2]} : {2'b00, s0[WIDTH -2:2]} : s0; 
    //stage 2, shift 0 or 4 bits
    assign s2 = amt[2]? type_shift ? {{4{s1[WIDTH -1]}} ,s1[WIDTH - 2:4]} : {4'h0, s1[WIDTH -2:4]} : s1;
    //stage 3, shift 0 or 8 bits
    assign s3 = amt[3]? type_shift ? {{8{s2[WIDTH -1]}}, s2[WIDTH - 2:8]} : {8'h0, s2[WIDTH -2:8]} : s2;
    //stage 4, shift 0 or 16 bits
    assign s4 = amt[4]? type_shift ? {{16{s3[WIDTH -1]}}, s3[WIDTH - 2:16]} : {16'h0, s3[WIDTH -2:16]} : s3;
    //stage 5, shift 0 or 32 bits
    assign out = amt[5]? type_shift ? {{32{s4[WIDTH -1]}},s4[WIDTH - 2:32]} : {32'h0, s4[WIDTH -2:32]} : s4;

endmodule
