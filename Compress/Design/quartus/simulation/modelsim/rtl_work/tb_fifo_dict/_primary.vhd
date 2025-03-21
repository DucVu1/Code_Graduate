library verilog;
use verilog.vl_types.all;
entity tb_fifo_dict is
    generic(
        DATA_WIDTH      : integer := 32;
        WORDS_PER_ENTRY : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORDS_PER_ENTRY : constant is 1;
end tb_fifo_dict;
