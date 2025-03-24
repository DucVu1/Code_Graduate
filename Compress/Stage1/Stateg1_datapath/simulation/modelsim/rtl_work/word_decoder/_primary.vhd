library verilog;
use verilog.vl_types.all;
entity word_decoder is
    port(
        i_compare_vec   : in     vl_logic_vector(3 downto 0);
        o_match_count   : out    vl_logic_vector(1 downto 0);
        o_align         : out    vl_logic
    );
end word_decoder;
