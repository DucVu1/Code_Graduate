library verilog;
use verilog.vl_types.all;
entity padding_module is
    port(
        i_word          : in     vl_logic_vector(127 downto 0);
        i_reset         : in     vl_logic;
        i_padd_amount   : in     vl_logic_vector(7 downto 0);
        o_word          : out    vl_logic_vector(127 downto 0)
    );
end padding_module;
