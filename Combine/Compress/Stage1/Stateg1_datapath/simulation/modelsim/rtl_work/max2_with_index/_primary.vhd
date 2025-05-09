library verilog;
use verilog.vl_types.all;
entity max2_with_index is
    generic(
        WIDTH           : integer := 2
    );
    port(
        i_a             : in     vl_logic_vector;
        i_b             : in     vl_logic_vector;
        idxA            : in     vl_logic_vector(3 downto 0);
        idxB            : in     vl_logic_vector(3 downto 0);
        alignA          : in     vl_logic;
        alignB          : in     vl_logic;
        max_out         : out    vl_logic_vector;
        max_idx         : out    vl_logic_vector(3 downto 0);
        max_align       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end max2_with_index;
