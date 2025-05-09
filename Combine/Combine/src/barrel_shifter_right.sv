module barrel_shifter_right #(parameter WIDTH = 196)(
    input  logic [WIDTH-1:0] i_data,
    input  logic [6:0]       i_amt,        
    output logic [WIDTH-1:0] o_data
); 

 logic [WIDTH-1:0] s0;
 logic [WIDTH-1:0] s1;
 logic [WIDTH-1:0] s2;
 logic [WIDTH-1:0] s3;
 logic [WIDTH-1:0] s4;
 logic [WIDTH-1:0] s5;
 logic [WIDTH-1:0] s6;
 logic [WIDTH-1:0] s7;
// logic [WIDTH-1:0] s8;

    assign s0 = i_data;

    // Stage 0: shift by 1
    assign s1 = i_amt[0] ? {{1'b0}, s0[WIDTH-1:1]} : s0;

    // Stage 1: shift by 2
    assign s2 = i_amt[1] ? {{2{1'b0}}, s1[WIDTH-1:2]} : s1;

    // Stage 2: shift by 4
    assign s3 = i_amt[2] ? {{4{1'b0}}, s2[WIDTH-1:4]} : s2;

    // Stage 3: shift by 8
    assign s4 = i_amt[3] ? {{8{1'b0}}, s3[WIDTH-1:8]}: s3;

    // Stage 4: shift by 16
    assign s5 = i_amt[4] ? {{16{1'b0}}, s4[WIDTH-1:16]} : s4;

    // Stage 5: shift by 32
    assign s6 = i_amt[5] ? {{32{1'b0}}, s5[WIDTH-1:32]} : s5;

    // Stage 6: shift by 64
    assign s7 = i_amt[6] ? {{64{1'b0}}, s6[WIDTH-1:64]} : s6;

    // Stage 7: shift by 128
    //assign s8 = i_amt[7] ? {{128{1'b0}}, s7[WIDTH-1:128]} : s7;

    assign o_data = s7;

endmodule
