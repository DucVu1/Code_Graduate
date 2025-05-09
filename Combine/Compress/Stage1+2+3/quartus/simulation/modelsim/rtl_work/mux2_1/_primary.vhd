library verilog;
use verilog.vl_types.all;
entity mux2_1 is
    generic(
        N               : integer := 32
    );
    port(
        i_a             : in     vl_logic_vector;
        i_b             : in     vl_logic_vector;
        i_option        : in     vl_logic;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
end mux2_1;
