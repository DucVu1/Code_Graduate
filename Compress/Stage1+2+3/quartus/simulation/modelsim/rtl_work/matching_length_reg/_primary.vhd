library verilog;
use verilog.vl_types.all;
entity matching_length_reg is
    generic(
        WIDTH           : integer := 64
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        i_type_matched2 : in     vl_logic_vector(3 downto 0);
        i_type_matched1 : in     vl_logic_vector(1 downto 0);
        i_location2     : in     vl_logic_vector(3 downto 0);
        i_location4     : in     vl_logic_vector(3 downto 0);
        i_match_s       : in     vl_logic_vector(1 downto 0);
        o_type_matched2 : out    vl_logic_vector(3 downto 0);
        o_type_matched1 : out    vl_logic_vector(1 downto 0);
        o_match_s       : out    vl_logic_vector(1 downto 0);
        o_word          : out    vl_logic_vector;
        o_location2     : out    vl_logic_vector(3 downto 0);
        o_location4     : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end matching_length_reg;
