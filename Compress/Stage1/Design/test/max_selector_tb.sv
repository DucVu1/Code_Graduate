`timescale 1ns / 1ps

module tb_comparator_array2;
    parameter INPUT_WORD = 32;
    parameter DICT_ENTRY = 16;
    parameter DICT_WORD  = 32;
    
    reg  [INPUT_WORD - 1 : 0] i_input;
    reg  [INPUT_WORD * DICT_ENTRY - 1 : 0] i_dict;
    reg  [DICT_ENTRY - 1 : 0] i_align;
    
    wire [1:0] o_type_matched;
    wire       o_align;
    wire [$clog2(DICT_ENTRY) - 1 : 0] o_location;
    
    comparator_array2 #(.INPUT_WORD(INPUT_WORD), .DICT_ENTRY(DICT_ENTRY), .DICT_WORD(DICT_WORD)) dut (
        .i_input(i_input),
        .i_dict(i_dict),
        .o_type_matched(o_type_matched),
        .o_align(o_align),
        .o_location(o_location)
    );
    
    initial begin
        $dumpfile("tb_comparator_array2.vcd");
        $dumpvars(0, tb_comparator_array2);
        
        // Test Case 1: Exact match, aligned entry 3
        i_input = 32'hA5A5A5A5;
        i_dict  = {32'hEEEEEEEE, 32'hDDDDDDDD, 32'hCCCCCCCC, 32'hA5A5A5A5,
                   32'h33333333, 32'h44444444, 32'h55555555, 32'h66666666,
                   32'h77777777, 32'h88888888, 32'h99999999, 32'hAAAAAAAA,
                   32'hBBBBBBBB, 32'hAAAAAAAA, 32'hCCCCCCCC, 32'hFFFFFFFF};
        i_align = 16'b0000_0000_0000_1000;
        #10;
        assert (o_location == 4'hc) else $fatal("Test Case 1 failed");
        
        // Test Case 2: Exact match, different aligned entry
        i_input = 32'h55AA55AA;
        i_dict  = {32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444,
                   32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888,
                   32'h99999999, 32'hAAAAAA55, 32'h55AA55AA, 32'hBBBBBBBB,
                   32'hCCCCCCCC, 32'hDDDDDDDD, 32'hEEEEEEEE, 32'hFFFFFFFF};
        i_align = 16'b0000_0100_0000_0000;
        #10;
        assert (o_location == 4'h5) else $error("Test Case 2 failed");
        
        // Test Case 3: No match in dictionary
        i_input = 32'h12345678;
        i_dict  = {16{32'hFFFFFFFF}}; // No match
        i_align = 16'b0000_0000_0000_0000;
        #10;
        assert (o_type_matched == 4'h0) else $error("Test Case 3 failed");
        
        // Test Case 4: Multiple matches, best match at entry 7
        i_input = 32'hDEADBEEF;
        i_dict  = {32'hDEADBEEF, 32'hDEADBEEF, 32'h11111111, 32'h22222222,
                   32'h33333333, 32'h44444444, 32'h55555555, 32'hDEADBEEF,
                   32'h77777777, 32'h88888888, 32'h99999999, 32'hAAAAAAA1,
                   32'hBBBBBBBB, 32'hCCCCCCCC, 32'hDDDDDDDD, 32'hEEEEEEEE};
        i_align = 16'b0000_0000_1000_0000;
        #10;
        assert (o_location == 4'h8) else $error("Test Case 4 failed");
        
        // Test Case 5: All entries match, first aligned one is chosen
        i_input = 32'hFFFFFFFF;
        i_dict  = {16{32'hFFFFFFFF}};
        i_align = 16'b0000_0000_0001_0000;
        #10;
        assert (o_location == 4'h0) else $error("Test Case 5 failed");
        
        $display("All test cases passed.");
        $finish;
    end
endmodule
