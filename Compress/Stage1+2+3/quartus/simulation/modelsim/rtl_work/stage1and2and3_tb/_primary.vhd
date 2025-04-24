library verilog;
use verilog.vl_types.all;
entity stage1and2and3_tb is
    generic(
        WIDTH           : integer := 64;
        CACHE_LINE      : integer := 128;
        DATA_WIDTH      : integer := 32;
        DICT_ENTRY      : integer := 16;
        COMPRESSED      : integer := 34;
        TOTAL_BITS      : integer := 34;
        TOTAL_WIDTH     : integer := 136;
        SETUP_WAIT      : integer := 0;
        INTERNAL_WAIT   : integer := 0;
        HOLD_WAIT       : integer := 0;
        OUT_SHIFT_BIT   : integer := 7
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of COMPRESSED : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SETUP_WAIT : constant is 1;
    attribute mti_svvh_generic_type of INTERNAL_WAIT : constant is 1;
    attribute mti_svvh_generic_type of HOLD_WAIT : constant is 1;
    attribute mti_svvh_generic_type of OUT_SHIFT_BIT : constant is 1;
end stage1and2and3_tb;
