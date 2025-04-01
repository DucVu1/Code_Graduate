library verilog;
use verilog.vl_types.all;
entity stage1and2and3 is
    generic(
        WIDTH           : integer := 64;
        DICT_ENTRY      : integer := 16;
        DICT_WORD       : integer := 32;
        WORD            : integer := 32;
        CACHE_LINE      : integer := 128;
        TOTAL_WIDTH     : integer := 136;
        TOTAL_BITS_COMPRESSED: integer := 34;
        WORD2_LENGTH    : integer := 6;
        TOTAL_LENGTH    : integer := 7;
        DICT_WORD2      : integer := 16;
        OUT_SHIFT_BIT   : integer := 7
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_mux_array2    : out    vl_logic_vector;
        dictionary_data : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_BITS_COMPRESSED : constant is 1;
    attribute mti_svvh_generic_type of WORD2_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD2 : constant is 1;
    attribute mti_svvh_generic_type of OUT_SHIFT_BIT : constant is 1;
end stage1and2and3;
