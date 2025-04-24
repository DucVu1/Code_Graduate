library verilog;
use verilog.vl_types.all;
entity comparator is
    port(
        i_len_r         : in     vl_logic_vector(7 downto 0);
        o_comp_signal   : out    vl_logic
    );
end comparator;
