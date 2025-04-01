library verilog;
use verilog.vl_types.all;
entity max_selector is
    generic(
        WIDTH_MATCH_BYTE: integer := 2;
        NO_WORD         : integer := 16
    );
    port(
        i_no_byte_matched: in     vl_logic_vector;
        i_align         : in     vl_logic_vector;
        max_val         : out    vl_logic_vector;
        max_idx         : out    vl_logic_vector;
        max_align       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_MATCH_BYTE : constant is 1;
    attribute mti_svvh_generic_type of NO_WORD : constant is 1;
end max_selector;
