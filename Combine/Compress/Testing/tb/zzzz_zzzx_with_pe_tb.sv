module tb_zzzz_zzzx_comparator;
    // Parameters (same as the comparator module)
    parameter WIDTH = 32;
    parameter WORDS = 16;
    parameter BYTE  = 8;

    // Signals
    logic [31:0]                  in_word;
    logic [WORDS*WIDTH-1:0]       dictionary_i;
    logic [5:0]                   dictionary_index; // 6-bit index (0-63)
    logic [7:0]                   matched_byte;     // The matched dictionary byte
    logic [11:0]                  out_code;         // 12-bit output code

    // Instantiate the DUT (zzzz_zzzx_comparator)
    zzzz_zzzx_comparator2 #(
        .WIDTH(WIDTH),
        .WORDS(WORDS),
        .BYTE(BYTE)
    ) dut (
        .in_word(in_word),
        .dictionary_i(dictionary_i),
        .dictionary_index(dictionary_index),
        .matched_byte(matched_byte),
        .out_code(out_code)
    );

    // Initialize the dictionary.
    // We create a 512-bit constant in which each byte is set to its index.
    initial begin
        dictionary_i = {8'd63, 8'd62, 8'd61, 8'd60,
                        8'd59, 8'd58, 8'd57, 8'd56,
                        8'd55, 8'd54, 8'd53, 8'd52,
                        8'd51, 8'd50, 8'd49, 8'd48,
                        8'd47, 8'd46, 8'd45, 8'd44,
                        8'd43, 8'd42, 8'd41, 8'd40,
                        8'd39, 8'd38, 8'd37, 8'd36,
                        8'd35, 8'd34, 8'd33, 8'd32,
                        8'd31, 8'd30, 8'd29, 8'd28,
                        8'd27, 8'd26, 8'd25, 8'd24,
                        8'd23, 8'd22, 8'd21, 8'd20,
                        8'd19, 8'd18, 8'd17, 8'd16,
                        8'd15, 8'd14, 8'd13, 8'd12,
                        8'd11, 8'd10, 8'd9,  8'd8,
                        8'd7,  8'd6,  8'd5,  8'd4,
                        8'd3,  8'd2,  8'd1,  8'd0};
    end

    // Stimulus
    initial begin
        $display("Starting testbench for zzzz_zzzx_comparator");
        
        // Test Case 1: in_word = 0 (all-zero condition)
        #5;
        in_word = 32'd0;
        #5;
        $display("Test 1: in_word = 0");
        $display("  out_code = %b, dictionary_index = %0d, matched_byte = %0d", out_code, dictionary_index, matched_byte);

        // Test Case 2: in_word meets zzzx condition (upper 24 bits zero, lower byte = 10)
        #5;
        in_word = {24'd0, 8'd10};  // 32'h0000000A
        #5;
        $display("Test 2: in_word = %h (zzzx condition)", in_word);
        $display("  out_code = %b, dictionary_index = %0d, matched_byte = %0d", out_code, dictionary_index, matched_byte);

        // Test Case 3: in_word does not meet zzzx (upper bits nonzero)
        #5;
        in_word = 32'hFF00000A;  // Upper 24 bits nonzero, so not zzzx.
        #5;
        $display("Test 3: in_word = %h (non-zzzx)", in_word);
        $display("  out_code = %b, dictionary_index = %0d, matched_byte = %0d", out_code, dictionary_index, matched_byte);

        // Test Case 4: another zzzx condition, lower byte = 45.
        #5;
        in_word = {24'd0, 8'd45};  // 32'h0000002D
        #5;
        $display("Test 4: in_word = %h (zzzx condition)", in_word);
        $display("  out_code = %b, dictionary_index = %0d, matched_byte = %0d", out_code, dictionary_index, matched_byte);

        #10;
        $finish;
    end
endmodule
