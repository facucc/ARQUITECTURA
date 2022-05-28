`include "parameters.vh"

module pc_adder
	#(
		parameter NB_DATA = `ADDRWIDTH
	)
	(
		input wire [NB_DATA-1:0] next_addr_i,
		output wire [NB_DATA-1:0] next_addr_o
	);


	assign next_addr_o = next_addr_i + {{NB_DATA-1{1'b0}}, 1'b1};

endmodule
