library verilog;
use verilog.vl_types.all;
entity control_signal_generator is
    port(
        i_first_code    : in     vl_logic_vector(1 downto 0);
        i_first_code_bak: in     vl_logic_vector(1 downto 0);
        i_second_code   : in     vl_logic_vector(1 downto 0);
        i_second_code_bak: in     vl_logic_vector(1 downto 0);
        ctrl_signal     : out    vl_logic_vector(1 downto 0)
    );
end control_signal_generator;
