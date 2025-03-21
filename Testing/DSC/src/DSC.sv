module DSC #(
    parameter TAG_WIDTH = 10,  // Tag size
    parameter INDEX_WIDTH = 4, // Cache index
    parameter BLOCK_SIZE = 64, // Cache block size (bytes)
    parameter NUM_WAYS = 2,    // 2-way set associative
    parameter NUM_SECTORS = 2  // Each tag maps to 2 blocks
)(
    input logic clk, reset,
    input logic read, write,
    input logic [31:0] addr,
    input logic [BLOCK_SIZE-1:0] wdata,
    output logic hit,
    output logic [BLOCK_SIZE-1:0] rdata
);

    // Cache Memory Declarations
    typedef struct {
        logic [TAG_WIDTH-1:0] tag;
        logic valid;
        logic dirty;
        logic [BLOCK_SIZE-1:0] data [NUM_SECTORS - 1 : 0]; // Each sector stores multiple blocks
    } cache_entry_t;

    cache_entry_t cache [NUM_WAYS][2**INDEX_WIDTH];  // 2-way set associative

    // Back Pointers for decoupling
    logic [NUM_WAYS-1:0] back_pointers [2**INDEX_WIDTH];

    logic [TAG_WIDTH-1:0] tag;
    logic [INDEX_WIDTH-1:0] index;
    logic [1:0] sector_offset;

    assign tag = addr[31:32-TAG_WIDTH];
    assign index = addr[INDEX_WIDTH+1:2];
    assign sector_offset = addr[1:0]; // Determines which sector

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 2**INDEX_WIDTH; i++) begin
                for (int j = 0; j < NUM_WAYS; j++) begin
                    cache[j][i].valid <= 0;
                    cache[j][i].dirty <= 0;
                end
            end
        end else if (read || write) begin
            // Search in all ways for a matching tag
            hit = 0;
            for (int way = 0; way < NUM_WAYS; way++) begin
                if (cache[way][index].valid && cache[way][index].tag == tag) begin
                    hit = 1;
                    if (read)
                        rdata = cache[way][index].data[sector_offset];
                    if (write) begin
                        cache[way][index].data[sector_offset] = wdata;
                        cache[way][index].dirty = 1;
                    end
                end
            end
        end
    end
endmodule
