library verilog;
use verilog.vl_types.all;
entity three_input_carry_save_adder is
    generic(
        WORD_LENGTH     : integer := 6;
        REMAIN_LENGTH   : integer := 8;
        RESULT_LENGTH   : integer := 7
    );
    port(
        i_first_len     : in     vl_logic_vector;
        i_second_len    : in     vl_logic_vector;
        i_remain_len    : in     vl_logic_vector;
        o_len_r         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WORD_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of REMAIN_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of RESULT_LENGTH : constant is 1;
end three_input_carry_save_adder;
