library verilog;
use verilog.vl_types.all;
entity packing_and_shifting is
    generic(
        TOTAL_WIDTH     : integer := 136;
        TOTAL_BITS_COMPRESSED: integer := 34;
        CACHE_LINE      : integer := 64;
        WORD_WIDTH      : integer := 32;
        SHIFT_WIDTH     : integer := 68;
        WORD2_LENGTH    : integer := 6;
        TOTAL_LENGTH    : integer := 7;
        DICT_WORD       : integer := 16;
        OUT_SHIFT_BIT   : integer := 7
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_store_flag    : in     vl_logic;
        i_output_flag   : in     vl_logic;
        i_fill_flag     : in     vl_logic;
        i_stop_flag     : in     vl_logic;
        i_code1         : in     vl_logic_vector(2 downto 0);
        i_code2         : in     vl_logic_vector(2 downto 0);
        i_total_length  : in     vl_logic_vector;
        i_out_shift     : in     vl_logic_vector;
        i_word2_length  : in     vl_logic_vector;
        i_word1         : in     vl_logic_vector;
        i_word2         : in     vl_logic_vector;
        i_backup_buffer : in     vl_logic_vector;
        i_idx1          : in     vl_logic_vector;
        i_idx2          : in     vl_logic_vector;
        o_mux_array2    : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_BITS_COMPRESSED : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of WORD_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORD2_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of OUT_SHIFT_BIT : constant is 1;
end packing_and_shifting;
