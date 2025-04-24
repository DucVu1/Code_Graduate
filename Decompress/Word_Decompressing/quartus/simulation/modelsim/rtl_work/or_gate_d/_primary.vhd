library verilog;
use verilog.vl_types.all;
entity or_gate_d is
    generic(
        WIDTH           : integer := 196
    );
    port(
        i_first_word    : in     vl_logic_vector;
        i_second_word   : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end or_gate_d;
