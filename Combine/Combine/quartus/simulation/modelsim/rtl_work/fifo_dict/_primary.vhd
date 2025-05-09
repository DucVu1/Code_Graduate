library verilog;
use verilog.vl_types.all;
entity fifo_dict is
    generic(
        DATA_WIDTH      : integer := 32;
        TOTAL_WORDS     : integer := 16;
        SIZE            : integer := 8
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        wr              : in     vl_logic;
        wr2             : in     vl_logic;
        wr3             : in     vl_logic;
        wr4             : in     vl_logic;
        w_data          : in     vl_logic_vector;
        w_data2         : in     vl_logic_vector;
        w_data3         : in     vl_logic_vector;
        w_data4         : in     vl_logic_vector;
        o_data          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WORDS : constant is 1;
    attribute mti_svvh_generic_type of SIZE : constant is 1;
end fifo_dict;
