library verilog;
use verilog.vl_types.all;
entity fifo_dict is
    generic(
        DATA_WIDTH      : integer := 32;
        WORDS_PER_ENTRY : integer := 16
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        wr              : in     vl_logic;
        wr2             : in     vl_logic;
        w_data          : in     vl_logic_vector;
        w_data2         : in     vl_logic_vector;
        r_data          : out    vl_logic_vector;
        full            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORDS_PER_ENTRY : constant is 1;
end fifo_dict;
