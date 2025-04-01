module mux2_1#(parameter N = 32)(
	input logic [N-1:0] i_a, i_b,
	input logic i_option,
	output logic [N-1:0] o_word
);
always_comb begin: Multiplexor_2_1
	if(i_option) begin 
		o_word = i_b;
		end
	else begin 
		o_word = i_a;
		end
	end
endmodule
