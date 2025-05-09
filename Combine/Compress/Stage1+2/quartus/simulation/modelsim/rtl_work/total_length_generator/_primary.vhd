library verilog;
use verilog.vl_types.all;
entity total_length_generator is
    port(
        i_word1_length  : in     vl_logic_vector(5 downto 0);
        i_word2_length  : in     vl_logic_vector(5 downto 0);
        o_total_length  : out    vl_logic_vector(6 downto 0)
    );
end total_length_generator;
