library verilog;
use verilog.vl_types.all;
entity barrel_shifter_3 is
    generic(
        TOTAL_LENGTH    : integer := 7;
        WIDTH           : integer := 136;
        O_WIDTH         : integer := 128
    );
    port(
        i_word          : in     vl_logic_vector;
        i_amt           : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TOTAL_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of O_WIDTH : constant is 1;
end barrel_shifter_3;
