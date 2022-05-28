`include "parameters.vh"

`define OP_CODE   31:26
`define RS_BIT    25:21
`define RT_BIT    20:16
`define RD_BIT    15:11
`define INM_BIT   15:0
`define FUNC_BIT  5:0
`define SHAMT_BIT 11:6
`define JUMP_BIT  25:0 
`define PC_BIT    31:28

module ID
	#(
		parameter NB_DATA   = 32,		
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3,		
		parameter NB_OPCODE = 6,
		parameter NB_REG    = 5				
	)
	(
		input wire clock_i,
		input wire reset_i,    
		//input wire enable_i,
		
		input wire cntl_read_debug_reg_i,
		input wire [NB_DATA-1:0] instruction_i,		
		input wire [NB_DATA-1:0] data_rw_i,
		input wire [NB_REG-1:0] write_register_i,

		input wire reg_write_i,		
		input wire [`ADDRWIDTH-1:0] pc_i,

		input wire [NB_REG-1:0] addr_debug_unit_i,

		input wire [NB_REG-1:0] EX_write_register_i, // write_register
		input wire [NB_REG-1:0] EX_rt_i, //usado por hazard detection
		input wire ID_EX_mem_read_i, //viene del latch ID_EX
		input wire EX_reg_write_i,
		input wire forward_A_i, //forward branch
		input wire forward_B_i,
		input wire [NB_DATA-1:0] data_forward_EX_MEM_i,


		output wire [NB_REG-1:0] rs_o, rt_o, rd_o,

		output wire [NB_DATA-1:0] data_ra_o,
		output wire [NB_DATA-1:0] data_rb_o,
		output wire [NB_REG-1:0] shamt_o,
		output wire [NB_DATA-1:0] inm_ext_o,
		output wire [NB_OPCODE-1:0] function_o, 

		output wire [1:0] pc_src_o,	

		output wire branch_or_jump_o,
		
		output wire [`ADDRWIDTH-1:0] addr_register_o, 
		output wire [`ADDRWIDTH-1:0] addr_branch_o,
		output wire [`ADDRWIDTH-1:0] addr_jump_o,

		output wire pc_write_o,
		output wire IF_ID_write_o,	

		output wire [NB_DATA-1:0] data_reg_debug_unit_o,

		output wire [NB_EX_CTRL-1:0] EX_control_o,
		output wire [NB_MEM_CTRL-1:0] M_control_o, 
		output wire [NB_WB_CTRL-1:0] WB_control_o,
		//output wire [NB_OPCODE-1:0] op_code_o,
		output wire halt_o

		/*
		output wire [NB_REG-1:0] EX_write_register_o,
		output wire [NB_REG-1:0] EX_rt_o,
		output wire ID_EX_mem_read_o,
		output wire EX_reg_write_o
		*/
	);

	wire [NB_REG-1:0] conex_reg_dest, conex_addres_reg_debug;
	wire conex_halt_detected;
	wire [NB_DATA-1:0] reg_inm_ext;
	wire [NB_DATA-1:0] data_ra_branch;
	wire [NB_DATA-1:0] data_rb_branch;

	wire [NB_WB_CTRL-1:0] conex_WB_control;
	wire [NB_EX_CTRL-1:0] conex_EX_control;
	wire [NB_MEM_CTRL-1:0] conex_M_control;

	wire is_equal, conex_stall; // se usa para ver si son iguales o no los registros fuentes para los branch
    
	wire conex_beq, conex_bne, conex_jump;
	wire [NB_DATA-1:0] reg_data_ra, reg_data_rb;
	
    assign rs_o = instruction_i[`RS_BIT];
	assign rt_o = instruction_i[`RT_BIT];
	assign rd_o = instruction_i[`RD_BIT];

	assign shamt_o = instruction_i[`SHAMT_BIT];
	assign inm_ext_o = reg_inm_ext;
	assign function_o = instruction_i[`FUNC_BIT];
	//assign op_code_o = instruction_i[`OP_CODE];
	assign branch_or_jump_o = ((conex_beq && is_equal) | (conex_bne && !is_equal) | conex_jump);
	assign addr_register_o  = reg_data_ra[`ADDRWIDTH-1:0];

	assign halt_o = conex_halt_detected;
	
	assign data_reg_debug_unit_o = reg_data_ra;
	assign data_ra_o = reg_data_ra;
	assign data_rb_o = reg_data_rb;
	assign addr_jump_o = pc_i + instruction_i[`ADDRWIDTH-1:0];
	/*
	assign EX_write_register_o = EX_write_register_i;
	assign EX_rt_o = EX_rt_i;
	assign ID_EX_mem_read_o = ID_EX_mem_read_i;
	assign EX_reg_write_o = EX_reg_write_i;
	*/
	assign EX_control_o = (conex_stall) ? {NB_EX_CTRL{1'b0}} : conex_EX_control;
	assign M_control_o = (conex_stall) ? {NB_MEM_CTRL{1'b0}} : conex_M_control;
	assign WB_control_o = (conex_stall) ? {NB_WB_CTRL{1'b0}} : conex_WB_control;

	hazard_detection hazard_detection
	(
		.ID_rs_i(instruction_i[`RS_BIT]),
		.ID_rt_i(instruction_i[`RT_BIT]),
		.EX_reg_write_i(EX_reg_write_i),
		//.beq_i(conex_beq),
		//.bne_i(conex_bne),
		//.op_code_i(instruction_i[`OP_CODE]),
		.EX_write_register_i(EX_write_register_i),
		.EX_rt_i(EX_rt_i),
		.ID_EX_mem_read_i(ID_EX_mem_read_i),		
		.halt_i(conex_halt_detected),
		.stall_o(conex_stall),
		.pc_write_o(pc_write_o),
		.IF_ID_write_o(IF_ID_write_o)
	);

	unit_branch unit_branch
	(
		.pc_i(pc_i),
		.inm_ext_i(reg_inm_ext[`ADDRWIDTH-1:0]),

		.data_ra_i(data_ra_branch),
		.data_rb_i(data_rb_branch),

		.is_equal_o(is_equal),
		.branch_address_o(addr_branch_o)
	);	
	Mux2_1 #(.NB_DATA(NB_REG)) mux_read_debug
	(
		.inA(addr_debug_unit_i),
		.inB(instruction_i[`RS_BIT]),
		.sel(cntl_read_debug_reg_i),
		.out(conex_addres_reg_debug)
	);

	bank_register banco_registros
	(
		.clock_i(clock_i),
		.reset_i(reset_i),		
		//.enable_i(enable_i),
		
		.rw_i(reg_write_i),		
		
		.addr_ra_i(conex_addres_reg_debug),
		.addr_rb_i(instruction_i[`RT_BIT]),

		.addr_rw_i(write_register_i),
		.data_rw_i(data_rw_i),
		
		.data_ra_o(reg_data_ra),
		.data_rb_o(reg_data_rb)
		
	);
	
	unit_control unidad_de_control
	(		
		.op_code_i(instruction_i[`OP_CODE]),
		.pc_src_o(pc_src_o),
		.function_i(instruction_i[`FUNC_BIT]),
		.beq_o(conex_beq),
		.bne_o(conex_bne),
		.jump_o(conex_jump),
		.EX_control_o(conex_EX_control),
		.M_control_o(conex_M_control),
		.WB_control_o(conex_WB_control),
		.halt_detected_o(conex_halt_detected)		

	);
	sign_ext sign_extend
	(
		.unextend_i(instruction_i[`INM_BIT]),
		.extended_o(reg_inm_ext)
	);		

	Mux2_1#(.NB_DATA(NB_DATA)) mux_reg_A
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_ra),
		.sel(forward_A_i),
		.out(data_ra_branch)
	);

	Mux2_1#(.NB_DATA(NB_DATA)) mux_reg_B
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_rb),
		.sel(forward_B_i),
		.out(data_rb_branch)
	);
	/*
	Mux2_1#(.NB_DATA(NB_DATA)) mux_signal_control //WB, MEM, EX = 0 cuando hay una burbuja.
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_rb),
		.sel(forward_B_i),
		.out(data_rb_branch)
	);
*/
endmodule

