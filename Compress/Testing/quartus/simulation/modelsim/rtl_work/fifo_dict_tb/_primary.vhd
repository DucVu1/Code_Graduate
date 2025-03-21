library verilog;
use verilog.vl_types.all;
entity fifo_dict_tb is
    generic(
        DATA_WIDTH      : integer := 32;
        WORDS_PER_ENTRY : integer := 16;
        ENTRY_WIDTH     : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORDS_PER_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of ENTRY_WIDTH : constant is 3;
end fifo_dict_tb;
