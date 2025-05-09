library verilog;
use verilog.vl_types.all;
entity zzzz_zzzx_comparator2 is
    generic(
        WIDTH           : integer := 32;
        WORDS           : integer := 16;
        BYTE            : integer := 8
    );
    port(
        in_word         : in     vl_logic_vector(31 downto 0);
        dictionary_i    : in     vl_logic_vector;
        dictionary_index: out    vl_logic_vector(5 downto 0);
        matched_byte    : out    vl_logic_vector(7 downto 0);
        out_code        : out    vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORDS : constant is 1;
    attribute mti_svvh_generic_type of BYTE : constant is 1;
end zzzz_zzzx_comparator2;
