library verilog;
use verilog.vl_types.all;
entity comparator is
    generic(
        N               : integer := 32
    );
    port(
        input_i         : in     vl_logic_vector;
        compare_value_i : in     vl_logic_vector;
        match_o         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
end comparator;
