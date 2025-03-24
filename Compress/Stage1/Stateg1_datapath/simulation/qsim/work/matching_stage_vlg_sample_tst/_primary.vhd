library verilog;
use verilog.vl_types.all;
entity matching_stage_vlg_sample_tst is
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector(63 downto 0);
        sampler_tx      : out    vl_logic
    );
end matching_stage_vlg_sample_tst;
