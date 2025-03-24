module reg_file #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)(
	input logic clk, 
	input logic w_en,
	input logic [ADDR_WIDTH - 1:0] r_addr, w_addr,
	input logic [DATA_WIDTH - 1 :0] w_data,
	output logic [DATA_WIDTH -1 :0] r_data
);
logic [DATA_WIDTH - 1 :0] memory [DATA_WIDTH - 1 : 0];
always_ff @(posedge clk) begin 
	if (w_en) 
		memory[w_addr] <= w_data;
end

assign r_data = memory[r_addr];
endmodule
