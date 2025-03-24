module tb_TopModule;
    // Parameters matching the design
    parameter WIDTH = 32;
    parameter WORDS = 16;
    parameter BYTE  = 8;
    
    // Dictionary: 16 words of 32 bits (512 bits total)
    reg [WORDS*WIDTH-1:0] dictionary_i;
    // 32-bit input word
    reg  [31:0] in_word;
    
    // Outputs from TopModule
    wire [3:0]  dictionary_index; // Overall dictionary byte index (0-63)
    wire [7:0]  matched_byte;     // Matched dictionary byte
    wire [11:0] out_code;         // 12-bit output code
    wire [63:0] cmp_vec;
    reg  [1:0] local_byte_index;
    
    // Instantiate the TopModule (which instantiates comparator_core and priority_encoder_64)
    top_module_1 top_inst (
        .in_word(in_word),
        .dictionary_i(dictionary_i),
        .dict_word_index(dictionary_index),
        .local_byte_index(local_byte_index),
        .matched_byte(matched_byte),
        .out_code(out_code)
    );
    
    initial begin
        // Initialize the dictionary.
        // In this example, we fill the dictionary with sequential values descending from 63 to 0.
        // Note: With this ordering, the LSB (dictionary_i[7:0]) is 0, dictionary_i[15:8] is 1, etc.
        dictionary_i = { 8'd63, 8'd62, 8'd61, 8'd60,
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
                         8'd3,  8'd2,  8'd1,  8'd0 };

        // Wait a few time units for initialization.
        #5;
        
        // Test Case 1: in_word = 0 (all-zero condition)
        in_word = 32'd0;
        #5;
        $display("Test 1: in_word = %h", in_word);
        $display("         Expected: dictionary_index = 0, matched_byte = 00, out_code = 0000_00000000");
        $display("         Got:      dictionary_index = %d, matched_byte = %h, out_code = %h",
                 dictionary_index, matched_byte, out_code);

        // Test Case 2: zzzx condition.
        // Set in_word with upper 24 bits 0 and lower 8 bits = 10.
        #5;
        in_word = {24'd0, 8'd10}; // in_word = 0x0000000A
        #5;
        $display("Test 2: in_word = %h", in_word);
        $display("         Expected: dictionary_index = 10, matched_byte = 0A, out_code = 1101_00001010");
        $display("         Got:      dictionary_index = %d, matched_byte = %h, out_code = %h",
                 dictionary_index, matched_byte, out_code);

        // Test Case 3: Non-zzzx condition.
        // in_word with nonzero upper bits; out_code should be 0.
        #5;
        in_word = 32'hFF00000A;
        #5;
        $display("Test 3: in_word = %h", in_word);
        $display("         Expected: out_code = 0000_00000000 (zzzx condition not met)");
        $display("         Got:      dictionary_index = %d, matched_byte = %h, out_code = %h",
                 dictionary_index, matched_byte, out_code);

        // Test Case 4: Another zzzx condition.
        // in_word with upper 24 bits 0 and lower 8 bits = 45.
        #5;
        in_word = {24'd0, 8'd45}; // in_word = 0x0000002D
        #5;
        $display("Test 4: in_word = %h", in_word);
        $display("         Expected: dictionary_index = 45, matched_byte = 2D, out_code = 1101_00101101");
        $display("         Got:      dictionary_index = %d, matched_byte = %h, out_code = %h",
                 dictionary_index, matched_byte, out_code);
        
        #10;
        $finish;
    end
endmodule
