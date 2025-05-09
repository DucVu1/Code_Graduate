library verilog;
use verilog.vl_types.all;
entity decompressor is
    generic(
        WIDTH_DATA_IN   : integer := 128;
        INPUT_LENGTH    : integer := 9;
        WORD            : integer := 16;
        WIDTH           : integer := 32;
        I_WORD          : integer := 196;
        I_WORD2         : integer := 34;
        LENGTH_CODE     : integer := 2;
        LENGTH          : integer := 6;
        REMAIN_LENGTH   : integer := 8;
        RESULT_LENGTH   : integer := 7
    );
    port(
        i_clk           : in     vl_logic;
        i_decompressor_en: in     vl_logic;
        i_reset         : in     vl_logic;
        i_update        : in     vl_logic;
        i_comp_flag     : in     vl_logic;
        i_data          : in     vl_logic_vector;
        o_data          : out    vl_logic_vector;
        ctrl_signal     : out    vl_logic_vector;
        first_word      : out    vl_logic_vector;
        second_word     : out    vl_logic_vector;
        dictionary_data : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_DATA_IN : constant is 1;
    attribute mti_svvh_generic_type of INPUT_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of I_WORD : constant is 1;
    attribute mti_svvh_generic_type of I_WORD2 : constant is 1;
    attribute mti_svvh_generic_type of LENGTH_CODE : constant is 1;
    attribute mti_svvh_generic_type of LENGTH : constant is 1;
    attribute mti_svvh_generic_type of REMAIN_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of RESULT_LENGTH : constant is 1;
end decompressor;
