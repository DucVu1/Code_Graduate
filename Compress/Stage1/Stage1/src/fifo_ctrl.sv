module fifo_ctrl #(parameter ADDR_WIDTH = 3)(
	input logic clk, reset, wr, rd,
	output logic full, empty, 
	output logic [ADDR_WIDTH -1: 0] w_addr,r_addr
);
logic [ADDR_WIDTH - 1:0] wr_ptr, wr_ptr_next, rd_ptr, rd_ptr_next;
logic full_next, empty_next;
always_ff @(posedge clk, posedge reset) begin
	if (reset) begin 
		wr_ptr <= 0;
		rd_ptr <= 0;
		full <= 1'b0;
		empty <= 1'b1;
	end
	else begin
		wr_ptr <= wr_ptr_next;
		rd_ptr <= rd_ptr_next;
		full <= full_next;
		empty <= empty_next;

	end
end
//circular buffer implemetation
always_comb begin 
	wr_ptr_next = wr_ptr;
	rd_ptr_next = rd_ptr;
	full_next = full;
	empty_next = empty;
	case({wr,rd})
		2'b00: begin
			wr_ptr_next = wr_ptr;
			rd_ptr_next = rd_ptr;	
		end
		2'b01: begin //read
			if (~empty) begin 
				rd_ptr_next = rd_ptr + 1'b1;
				full_next = 1'b0;
				if ((rd_ptr_next == wr_ptr))
					empty_next = 1'b1;
			end
		end
		2'b10: //write
		begin 
			if (~full) begin 
				wr_ptr_next = wr_ptr + 1'b1;
				empty_next = 1'b0;
				if ((wr_ptr_next == rd_ptr))
					full_next = 1'b1;
			end
		end
		2'b11: begin // write + read
			if (empty) begin 
				wr_ptr_next = wr_ptr;
				rd_ptr_next = rd_ptr;
			end
			else begin 	
				wr_ptr_next = wr_ptr + 1'b1;
				rd_ptr_next = rd_ptr + 1'b1;
			end 
		end
	endcase
end
assign r_addr = rd_ptr;
assign w_addr = wr_ptr;
endmodule
