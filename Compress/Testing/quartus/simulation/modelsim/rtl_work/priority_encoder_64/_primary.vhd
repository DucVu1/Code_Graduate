library verilog;
use verilog.vl_types.all;
entity priority_encoder_64 is
    port(
        vec             : in     vl_logic_vector(63 downto 0);
        index           : out    vl_logic_vector(5 downto 0)
    );
end priority_encoder_64;
