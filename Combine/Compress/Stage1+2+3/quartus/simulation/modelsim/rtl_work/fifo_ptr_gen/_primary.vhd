library verilog;
use verilog.vl_types.all;
entity fifo_ptr_gen is
    generic(
        SIZE            : integer := 8
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        wr              : in     vl_logic;
        wr2             : in     vl_logic;
        wr_addr         : out    vl_logic_vector;
        wr_addr2        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIZE : constant is 1;
end fifo_ptr_gen;
