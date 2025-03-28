library verilog;
use verilog.vl_types.all;
entity or_gate_tb is
    generic(
        I_WIDTH1        : integer := 68;
        I_WIDTH2        : integer := 34;
        TOTAL_WIDTH     : integer := 136
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of I_WIDTH1 : constant is 1;
    attribute mti_svvh_generic_type of I_WIDTH2 : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_WIDTH : constant is 1;
end or_gate_tb;
