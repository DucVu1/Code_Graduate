library verilog;
use verilog.vl_types.all;
entity code_concatenator is
    generic(
        DATA_WIDTH      : integer := 32;
        TOTAL_BITS      : integer := 34;
        TOTAL_WORDS     : integer := 16
    );
    port(
        i_dict_idx      : in     vl_logic_vector(3 downto 0);
        i_code          : in     vl_logic_vector(2 downto 0);
        i_word          : in     vl_logic_vector;
        o_compressed_word: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_BITS : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WORDS : constant is 1;
end code_concatenator;
