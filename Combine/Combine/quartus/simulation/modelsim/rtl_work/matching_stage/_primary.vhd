library verilog;
use verilog.vl_types.all;
entity matching_stage is
    generic(
        WIDTH           : integer := 64;
        DICT_ENTRY      : integer := 16;
        DICT_WORD       : integer := 32;
        WORD            : integer := 32
    );
    port(
        i_clk           : in     vl_logic;
        i_reset         : in     vl_logic;
        i_word          : in     vl_logic_vector;
        o_location2     : out    vl_logic_vector(3 downto 0);
        o_location4     : out    vl_logic_vector(3 downto 0);
        o_codeded1      : out    vl_logic_vector(11 downto 0);
        o_codeded3      : out    vl_logic_vector(11 downto 0);
        type_matched1   : out    vl_logic;
        type_matched3   : out    vl_logic;
        match_s1        : out    vl_logic;
        match_s3        : out    vl_logic;
        type_matched2   : out    vl_logic_vector(1 downto 0);
        type_matched4   : out    vl_logic_vector(1 downto 0);
        fifo_wr_signal  : out    vl_logic_vector(1 downto 0);
        first_word      : out    vl_logic_vector(31 downto 0);
        second_word     : out    vl_logic_vector(31 downto 0);
        dictionary_data : in     vl_logic_vector(511 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DICT_ENTRY : constant is 1;
    attribute mti_svvh_generic_type of DICT_WORD : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
end matching_stage;
