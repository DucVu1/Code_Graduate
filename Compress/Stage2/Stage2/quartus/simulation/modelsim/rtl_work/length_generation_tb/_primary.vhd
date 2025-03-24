library verilog;
use verilog.vl_types.all;
entity length_generation_tb is
    generic(
        CACHE_LINE      : integer := 128;
        WORD_SIZE       : integer := 64
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CACHE_LINE : constant is 1;
    attribute mti_svvh_generic_type of WORD_SIZE : constant is 1;
end length_generation_tb;
