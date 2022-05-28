module Mux2_1
	#(
		parameter NB_DATA = 5
	)
	(
		input wire [NB_DATA-1:0] inA,
		input wire [NB_DATA-1:0] inB,
		input wire sel,
		output wire [NB_DATA-1:0] out
	);

	assign out = (sel) ? inA : inB;

endmodule