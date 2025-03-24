module barrel_shifter_32(
    input logic [31:0] data,
    input logic [4:0] amt,
    input logic dir_lr, type_shift, // 1 rotate left = shift left, 0 rotate right = shift right , 1 = arithmetic
    output logic [31:0] out
);
    logic [31:0] out_right;
    logic [31:0] out_left;

    
    barrel_shifter_right_32 bsr(.data(data), .type_shift(type_shift), .amt(amt) , .out(out_right));
    barrel_shifter_left_32 bsl(.data(data), .amt(amt) , .out(out_left));
    
     // if rotate right use rotated output  
    assign  out = (dir_lr) ? out_left:out_right;

endmodule
