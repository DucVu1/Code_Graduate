module fifo_dict_tb;
    // Parameters: one entry with 16 words of 32-bit (64 bytes total)
    parameter DATA_WIDTH = 32;
    parameter WORDS_PER_ENTRY = 16;
    parameter ENTRY_WIDTH = DATA_WIDTH * WORDS_PER_ENTRY; // 512 bits

    // Testbench signals
    logic clk, reset, wr;
    logic [DATA_WIDTH-1:0] w_data;
    logic [ENTRY_WIDTH-1:0] r_data;
    logic full;

    // Instantiate the single-entry FIFO dictionary module
    fifo_dict #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_ENTRY(WORDS_PER_ENTRY)
    ) dut (
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .w_data(w_data),
        .r_data(r_data),
        .full(full)
    );

    // Clock generation: period = 10 ns (toggle every 5 ns)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        wr = 0;
        w_data = 0;
        #10;         // Allow a couple of clock cycles for reset
        reset = 0;

        // --------------------------------------------------
        // Write 16 words (32-bit each) to form one full entry
        // --------------------------------------------------
        $display("\n--- Writing first full 64B entry ---");
        for (int i = 0; i < WORDS_PER_ENTRY; i++) begin
            @(posedge clk);
            wr = 1;
            w_data = i;  // For example, write word value equal to the index
            $display("Writing word %0d: 0x%08X", i, w_data);
        end

        // Deassert write after finishing the entry
        @(posedge clk);
        wr = 0;
        @(posedge clk);
        $display("\nAfter 16 writes, full = %0d", full);
        $display("Complete entry: %h", r_data);

        // Wait a few cycles
        repeat (3) @(posedge clk);

        // --------------------------------------------------
        // Write another 16 words to test wrap-around (replacement)
        // --------------------------------------------------
        $display("\n--- Writing second full 64B entry (wrap-around) ---");
        for (int i = 0; i < WORDS_PER_ENTRY; i++) begin
            @(posedge clk);
            wr = 1;
            w_data = i + 16;  // New data values for the new entry
            $display("Writing word %0d: 0x%08X", i, w_data);
        end

        // Deassert write after finishing the new entry
        @(posedge clk);
        wr = 0;
        @(posedge clk);
        $display("\nAfter wrap-around, full = %0d", full);
        $display("New complete entry: %h", r_data);

        #20;
        $finish;
    end
endmodule
