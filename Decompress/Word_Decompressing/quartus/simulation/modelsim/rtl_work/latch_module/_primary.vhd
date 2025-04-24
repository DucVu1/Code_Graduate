library verilog;
use verilog.vl_types.all;
entity latch_module is
    generic(
        WIDTH           : integer := 128
    );
    port(
        i_reset         : in     vl_logic;
        i_enable        : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end latch_module;
