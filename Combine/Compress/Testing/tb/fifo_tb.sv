`timescale 1ns / 1ps

module fifo_tb;
    // Parameters
    parameter ADDR_WIDTH = 3;
    parameter DATA_WIDTH = 8;
    
    // Signals
    logic clk, reset;
    logic wr, rd;
    logic [DATA_WIDTH-1:0] w_data;
    logic [DATA_WIDTH-1:0] r_data;
    logic full, empty;
    
    // Instantiate FIFO
    fifo #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .w_data(w_data),
        .r_data(r_data),
        .full(full),
        .empty(empty)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        wr = 0;
        rd = 0;
        w_data = 0;
        
        // Reset sequence
        #10;
        reset = 0;
        
        // Write data into FIFO
        repeat (2**ADDR_WIDTH) begin
            @(negedge clk);
            if (!full) begin
                wr = 1;
                w_data = $random;
            end
        end
        wr = 0;
        
        // Read data from FIFO
        repeat (2**ADDR_WIDTH) begin
            @(negedge clk);
            if (!empty) begin
                rd = 1;
            end
        end
        rd = 0;
        
        // Test simultaneous read/write
        #10;
        wr = 1;
        rd = 1;
        w_data = 8'hAA;
        #10;
        wr = 0;
        rd = 0;
        
        // Finish simulation
        #50;
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor($time, " clk=%b, wr=%b, rd=%b, w_data=%h, r_data=%h, full=%b, empty=%b", 
                 clk, wr, rd, w_data, r_data, full, empty);
    end
endmodule
