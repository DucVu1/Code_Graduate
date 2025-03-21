module dsc_cache_tb;

    // Parameters matching the DSC Cache module
    parameter TAG_WIDTH = 10;
    parameter INDEX_WIDTH = 4;
    parameter BLOCK_SIZE = 64;
    parameter NUM_WAYS = 2;
    parameter NUM_SECTORS = 2;

    // DUT signals
    logic clk, reset;
    logic read, write;
    logic [31:0] addr;
    logic [BLOCK_SIZE-1:0] wdata, rdata;
    logic hit;

    // Instantiate DUT
    DSC #(
        .TAG_WIDTH(TAG_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH),
        .BLOCK_SIZE(BLOCK_SIZE),
        .NUM_WAYS(NUM_WAYS),
        .NUM_SECTORS(NUM_SECTORS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .read(read),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .hit(hit),
        .rdata(rdata)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        clk = 0;
        reset = 1;
        read = 0;
        write = 0;
        addr = 0;
        wdata = 0;

        // Reset phase
        #10 reset = 0;
        $display("Cache Reset Complete.");

        // Write data to sector 0, index 0
        addr = 32'h0000_0000;
        wdata = 64'hAAAA_BBBB_CCCC_DDDD;
        write = 1;
        #10 write = 0;
        $display("Wrote to Address: %h, Data: %h", addr, wdata);

        // Read the same address (expect cache hit)
        read = 1;
        #10 read = 0;
        if (hit) 
            $display("Cache Hit! Read Data: %h", rdata);
        else
            $display("Cache Miss! Read Data: %h", rdata);

        // Write to a different sector but same tag (sector 1)
        addr = 32'h0000_0010; // Address in same superblock
        wdata = 64'h1111_2222_3333_4444;
        write = 1;
        #10 write = 0;
        $display("Wrote to Address: %h, Data: %h", addr, wdata);

        // Read previous sector (expect hit)
        addr = 32'h0000_0000;
        read = 1;
        #10 read = 0;
        if (hit) 
            $display("Cache Hit! Read Data: %h", rdata);
        else
            $display("Cache Miss! Read Data: %h", rdata);

        // Read new sector (expect hit)
        addr = 32'h0000_0010;
        read = 1;
        #10 read = 0;
        if (hit) 
            $display("Cache Hit! Read Data: %h", rdata);
        else
            $display("Cache Miss! Read Data: %h", rdata);

        // Write to a new superblock, causing eviction
        addr = 32'h1000_0000;
        wdata = 64'h5555_6666_7777_8888;
        write = 1;
        #10 write = 0;
        $display("Wrote to New Superblock Address: %h, Data: %h", addr, wdata);

        // Read old address (expect miss if eviction happened)
        addr = 32'h0000_0000;
        read = 1;
        #10 read = 0;
        if (hit) 
            $display("Cache Hit! Read Data: %h", rdata);
        else
            $display("Cache Miss! Data Evicted.");

        // Finish simulation
        #20;
        $display("Testbench complete.");
        $stop;
    end

endmodule
