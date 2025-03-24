library verilog;
use verilog.vl_types.all;
entity tb_TopModule is
    generic(
        WIDTH           : integer := 32;
        WORDS           : integer := 16;
        BYTE            : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORDS : constant is 1;
    attribute mti_svvh_generic_type of BYTE : constant is 1;
end tb_TopModule;
