library verilog;
use verilog.vl_types.all;
entity stage1and2 is
    generic(
        WIDTH           : integer := 64;
        DICT_ENTRY      : integer := 16;
        DICT_WORD       : integer := 32;
        WORD            : integer := 32;
        CACHE_LINE      : integer := 128
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_store_flag    : out    vl_logic;
        o_shift_amount  : out    vl_logic_vector(7 downto 0);
        dictionary_data : out    vl_logic_vector(511 downto 0);
        o_encoded1      : out    vl_logic_vector(2 downto 0);
        o_encoded2      : out    vl_logic_vector(2 downto 0);
        o_length1       : out    vl_logic_vector(5 downto 0);
        o_length2       : out    vl_logic_vector(5 downto 0);
        o_total_length  : out    vl_logic_vector(6 downto 0);
        o_location2     : out    vl_logic_vector(3 downto 0);
        o_location4     : out    vl_logic_vector(3 downto 0);
        o_fill_flag     : out    vl_logic;
        o_output_flag   : out    vl_logic;
        o_fill_ctrl     : out    vl_logic;
        o_stop_flag     : out    vl_logic;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
end stage1and2;
