module fifo #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 32)(
	input logic clk, reset,
	input logic wr, rd,
	input logic [DATA_WIDTH - 1:0] w_data,
	output logic [DATA_WIDTH - 1:0] r_data,
	output logic full, empty
);
logic [ADDR_WIDTH - 1: 0] r_addr, w_addr;
//logic [DATA_WIDTH - 1: 0] read;
logic w_en;
assign w_en = ~full & wr; 

reg_file  #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) reg_file (.clk(clk), .w_en(w_en), .w_data(w_data), .w_addr(w_addr), .r_data(r_data), .r_addr(r_addr));
fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) ctrl (.clk(clk), .reset(reset), .wr(wr), .rd(rd), .full(full), .empty(empty), .w_addr(w_addr), .r_addr(r_addr));

/*always_ff @(posedge clk) begin 
	if (rd) 
		r_data <= read;
end*/
endmodule
