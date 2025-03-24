library verilog;
use verilog.vl_types.all;
entity word_comparator is
    generic(
        INPUT_WORD      : integer := 32;
        COMPARE_WORD    : integer := 32;
        BYTE            : integer := 8
    );
    port(
        i_input         : in     vl_logic_vector;
        i_dict          : in     vl_logic_vector;
        o_no_match      : out    vl_logic_vector(1 downto 0);
        o_align         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WORD : constant is 1;
    attribute mti_svvh_generic_type of COMPARE_WORD : constant is 1;
    attribute mti_svvh_generic_type of BYTE : constant is 1;
end word_comparator;
