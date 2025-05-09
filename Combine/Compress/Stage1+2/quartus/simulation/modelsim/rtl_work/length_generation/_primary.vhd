library verilog;
use verilog.vl_types.all;
entity length_generation is
    generic(
        CACHE_LINE      : integer := 128;
        WORD_SIZE       : integer := 64
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_type_matched2 : in     vl_logic_vector(3 downto 0);
        i_type_matched1 : in     vl_logic_vector(1 downto 0);
        i_match_s       : in     vl_logic_vector(1 downto 0);
        o_store_flag    : out    vl_logic;
        o_shift_amount  : out    vl_logic_vector(6 downto 0);
        o_send_back     : out    vl_logic;
        o_encoded1      : out    vl_logic_vector(2 downto 0);
        o_encoded2      : out    vl_logic_vector(2 downto 0);
        o_length1       : out    vl_logic_vector(5 downto 0);
        o_length2       : out    vl_logic_vector(5 downto 0);
        o_total_length  : out    vl_logic_vector(6 downto 0);
        o_fill_flag     : out    vl_logic;
        o_output_flag   : out    vl_logic;
        o_fill_ctrl     : out    vl_logic;
        o_stop_flag     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of WORD_SIZE : constant is 1;
end length_generation;
