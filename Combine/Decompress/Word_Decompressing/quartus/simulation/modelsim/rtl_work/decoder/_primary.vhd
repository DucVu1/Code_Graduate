library verilog;
use verilog.vl_types.all;
entity decoder is
    generic(
        CODES           : integer := 2;
        WORD            : integer := 16;
        WIDTH           : integer := 32;
        \I_WORD\        : integer := 196;
        I_WORD2         : integer := 34
    );
    port(
        i_codes         : in     vl_logic_vector;
        i_codes_bak     : in     vl_logic_vector;
        i_word          : in     vl_logic_vector;
        i_idx           : in     vl_logic_vector;
        i_dict          : in     vl_logic_vector;
        o_word          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CODES : constant is 1;
    attribute mti_svvh_generic_type of WORD : constant is 1;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of \I_WORD\ : constant is 1;
    attribute mti_svvh_generic_type of I_WORD2 : constant is 1;
end decoder;
