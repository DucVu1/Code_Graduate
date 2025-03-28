library verilog;
use verilog.vl_types.all;
entity or_gate is
    generic(
        I_WIDTH1        : integer := 68;
        I_WIDTH2        : integer := 34;
        TOTAL_WIDTH     : integer := 136
    );
    port(
        i_first_word    : in     vl_logic_vector;
        i_second_word   : in     vl_logic_vector;
        i_reg_array     : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of I_WIDTH1 : constant is 1;
    attribute mti_svvh_generic_type of I_WIDTH2 : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
end or_gate;
