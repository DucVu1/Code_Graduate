library verilog;
use verilog.vl_types.all;
entity comparator_array1 is
    generic(
        WIDTH           : integer := 32
    );
    port(
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_type_matched  : out    vl_logic;
        o_match_s       : out    vl_logic;
        o_code          : out    vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end comparator_array1;
