library verilog;
use verilog.vl_types.all;
entity matching_length_reg is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_type_matched2 : in     vl_logic_vector(3 downto 0);
        i_type_matched1 : in     vl_logic_vector(1 downto 0);
        i_match_s       : in     vl_logic_vector(1 downto 0);
        o_type_matched2 : out    vl_logic_vector(3 downto 0);
        o_type_matched1 : out    vl_logic_vector(1 downto 0);
        o_match_s       : out    vl_logic_vector(1 downto 0)
    );
end matching_length_reg;
