library verilog;
use verilog.vl_types.all;
entity priority_encoder_64 is
    port(
        vec             : in     vl_logic_vector(63 downto 0);
        dict_word_index : out    vl_logic_vector(3 downto 0);
        local_byte_index: out    vl_logic_vector(1 downto 0)
    );
end priority_encoder_64;
