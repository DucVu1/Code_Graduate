library verilog;
use verilog.vl_types.all;
entity top_module_1 is
    port(
        in_word         : in     vl_logic_vector(31 downto 0);
        dictionary_i    : in     vl_logic_vector(511 downto 0);
        dict_word_index : out    vl_logic_vector(3 downto 0);
        local_byte_index: out    vl_logic_vector(1 downto 0);
        matched_byte    : out    vl_logic_vector(7 downto 0);
        out_code        : out    vl_logic_vector(11 downto 0)
    );
end top_module_1;
