library verilog;
use verilog.vl_types.all;
entity unpacker is
    generic(
        WIDTH           : integer := 128;
        CODE            : integer := 2;
        WORD            : integer := 16;
        LENGTH          : integer := 6;
        WIDTH196        : integer := 196
    );
    port(
        i_clk           : in     vl_logic;
        i_decompressor_en: in     vl_logic;
        i_reset         : in     vl_logic;
        i_update        : in     vl_logic;
        i_data          : in     vl_logic_vector;
        o_first_code    : out    vl_logic_vector;
        o_first_code_bak: out    vl_logic_vector;
        o_idx1          : out    vl_logic_vector;
        o_second_code   : out    vl_logic_vector;
        o_second_code_bak: out    vl_logic_vector;
        o_idx2          : out    vl_logic_vector;
        o_first_length  : out    vl_logic_vector;
        o_second_length : out    vl_logic_vector;
        o_remain_length : out    vl_logic_vector;
        o_total_length_n: out    vl_logic_vector;
        o_remain_length_n: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CODE : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of LENGTH : constant is 1;
    attribute mti_svvh_generic_type of WIDTH196 : constant is 1;
end unpacker;
