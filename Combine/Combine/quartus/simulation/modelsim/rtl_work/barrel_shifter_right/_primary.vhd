library verilog;
use verilog.vl_types.all;
entity barrel_shifter_right is
    generic(
        WIDTH           : integer := 196
    );
    port(
        i_data          : in     vl_logic_vector;
        i_amt           : in     vl_logic_vector(6 downto 0);
        o_data          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end barrel_shifter_right;
