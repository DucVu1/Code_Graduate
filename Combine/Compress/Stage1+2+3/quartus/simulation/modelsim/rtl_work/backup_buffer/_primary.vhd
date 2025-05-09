library verilog;
use verilog.vl_types.all;
entity backup_buffer is
    generic(
        WIDTH           : integer := 128;
        WORD_WIDTH      : integer := 64
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_backup_buffer : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WORD_WIDTH : constant is 1;
end backup_buffer;
