library verilog;
use verilog.vl_types.all;
entity barrel_shifter_d2 is
    generic(
        WIDTH           : integer := 196;
        I_WIDTH         : integer := 128;
        SHIFT_BIT       : integer := 7
    );
    port(
        i_comp_flag     : in     vl_logic;
        i_word          : in     vl_logic_vector;
        i_amt           : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of I_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_BIT : constant is 1;
end barrel_shifter_d2;
