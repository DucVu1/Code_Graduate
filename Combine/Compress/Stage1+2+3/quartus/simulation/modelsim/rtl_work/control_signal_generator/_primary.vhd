library verilog;
use verilog.vl_types.all;
entity control_signal_generator is
    port(
        i_type_matched2 : in     vl_logic_vector(1 downto 0);
        i_match_s1      : in     vl_logic;
        i_match_s3      : in     vl_logic;
        i_type_matched4 : in     vl_logic_vector(1 downto 0);
        o_wr_control    : out    vl_logic_vector(1 downto 0)
    );
end control_signal_generator;
