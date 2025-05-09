library verilog;
use verilog.vl_types.all;
entity matching_stage_vlg_check_tst is
    port(
        dictionary_data : in     vl_logic_vector(511 downto 0);
        o_code1         : in     vl_logic_vector(2 downto 0);
        o_code2         : in     vl_logic_vector(2 downto 0);
        o_codeded1      : in     vl_logic_vector(11 downto 0);
        o_codeded3      : in     vl_logic_vector(11 downto 0);
        o_dict_full     : in     vl_logic;
        o_length1       : in     vl_logic_vector(5 downto 0);
        o_length2       : in     vl_logic_vector(5 downto 0);
        o_location2     : in     vl_logic_vector(3 downto 0);
        o_location4     : in     vl_logic_vector(3 downto 0);
        sampler_rx      : in     vl_logic
    );
end matching_stage_vlg_check_tst;
