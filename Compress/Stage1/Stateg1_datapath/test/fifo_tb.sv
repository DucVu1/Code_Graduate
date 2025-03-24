`timescale 1ns/1ps

module tb_fifo_dict;
    parameter DATA_WIDTH = 32;
    parameter WORDS_PER_ENTRY = 16;
    
    logic i_clk, i_reset;
    logic wr, wr2;
    logic [DATA_WIDTH-1:0] w_data, w_data2;
    wire [WORDS_PER_ENTRY*DATA_WIDTH-1:0] r_data;
    wire full;
    
    fifo_dict #(.DATA_WIDTH(DATA_WIDTH), .TOTAL_WORDS(WORDS_PER_ENTRY)) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .wr(wr),
        .wr2(wr2),
        .w_data(w_data),
        .w_data2(w_data2),
        .o_data(r_data),
        .full(full)
    );
    
    // Clock generation
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;
    
    initial begin
        i_reset = 0;
        wr = 0;
        wr2 = 0;
        w_data = 0;
        w_data2 = 0;
        #10;
        i_reset = 1;
        
        // Test writing two words per cycle.
        // Write 16 words (full entry) using two writes per cycle.
        repeat (8) begin
            @(posedge i_clk);
            wr = 1; wr2 = 1;
            w_data = $urandom_range(0, 32'hFFFFFFFF);
            w_data2 = $urandom_range(0, 32'hFFFFFFFF);
            @(posedge i_clk);
            wr = 0; wr2 = 0;
        end
        
        // Check the r_data output.
        #10;
        $display("FIFO r_data = %h", r_data);
        $display("FIFO full = %b", full);
        $finish;
    end
endmodule
