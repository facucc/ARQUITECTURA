`include "parameters.vh"

module unit_branch
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [`ADDRWIDTH-1:0] inm_ext_i,
		input wire [NB_DATA-1:0] data_ra_i,
		input wire [NB_DATA-1:0] data_rb_i,
		output wire is_equal_o,
		output wire [`ADDRWIDTH-1:0] branch_address_o

	);

	assign is_equal_o = (data_ra_i == data_rb_i) ? 1'b1 : 1'b0;
	assign branch_address_o = pc_i + inm_ext_i;	

endmodule
