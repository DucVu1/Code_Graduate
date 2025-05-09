library verilog;
use verilog.vl_types.all;
entity length_accumulator is
    generic(
        CACHE_LINE      : integer := 128;
        WORD_SIZE       : integer := 64
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_total_length  : in     vl_logic_vector(6 downto 0);
        o_store_flag    : out    vl_logic;
        o_shift_amount  : out    vl_logic_vector(7 downto 0);
        o_fill_flag     : out    vl_logic;
        o_output_flag   : out    vl_logic;
        o_fill_ctrl     : out    vl_logic;
        o_stop_flag     : out    vl_logic;
        o_done_flag     : out    vl_logic;
        o_finish_final  : out    vl_logic;
        o_push_flag     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of WORD_SIZE : constant is 1;
end length_accumulator;
