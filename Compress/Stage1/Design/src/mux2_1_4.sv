module mux2_1_4 (
    input  logic       sel,
    input  logic [3:0] in0,
    input  logic [3:0] in1,
    output logic [3:0] out
);
  assign out = sel ?  in1 : in0;
endmodule
