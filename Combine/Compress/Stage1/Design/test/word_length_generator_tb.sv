`timescale 1ns / 1ps

module tb_word_length_genetator;
    // DUT inputs
    logic        i_type_matched1; // from CA1 (least significant bit of CA1)
    logic        i_match_s1;      // from CA1 (most significant bit of CA1)
    logic  [1:0] i_type_matched2; // CA2
    
    // DUT outputs
    wire [5:0]   o_length;
    wire [2:0]   o_encoded;
    
    // Instantiate the DUT.
    word_length_genetator dut (
        .i_type_matched1(i_type_matched1),
        .i_match_s1(i_match_s1),
        .i_type_matched2(i_type_matched2),
        .o_length(o_length),
        .o_encoded(o_encoded)
    );
    
    // Expected values lookup table for 16 combinations.
    // Based on the truth table mapping defined above.
    logic [2:0] expected_encoded [0:15];
    logic [5:0] expected_length [0:15];
    
    initial begin
        expected_encoded[ 0] = 3'b101; expected_length[ 0] = 34;
        expected_encoded[ 1] = 3'b101; expected_length[ 1] = 34;
        expected_encoded[ 2] = 3'b010; expected_length[ 2] = 12;
        expected_encoded[ 3] = 3'b000; expected_length[ 3] = 2;
        expected_encoded[ 4] = 3'b100; expected_length[ 4] = 24;
        expected_encoded[ 5] = 3'b100; expected_length[ 5] = 24;
        expected_encoded[ 6] = 3'b010; expected_length[ 6] = 12;
        expected_encoded[ 7] = 3'b000; expected_length[ 7] = 2;
        expected_encoded[ 8] = 3'b011; expected_length[ 8] = 16;
        expected_encoded[ 9] = 3'b011; expected_length[ 9] = 16;
        expected_encoded[10] = 3'b010; expected_length[10] = 12;
        expected_encoded[11] = 3'b000; expected_length[11] = 2;
        expected_encoded[12] = 3'b001; expected_length[12] = 6;
        expected_encoded[13] = 3'b001; expected_length[13] = 6;
        expected_encoded[14] = 3'b001; expected_length[14] = 6;
        expected_encoded[15] = 3'b000; expected_length[15] = 2;
    end
    
    integer test;
    initial begin
        $dumpfile("tb_word_length_genetator.vcd");
        $dumpvars(0, tb_word_length_genetator);
        $display("Starting word_length_genetator test...");
        
        // Loop over all 16 test cases.
        // Note: Here we assign the test vector as follows:
        // CA1 = { i_match_s1, i_type_matched1 } where
        //   i_match_s1 = test[1] and i_type_matched1 = test[0],
        // CA2 = test[3:2].
        for (test = 0; test < 16; test = test + 1) begin
            i_match_s1      = test[1];        // second LSB becomes i_match_s1
            i_type_matched1 = test[0];        // LSB becomes i_type_matched1
            i_type_matched2 = test[3:2];        // MSBs become i_type_matched2
            #10;
            $display("Test %0d: CA1 = {%b, %b}, CA2 = %b | o_encoded = %b, o_length = %d", 
                     test, i_match_s1, i_type_matched1, i_type_matched2, o_encoded, o_length);
            if ((o_encoded !== expected_encoded[test]) || (o_length !== expected_length[test])) begin
                $display("[ERROR] Test %0d failed: Expected o_encoded = %b, o_length = %d", test, expected_encoded[test], expected_length[test]);
            end else begin
                $display("[PASS] Test %0d passed.", test);
            end
        end
        
        $finish;
    end
endmodule
