library verilog;
use verilog.vl_types.all;
entity tb_matching_stage is
    generic(
        WIDTH           : integer := 64;
        DICT_ENTRY      : integer := 16;
        DICT_WORD       : integer := 32;
        WORD            : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end tb_matching_stage;
