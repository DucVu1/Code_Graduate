module unpacker #(
  parameter WIDTH  = 128,
  parameter CODE   = 2,
  parameter WORD   = 16,
  parameter LENGTH = 6,
  parameter WIDTH196 = 196
)(
  input  logic                       i_clk,
  input  logic                       i_decompressor_en,
  input  logic                       i_reset,
  input  logic                       i_update,
  input  logic [WIDTH196 - 1 : 0]    i_data,
  output logic [CODE - 1 : 0]        o_first_code,
  output logic [CODE - 1 : 0]        o_first_code_bak,
  output logic [$clog2(WORD)-1 : 0]  o_idx1,
  output logic [CODE - 1 : 0]        o_second_code,
  output logic [CODE - 1 : 0]        o_second_code_bak,
  output logic [$clog2(WORD)-1 : 0]  o_idx2,
  output logic [LENGTH - 1 : 0]      o_first_length,
  output logic [LENGTH - 1 : 0]      o_second_length,
  output logic [$clog2(WIDTH) : 0]   o_remain_length,
  output logic [$clog2(WIDTH)-1:0]   o_total_length_n,
  output logic [$clog2(WIDTH) : 0]   o_remain_length_n
);


//logic [WIDTH-1:0] shifted_data_n, shifted_data_r;
logic [WIDTH196-1:0] shifted_data_n, shifted_data_r;
//logic [$clog2(WIDTH)-1:0] total_length_reg;
logic [$clog2(WIDTH)-1:0] total_length_next;
//logic [WIDTH-1:0] second_shifted;
logic [WIDTH196-1:0] second_shifted;
logic test_first_code;
logic test_second_code;
// logic reg_reset;
// logic reg_reset2;

// always_ff @(posedge i_clk or negedge i_reset) begin
//   if (~i_reset) begin
//     reg_reset <= '1;
// 	 reg_reset2 <= reg_reset;
//   end else begin
//     reg_reset <= '0;
// 	 reg_reset2 <= reg_reset;
//   end
// end

assign o_total_length_n = total_length_next;

always_comb begin
  if(~i_reset) begin
    shifted_data_n = '0;
    second_shifted = '0;
    total_length_next = '0;
    test_first_code = '0;
    test_second_code = '0;
    o_remain_length_n = 8'd0;
  end else begin
    if(i_decompressor_en) total_length_next = o_first_length + o_second_length;
    else total_length_next = '0;
    if(i_update) begin
    //shifted_data_n = i_data >> total_length_next;
    shifted_data_n = i_data;
    second_shifted = shifted_data_r >> o_first_length;
    test_first_code = &shifted_data_r[1:0];
    test_second_code = &second_shifted[1:0];
    o_remain_length_n = o_remain_length - total_length_next + 8'd128; //number of bits remain after this cycle
    end else begin
    shifted_data_n = shifted_data_r >> total_length_next;
    second_shifted = shifted_data_r >> o_first_length;
    test_first_code = &shifted_data_r[1:0];
    test_second_code = &second_shifted[1:0];
    o_remain_length_n = o_remain_length - total_length_next;
    end
  end
end

// always_ff @(posedge i_clk or negedge i_reset) begin : proc_update_signal
//  if(~i_reset) begin
//   update_signal <= '0;
//  end else begin
//   if(o_remain_length_)
//  end
// end: proc_update_signal

always_ff @(posedge i_clk or negedge i_reset) begin : proc_update
  if (~i_reset) begin
    //total_length_reg <= '0;
    shifted_data_r <= '0;
    o_remain_length <= '0;
  end else begin
    // if(i_update) o_remain_length <= o_remain_length_n + 8'd128;
    o_remain_length <= o_remain_length_n;
    //total_length_reg <= total_length_next;
    shifted_data_r <= shifted_data_n;
  end
end

always_comb begin : proc_first
  if (~i_reset) begin
    o_first_code      = '0;
    o_first_code_bak  = '0;
    o_idx1            = '0;
  end else begin
    o_first_code = shifted_data_r[1:0];
    if (test_first_code) begin
      o_first_code_bak = shifted_data_r[3:2];
      o_idx1 = shifted_data_r[7:4];
    end else begin
      o_first_code_bak = '0;
      o_idx1 = shifted_data_r[5:2];
    end
  end
end

length_generator #(
  .CODE(CODE),
  .LENGTH(LENGTH)
) length_gen1 (
  .i_reset(i_reset),
  .i_codes(o_first_code),
  .i_codes_bak(o_first_code_bak),
  .o_length1(o_first_length)
);

always_comb begin : proc_second
  if (~i_reset) begin
    o_second_code     = '0;
    o_second_code_bak = '0;
    o_idx2            = '0;
  end else begin
    o_second_code = second_shifted[1:0];
    if (test_second_code) begin
      o_second_code_bak = second_shifted[3:2];
      o_idx2 = second_shifted[7:4];
    end else begin
      o_second_code_bak = '0;
      o_idx2 = second_shifted[5:2];
    end
  end
end

length_generator #(
  .CODE(CODE),
  .LENGTH(LENGTH)
) length_gen2 (
  .i_reset(i_reset),
  .i_codes(o_second_code),
  .i_codes_bak(o_second_code_bak),
  .o_length1(o_second_length)
);

endmodule
