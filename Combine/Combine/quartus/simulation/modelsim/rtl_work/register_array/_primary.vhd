library verilog;
use verilog.vl_types.all;
entity register_array is
    generic(
        TOTAL_WIDTH     : integer := 128
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
end register_array;
