library verilog;
use verilog.vl_types.all;
entity length_generator is
    generic(
        CODE            : integer := 2;
        LENGTH          : integer := 6
    );
    port(
        i_reset         : in     vl_logic;
        i_codes         : in     vl_logic_vector;
        i_codes_bak     : in     vl_logic_vector;
        o_length1       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CODE : constant is 1;
    attribute mti_svvh_generic_type of LENGTH : constant is 1;
end length_generator;
