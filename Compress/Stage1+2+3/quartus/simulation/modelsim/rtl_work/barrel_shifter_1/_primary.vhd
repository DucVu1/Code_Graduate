library verilog;
use verilog.vl_types.all;
entity barrel_shifter_1 is
    generic(
        WIDTH           : integer := 68;
        SHIFT_BIT       : integer := 6
    );
    port(
        data            : in     vl_logic_vector;
        type_shift      : in     vl_logic;
        amt             : in     vl_logic_vector;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_BIT : constant is 1;
end barrel_shifter_1;
