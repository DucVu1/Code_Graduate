library verilog;
use verilog.vl_types.all;
entity word_length_genetator is
    port(
        i_type_matched1 : in     vl_logic;
        i_match_s1      : in     vl_logic;
        i_type_matched2 : in     vl_logic_vector(1 downto 0);
        o_length        : out    vl_logic_vector(5 downto 0);
        o_encoded       : out    vl_logic_vector(2 downto 0)
    );
end word_length_genetator;
