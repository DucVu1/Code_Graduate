library verilog;
use verilog.vl_types.all;
entity compare_value is
    generic(
        WIDTH           : integer := 3
    );
    port(
        i_a             : in     vl_logic_vector;
        i_b             : in     vl_logic_vector;
        o_a_gt_b        : out    vl_logic;
        o_equal         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end compare_value;
