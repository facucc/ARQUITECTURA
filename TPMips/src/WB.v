`include "parameters.vh"

module WB
	#(
		parameter NB_DATA = 32,
		parameter NB_MEM_TO_REG = 2
	)
	(
		input wire [NB_DATA-1:0] mem_data_i,
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [NB_DATA-1:0] inm_ext_i, // LUI

		input wire [NB_MEM_TO_REG-1:0] mem_to_reg_i,

		output wire [NB_DATA-1:0] data_o
	);


	Mux4_1 mux_wb
	(
		.op1_i(mem_data_i), // 00
		.op2_i(alu_result_i), // 01
		.op3_i({{25'b0}, pc_i}), // 10
		.op4_i(inm_ext_i), // 11
		.sel_i(mem_to_reg_i),

		.data_o(data_o)
	);

endmodule