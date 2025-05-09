module fifo_dict #(
  parameter DATA_WIDTH = 32,
  parameter TOTAL_WORDS = 16,  
  parameter SIZE = 8           
)(
  input  logic i_clk,
  input  logic i_reset,  
  input  logic wr,     
  input  logic wr2,  
  input  logic wr3,     
  input  logic wr4,    
  input  logic [DATA_WIDTH-1:0] w_data,  
  input  logic [DATA_WIDTH-1:0] w_data2,  
  input  logic [DATA_WIDTH-1:0] w_data3,  
  input  logic [DATA_WIDTH-1:0] w_data4,  
  output logic [TOTAL_WORDS*DATA_WIDTH-1:0] o_data 
);
  logic [DATA_WIDTH - 1 :0] real_write2, real_write;
  logic [$clog2(SIZE)-1:0] wr_addr, wr_addr2;
  
  fifo_ptr_gen #(.SIZE(SIZE)) ptr_gen (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .wr(wr),
    .wr2(wr2),
    .wr3(wr3),
    .wr4(wr4),
    .wr_addr(wr_addr),
    .wr_addr2(wr_addr2)
  );
 
  reg_file_dual #(.DATA_N(DATA_WIDTH), .SIZE(SIZE), .TOTAL_WORDS(TOTAL_WORDS))
    rf_dual (
      .clk_i(i_clk),
      .i_reset(i_reset),
      .wr(wr),
      .wr2(wr2),
      .wr3(wr3),
      .wr4(wr4),
      .wr_addr(wr_addr),
      .wr_addr2(wr_addr2),
      .w_data(w_data),
      .w_data2(w_data2),
      .w_data3(w_data3),
      .w_data4(w_data4),
      .o_data(o_data)
    );
endmodule

module fifo_ptr_gen #(
  parameter SIZE = 8
)(
  input  logic i_clk,
  input  logic i_reset, 
  input  logic wr,     
  input  logic wr2,  
  input  logic wr3,     
  input  logic wr4,   
  output logic [$clog2(SIZE)-1:0] wr_addr,
  output logic [$clog2(SIZE)-1:0] wr_addr2
);
  logic [$clog2(SIZE)-1:0] current_ptr;
  logic [$clog2(SIZE)-1:0] current_ptr2;
  
  always_ff @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
      current_ptr  <= 0;
      current_ptr2 <= 0;
    end else begin
      if (wr | wr3) begin
        if (current_ptr < SIZE - 1)
          current_ptr <= current_ptr + 1'b1;
        else
          current_ptr <= 0;
      end
      if (wr2 | wr4) begin
        if (current_ptr2 < SIZE - 1)
          current_ptr2 <= current_ptr2 + 1'b1;
        else
          current_ptr2 <= 0;
      end
    end
  end
  
  assign wr_addr  = current_ptr;
  assign wr_addr2 = current_ptr2;
endmodule

module reg_file_dual #(
    parameter DATA_N = 32,
    parameter SIZE = 8,
    parameter TOTAL_WORDS = 16
)(
    input  logic              clk_i,
    input  logic              i_reset,
    input  logic              wr,       
    input  logic              wr2,  
    input  logic              wr3,       
    input  logic              wr4,      
    input  logic [$clog2(SIZE)-1:0] wr_addr,
    input  logic [$clog2(SIZE)-1:0] wr_addr2,
    input  logic [DATA_N-1:0] w_data,     
    input  logic [DATA_N-1:0] w_data2,    
    input  logic [DATA_N-1:0] w_data3,  
    input  logic [DATA_N-1:0] w_data4,  
    output logic [TOTAL_WORDS * DATA_N -1:0] o_data
);
logic [DATA_N-1:0] regs1 [0:SIZE-1];
logic [DATA_N-1:0] regs2 [0:SIZE-1];
//logic [DATA_N-1:0] w_data_real, w_data_real2; 

always_ff @(posedge clk_i) begin
if (~i_reset) begin
 for (integer i = 0; i < SIZE; i = i + 1) begin
  regs1[i] <= 32'd0;
  regs2[i] <= 32'd0;
end
  // regs1[0] <= 32'h00000000; regs2[0] <= 32'h11111111;
  // regs1[1] <= 32'h22222222; regs2[1] <= 32'h33333333;
  // regs1[2] <= 32'h44444444; regs2[2] <= 32'h55555555;
  // regs1[3] <= 32'h66666666; regs2[3] <= 32'h77777777;
  // regs1[4] <= 32'h88888888; regs2[4] <= 32'h99999999;
  // regs1[5] <= 32'hAAAAAAAA; regs2[5] <= 32'hBBBBBBBB;
  // regs1[6] <= 32'hCCCCCCCC; regs2[6] <= 32'hDDDDDDDD;
  // regs1[7] <= 32'hEEEEEEEE; regs2[7] <= 32'hFFFFFFFF; 
end else begin
 if(wr & wr2) begin
  regs2[wr_addr2] <= w_data2;
  regs1[wr_addr] <= w_data;
 end else if (wr) regs1[wr_addr] <= w_data;
 else if (wr2) regs2[wr_addr2] <= w_data2;
 else if (wr3) regs1[wr_addr] <= w_data3;
 else if (wr4) regs1[wr_addr] <= w_data4;
 else begin
  regs2[wr_addr2] <=  regs2[wr_addr2];
  regs1[wr_addr] <=  regs1[wr_addr];
  end
end
end

always @(*) begin
   o_data = {regs2[SIZE-1], regs1[SIZE-1], regs2[SIZE-2], regs1[SIZE-2],
                 regs2[SIZE-3], regs1[SIZE-3], regs2[SIZE-4], regs1[SIZE-4],
                 regs2[SIZE-5], regs1[SIZE-5], regs2[SIZE-6], regs1[SIZE-6],
                 regs2[SIZE-7], regs1[SIZE-7], regs2[0], regs1[0]};
end


endmodule

