library verilog;
use verilog.vl_types.all;
entity tb_compressor_decompressor is
    generic(
        WIDTH           : integer := 64;
        WORD            : integer := 32;
        CACHE_LINE      : integer := 128;
        SETUP_WAIT      : integer := 0
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of SETUP_WAIT : constant is 1;
end tb_compressor_decompressor;
