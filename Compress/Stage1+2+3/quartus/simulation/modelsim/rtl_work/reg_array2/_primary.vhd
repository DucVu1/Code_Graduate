library verilog;
use verilog.vl_types.all;
entity reg_array2 is
    generic(
        TOTAL_WIDTH     : integer := 128
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_enable        : in     vl_logic;
        i_word          : in     vl_logic_vector(63 downto 0);
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
end reg_array2;
