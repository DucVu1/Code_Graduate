library verilog;
use verilog.vl_types.all;
entity reg_out is
    generic(
        WIDTH           : integer := 32;
        O_WIDTH         : integer := 128
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word1         : in     vl_logic_vector;
        i_word2         : in     vl_logic_vector;
        o_word          : out    vl_logic_vector;
        o_count         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of O_WIDTH : constant is 1;
end reg_out;
