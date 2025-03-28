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
        o_shift_amount  : out    vl_logic_vector(6 downto 0);
        o_send_back     : out    vl_logic;
        dictionary_data : out    vl_logic_vector(511 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
end stage1and2;
