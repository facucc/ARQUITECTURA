

module unit_jump
	#(
		parameter NB_DATA = 32,
		parameter NB_JUMP = 26
	)
	(
		input wire [NB_JUMP-1:0] data_to_shift_i,
		input wire [3:0] pc_4_i,

		output wire [NB_DATA-1:0] jump_address_o
	);
	
	wire [NB_JUMP+1:0] conex_data_to_shift;

	shift_left2#(.NB_DATA_1(NB_JUMP),.NB_DATA_2(NB_JUMP+2)) shift_left2_jump
	(
		.data_to_shift_i(data_to_shift_i),
		.data_to_shift_o(conex_data_to_shift)
	);

	assign jump_address_o = {pc_4_i, conex_data_to_shift};

endmodule
