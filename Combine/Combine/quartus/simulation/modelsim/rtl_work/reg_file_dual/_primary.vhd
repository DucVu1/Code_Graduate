library verilog;
use verilog.vl_types.all;
entity reg_file_dual is
    generic(
        DATA_N          : integer := 32;
        SIZE            : integer := 8;
        TOTAL_WORDS     : integer := 16
    );
    port(
        clk_i           : in     vl_logic;
        i_reset         : in     vl_logic;
        wr              : in     vl_logic;
        wr2             : in     vl_logic;
        wr3             : in     vl_logic;
        wr4             : in     vl_logic;
        wr_addr         : in     vl_logic_vector;
        wr_addr2        : in     vl_logic_vector;
        w_data          : in     vl_logic_vector;
        w_data2         : in     vl_logic_vector;
        w_data3         : in     vl_logic_vector;
        w_data4         : in     vl_logic_vector;
        o_data          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_N : constant is 1;
    attribute mti_svvh_generic_type of SIZE : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WORDS : constant is 1;
end reg_file_dual;
