library verilog;
use verilog.vl_types.all;
entity decompressor_tb is
    generic(
        WIDTH_DATA_IN   : integer := 128;
        WIDTH128        : integer := 128;
        WIDTH196        : integer := 196;
        CODE            : integer := 2;
        WORD            : integer := 16;
        SIZE            : integer := 8;
        WIDTH           : integer := 32;
        LENGTH          : integer := 6
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_DATA_IN : constant is 1;
    attribute mti_svvh_generic_type of WIDTH128 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH196 : constant is 1;
    attribute mti_svvh_generic_type of CODE : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of SIZE : constant is 1;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of LENGTH : constant is 1;
end decompressor_tb;
