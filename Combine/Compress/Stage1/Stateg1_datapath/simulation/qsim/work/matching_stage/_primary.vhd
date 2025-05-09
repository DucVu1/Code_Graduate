library verilog;
use verilog.vl_types.all;
entity matching_stage is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector(63 downto 0);
        o_location2     : out    vl_logic_vector(3 downto 0);
        o_location4     : out    vl_logic_vector(3 downto 0);
        o_codeded1      : out    vl_logic_vector(11 downto 0);
        o_codeded3      : out    vl_logic_vector(11 downto 0);
        o_dict_full     : out    vl_logic;
        o_length1       : out    vl_logic_vector(5 downto 0);
        o_length2       : out    vl_logic_vector(5 downto 0);
        o_code1         : out    vl_logic_vector(2 downto 0);
        o_code2         : out    vl_logic_vector(2 downto 0);
        dictionary_data : out    vl_logic_vector(511 downto 0)
    );
end matching_stage;
