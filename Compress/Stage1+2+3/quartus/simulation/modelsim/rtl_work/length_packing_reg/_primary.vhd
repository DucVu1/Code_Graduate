library verilog;
use verilog.vl_types.all;
entity length_packing_reg is
    generic(
        WIDTH           : integer := 64
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_store_flag    : in     vl_logic;
        i_shift_amount  : in     vl_logic_vector(7 downto 0);
        i_encoded1      : in     vl_logic_vector(2 downto 0);
        i_encoded2      : in     vl_logic_vector(2 downto 0);
        i_length1       : in     vl_logic_vector(5 downto 0);
        i_length2       : in     vl_logic_vector(5 downto 0);
        i_location2     : in     vl_logic_vector(3 downto 0);
        i_location4     : in     vl_logic_vector(3 downto 0);
        i_total_length  : in     vl_logic_vector(6 downto 0);
        i_fill_flag     : in     vl_logic;
        i_output_flag   : in     vl_logic;
        i_fill_ctrl     : in     vl_logic;
        i_stop_flag     : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_store_flag    : out    vl_logic;
        o_shift_amount  : out    vl_logic_vector(7 downto 0);
        o_encoded1      : out    vl_logic_vector(2 downto 0);
        o_encoded2      : out    vl_logic_vector(2 downto 0);
        o_length1       : out    vl_logic_vector(5 downto 0);
        o_length2       : out    vl_logic_vector(5 downto 0);
        o_location2     : out    vl_logic_vector(3 downto 0);
        o_location4     : out    vl_logic_vector(3 downto 0);
        o_total_length  : out    vl_logic_vector(6 downto 0);
        o_fill_flag     : out    vl_logic;
        o_output_flag   : out    vl_logic;
        o_fill_ctrl     : out    vl_logic;
        o_stop_flag     : out    vl_logic;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end length_packing_reg;
