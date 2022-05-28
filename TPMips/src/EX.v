module EX
	#(
		parameter NB_DATA     = 32,
		parameter NB_REG      = 5,
		parameter NB_FUNCTION = 6,
		parameter NB_ALU_OP   = 3, 
		parameter NB_EX_CTRL = 7,
		parameter NB_OP_ALU   = 4
	)
	(
		input wire [NB_FUNCTION-1:0] function_i,		
		input wire [NB_DATA-1:0] data_ra_i,
		input wire [NB_DATA-1:0] data_rb_i,
		input wire [NB_DATA-1:0] data_inm_i,

		input wire [NB_REG-1:0]	shamt_i,
		input wire [NB_REG-1:0]	rs_i, rt_i, rd_i,

		input wire [NB_EX_CTRL-1:0] EX_control_i,

		input wire [NB_REG-1:0] EX_MEM_write_reg_i, // addres de reg a escribir
		input wire [NB_REG-1:0] MEM_WB_write_reg_i,

		input wire EX_MEM_reg_write_i, //escritura en reg ?
		input wire MEM_WB_reg_write_i,

		input wire [NB_DATA-1:0] EX_MEM_result_alu_i,
		input wire [NB_DATA-1:0] MEM_WB_data_i,
		
		output wire [NB_DATA-1:0] data_write_mem_o,
		output wire [NB_REG-1:0] write_register_o,
		output wire [NB_DATA-1:0] result_alu_o
	);
	
	wire [NB_DATA-1:0] conex_input_alu_A, conex_input_alu_B; //entradas a la alu
	wire [NB_DATA-1:0] out_mux_forwardA, out_mux_forwardB;
	wire [1:0] src_forwardA;
	wire [1:0] src_forwardB;

	assign data_write_mem_o = out_mux_forwardB;

	wire [3:0] cod_op_alu;

	Alu alu
	(
		.A(conex_input_alu_A),
		.B(conex_input_alu_B),
		.Op(cod_op_alu),
		.result_o(result_alu_o)		
	);

	alu_control alu_control
	(
		.function_i(function_i),
		.alu_op_i(EX_control_i[2:0]),
		.alu_op_o(cod_op_alu)
	);	

	/* este mux es manejado por la unidad de forward*/
	Mux3_1 mux_forwardA
	(
		.op1_i(data_ra_i), //00
		.op2_i(EX_MEM_result_alu_i), //01
		.op3_i(MEM_WB_data_i), //10
		.sel_i(src_forwardA),
		.data_o(out_mux_forwardA)
	);
	Mux3_1 mux_forwardB
	(
		.op1_i(data_rb_i),
		.op2_i(EX_MEM_result_alu_i),
		.op3_i(MEM_WB_data_i),
		.sel_i(src_forwardB),
		.data_o(out_mux_forwardB)
	);

	Mux2_1 #(.NB_DATA(32)) mux_alu_src_A	
	(
		.inA({{27'b0},shamt_i}), // sel = 1
		.inB(out_mux_forwardA), 
		.sel(EX_control_i[6]),
		.out(conex_input_alu_A)
	);

	Mux2_1 #(.NB_DATA(32)) mux_alu_src_B	
	(
		.inA(out_mux_forwardB), // sel = 1
		.inB(data_inm_i),
		.sel(EX_control_i[5]),
		.out(conex_input_alu_B)
	);
	/* check este por registro 31*/
	Mux3_1#(.NB_DATA(NB_REG)) mux_reg_dest
	(
		.op1_i(rt_i), // tipo I
		.op2_i(rd_i), // tipo R
		.op3_i(5'd31), // jumps and link		
		.sel_i(EX_control_i[4:3]),
		.data_o(write_register_o)
	);

	unit_forward unit_forward
	(
		.ID_EX_rs_i(rs_i),
		.ID_EX_rt_i(rt_i),

		.EX_MEM_write_reg_i(EX_MEM_write_reg_i),
		.MEM_WB_write_reg_i(MEM_WB_write_reg_i),
		.EX_MEM_reg_write_i(EX_MEM_reg_write_i),
		.MEM_WB_reg_write_i(MEM_WB_reg_write_i),

		.forward_A_o(src_forwardA),
		.forward_B_o(src_forwardB) 
	);

endmodule