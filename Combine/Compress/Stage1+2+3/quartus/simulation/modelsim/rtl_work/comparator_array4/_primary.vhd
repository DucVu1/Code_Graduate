library verilog;
use verilog.vl_types.all;
entity comparator_array4 is
    generic(
        INPUT_WORD      : integer := 32;
        DICT_ENTRY      : integer := 16;
        DICT_WORD       : integer := 32
    );
    port(
        i_input         : in     vl_logic_vector;
        i_first_word    : in     vl_logic_vector;
        i_dict          : in     vl_logic_vector;
        i_match_s1      : in     vl_logic_vector(1 downto 0);
        o_type_matched  : out    vl_logic_vector(1 downto 0);
        o_align         : out    vl_logic;
        o_location      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INPUT_WORD : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
end comparator_array4;
