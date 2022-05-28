`include "parameters.vh"

module pipeline_segmentado
	#(		
		parameter NB_DATA = 32,
		parameter NB_OPCODE = 6,
		parameter NB_FUNCTION = 6,
		parameter NB_REG  = 5,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3,
		parameter N_REGISTER = 32,
		parameter N_BYTES    = 4,
		parameter N_BITS = 8		
	)
	(
		input wire clock,
		input wire reset_i,		
		input wire [NB_DATA-1:0] inst_load_i,
		input wire [`ADDRWIDTH-1:0] addr_inst_load_i,	

		input wire en_write_i,
		input wire en_read_i,
		input wire enable_pipe_i,
		input wire enable_mem_i,							
		input wire debug_unit_i,
		input wire cntl_read_debug_reg_i,

		input wire [`ADDRWIDTH-1:0] addr_mem_debug_unit_i,
		input wire cntl_addr_debug_mem_i,
		input wire cntl_wr_debug_mem_i, //leyendo para debug mem

		input wire [NB_REG-1:0] addr_debug_unit_i, //addr de registro debug

		output wire bit_sucio_o,
		output wire [NB_DATA-1:0] data_mem_debug_unit_o,

		output wire [`ADDRWIDTH-1:0] data_send_pc_o,
		output wire [N_BITS-1:0] count_cycles_o,
		output wire [NB_DATA-1:0] data_reg_debug_unit_o,
		output wire halt_o
		/* DEBUG */

		/*
		output wire pc_write_o,
		output wire IF_ID_write_o,

		output wire [`ADDRWIDTH-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o,
		output wire [`ADDRWIDTH-1:0] pc_i_mem_o,
		output wire [1:0] pc_src_o,
		output wire [NB_OPCODE-1:0] op_code_o,
		output wire enable_reg_IF_ID,

		output wire [NB_REG-1:0] EX_write_register_o,
		output wire [NB_REG-1:0] EX_rt_o,
		output wire ID_EX_mem_read_o,
		output wire EX_reg_write_o,
		output wire [NB_REG-1:0] rs_o, rt_o,

		output wire [NB_EX_CTRL-1:0] EX_control_o,
		output wire [NB_MEM_CTRL-1:0] M_control_o,
		output wire [NB_WB_CTRL-1:0] WB_control_o
		*/	
	);




	wire [`ADDRWIDTH-1:0]  conex_pc_IF_ID, conex_pc_ID_EX, conex_pc_EX_MEM, conex_pc_MEM_WB, conex_pc_WB, conex_pc_adder;
	wire [NB_DATA-1:0] conex_inst_IF, conex_inst_IF_ID;

	wire [NB_DATA-1:0] conex_result_alu_MEM_WB; //resultado de la ALU


	/* output data stage ID */
	wire [NB_DATA-1:0] conex_data_ra_ID, conex_data_rb_ID, conex_inm_ext_ID;
	wire [NB_DATA-1:0] conex_data_ra_ID_EX, conex_data_rb_ID_EX, conex_inm_ext_ID_EX;

	wire [NB_EX_CTRL-1:0] conex_EX_ctrl_ID; 
	wire [NB_MEM_CTRL-1:0] conex_M_ctrl_ID;
	wire [NB_WB_CTRL-1:0] conex_WB_ctrl_ID;
	/* signal unit control per stage*/
	/* ------------------------------------------ */
	wire [NB_EX_CTRL-1:0] conex_EX_ctrl_ID_EX;
	wire [NB_MEM_CTRL-1:0] conex_M_ctrl_ID_EX;
	wire [NB_WB_CTRL-1:0] conex_WB_ctrl_ID_EX;
	/* ------------------------------------------ */
	wire [NB_EX_CTRL-1:0]  conex_EX_ctrl_EX_MEM;
	wire [NB_MEM_CTRL-1:0] conex_M_ctrl_EX_MEM;
	wire [NB_WB_CTRL-1:0] conex_WB_ctrl_EX_MEM;
	/* ------------------------------------------ */
	wire [NB_MEM_CTRL-1:0] conex_M_ctrl_MEM;
	wire [NB_WB_CTRL-1:0] conex_WB_ctrl_MEM_WB;
	/* ------------------------------------------ */


	wire [NB_FUNCTION-1:0] conex_function_ID_EX;

	/* registros operandos */

	wire [NB_REG-1:0] conex_rt_ID, conex_rs_ID, conex_rd_ID;
	wire [NB_REG-1:0] conex_rt_ID_EX, conex_rs_ID_EX, conex_rd_ID_EX;

	wire [NB_REG-1:0] conex_shamt_ID;
	wire [NB_REG-1:0] conex_shamt_ID_EX;

	wire [NB_REG-1:0] conex_write_reg_EX;

	wire [NB_FUNCTION-1:0] conex_function_ID;

	/* Direccion a cargar en PC */

	wire conex_branch_or_jump_IF_ID;

	wire [`ADDRWIDTH-1:0] conex_addr_reg_ID_IF; 
	wire [`ADDRWIDTH-1:0] conex_addr_branch_ID_IF;
	wire [`ADDRWIDTH-1:0] conex_addr_jump_ID_IF;

    /* Instruccion LUI */    
    wire [NB_DATA-1:0] conex_inm_ext_MEM_WB;
    wire [NB_DATA-1:0] conex_inm_ext_WB;

    /* STORE */
    wire [NB_DATA-1:0] conex_write_data_mem_EX_MEM;

	wire [NB_DATA-1:0] conex_data_write_WB_ID;

	/* conexion entre EX y reg_EX_MEM */
	wire [NB_DATA-1:0] conex_result_alu_EX, conex_result_alu_EX_MEM;

	wire [1:0] conex_pc_src_ID_IF;

	wire [NB_REG-1:0] conex_EX_rt;
	wire conex_ID_EX_mem_read_i;


	/* CONEX UNIT FORWARDING EN EX*/
	wire conex_reg_write_MEM_EX;
	wire conex_reg_write_WB_EX;

	wire [NB_REG-1:0] conex_write_reg_MEM_EX;
	wire [NB_REG-1:0] conex_write_reg_WB_EX;
	/* **************************** */

	wire forw_branch_A, forw_branch_B;

	wire conex_pc_write;

	wire [1:0] conex_mem_to_reg_WB;
	wire [NB_DATA-1:0] conex_alu_result_WB;
	wire [NB_DATA-1:0] conex_write_data_MEM;

	wire [NB_REG-1:0] conex_write_reg_MEM_WB;
	wire [NB_REG-1:0] conex_write_reg_WB_ID; // registro a escribir en ID
	wire [NB_DATA-1:0] conex_mem_data_MEM_WB;
	wire [NB_DATA-1:0] conex_mem_data_WB;

	/* HAZARD */
	wire conex_IF_ID_write;

	/* conexiones halt*/
	wire conex_halt_detected_IF_ID_EX;
	wire conex_halt_detected_ID_EX_MEM;
	wire conex_halt_detected_EX_MEM_WB;
	
	assign data_send_pc_o = conex_pc_IF_ID;

	/************************/	
	/*
	
    assign pc_o = conex_pc_adder;
	assign instruction_o = conex_inst_IF_ID;

	assign pc_write_o = conex_pc_write;
	assign IF_ID_write_o = conex_IF_ID_write;
	//assign halt_o = conex_halt_detected_IF_ID_EX;	
	assign rs_o = conex_rs_ID;
	assign rt_o = conex_rt_ID;

	assign enable_reg_IF_ID = (conex_IF_ID_write&&enable_pipe_i);

	assign EX_control_o = conex_EX_ctrl_ID_EX;
	assign M_control_o = conex_M_ctrl_EX_MEM;
	assign WB_control_o = conex_WB_ctrl_EX_MEM;*/

	Counter_Cycles Counter_Cycles
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.en_count_i(enable_pipe_i),

		.count_cycles_o(count_cycles_o)

	);

	IF instruccion_fetch
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.en_write_i(en_write_i),
		.en_read_i(en_read_i),
		.debug_unit_i(debug_unit_i),
		.enable_i(conex_pc_write&&enable_pipe_i),
		.inst_load_i(inst_load_i),
		.wr_addr_i(addr_inst_load_i), //address instr debu_unit		
		.pc_src_i(conex_pc_src_ID_IF), //viene de ID
		.jump_or_branch_i(conex_branch_or_jump_IF_ID),//viene de ID
		.addr_register_i(conex_addr_reg_ID_IF),
		.addr_branch_i(conex_addr_branch_ID_IF),
		.addr_jump_i(conex_addr_jump_ID_IF),

		.instruction_o(conex_inst_IF),		
		.pc_o(conex_pc_adder)	

/*		.pc_src_o(pc_src_o),
		.pc_i_mem_o(pc_i_mem_o)*/
	);

	reg_IF_ID reg_IF_ID
	(
		.clock_i(clock),		
		.enable_pipe_i(conex_IF_ID_write&&enable_pipe_i),					
		.instruction_i(conex_inst_IF),
		.pc_i(conex_pc_adder),		
		.instruction_o(conex_inst_IF_ID),	
		.pc_o(conex_pc_IF_ID)	

	);

	
	ID instruction_decode
	(
		.clock_i(clock),
		.reset_i(reset_i),
		//.enable_i(enable_pipe_i),
		.cntl_read_debug_reg_i(cntl_read_debug_reg_i),			
		.instruction_i(conex_inst_IF_ID),		
		.pc_i(conex_pc_IF_ID),

		.data_rw_i(conex_data_write_WB_ID),
		.write_register_i(conex_write_reg_WB_ID),
		.reg_write_i(conex_reg_write_WB_EX),
		.addr_debug_unit_i(addr_debug_unit_i),
		.data_reg_debug_unit_o(data_reg_debug_unit_o),


		/* HAZARD UNIT*/
		.EX_rt_i(conex_rt_ID_EX),
		.ID_EX_mem_read_i(conex_M_ctrl_EX_MEM[5]), //mem_read (LOAD)
		.EX_write_register_i(conex_write_reg_EX),//HAZARD BRANCH
		.EX_reg_write_i(conex_WB_ctrl_EX_MEM[2]),
		/********************************/
		.pc_write_o(conex_pc_write),
		.IF_ID_write_o(conex_IF_ID_write),

		.halt_o(conex_halt_detected_IF_ID_EX),

		//.op_code_o(op_code_o),
		.forward_A_i(forw_branch_A),
		.forward_B_i(forw_branch_B),
		.data_forward_EX_MEM_i(conex_result_alu_EX_MEM), //forward branch EX_MEM a ID
		
		.data_ra_o(conex_data_ra_ID),
		.data_rb_o(conex_data_rb_ID),
		.inm_ext_o(conex_inm_ext_ID),		

		.pc_src_o(conex_pc_src_ID_IF),

		.branch_or_jump_o(conex_branch_or_jump_IF_ID),

		.addr_register_o(conex_addr_reg_ID_IF),
		.addr_branch_o(conex_addr_branch_ID_IF),
		.addr_jump_o(conex_addr_jump_ID_IF),
		

		.function_o(conex_function_ID),
		
		.EX_control_o(conex_EX_ctrl_ID),
		.M_control_o(conex_M_ctrl_ID),
		.WB_control_o(conex_WB_ctrl_ID),
		
		.shamt_o(conex_shamt_ID),
		.rs_o(conex_rs_ID),
		.rt_o(conex_rt_ID),		
		.rd_o(conex_rd_ID)

		/*
		.EX_rt_o(EX_rt_o),
		.EX_reg_write_o(EX_reg_write_o),
		.ID_EX_mem_read_o(ID_EX_mem_read_o),
		.EX_write_register_o(EX_write_register_o)*/


	);
	
	reg_ID_EX reg_ID_EX
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.enable_pipe_i(enable_pipe_i),
		.halt_detected_i(conex_halt_detected_IF_ID_EX),

		.EX_control_i(conex_EX_ctrl_ID),
		.M_control_i (conex_M_ctrl_ID),
		.WB_control_i(conex_WB_ctrl_ID),

		.pc_i(conex_pc_IF_ID),

		.halt_detected_o(conex_halt_detected_ID_EX_MEM),		

		.data_ra_i(conex_data_ra_ID),
		.data_rb_i(conex_data_rb_ID),
		.inm_ext_i(conex_inm_ext_ID),
		.function_i(conex_function_ID),
		.shamt_i(conex_shamt_ID),
		.rs_i(conex_rs_ID),
		.rt_i(conex_rt_ID),
		.rd_i(conex_rd_ID),

		.EX_control_o(conex_EX_ctrl_ID_EX),
		.M_control_o (conex_M_ctrl_EX_MEM),
		.WB_control_o(conex_WB_ctrl_EX_MEM),

		.pc_o(conex_pc_EX_MEM),

		.data_ra_o(conex_data_ra_ID_EX),
		.data_rb_o(conex_data_rb_ID_EX),
		.inm_ext_o(conex_inm_ext_ID_EX),

		.shamt_o(conex_shamt_ID_EX),
		.rs_o(conex_rs_ID_EX),
		.rt_o(conex_rt_ID_EX),
		.rd_o(conex_rd_ID_EX),
		
		.function_o(conex_function_ID_EX)
		
	);

	EX execute_instruction
	(
		.data_ra_i(conex_data_ra_ID_EX),
		.data_rb_i(conex_data_rb_ID_EX),
		.data_inm_i(conex_inm_ext_ID_EX),
		.EX_control_i(conex_EX_ctrl_ID_EX),		
		.function_i(conex_function_ID_EX),		

		.shamt_i(conex_shamt_ID_EX),
		.rs_i(conex_rs_ID_EX),
		.rt_i(conex_rt_ID_EX),
		.rd_i(conex_rd_ID_EX),
		// unit forward
		.EX_MEM_write_reg_i(conex_write_reg_MEM_WB),
		.MEM_WB_write_reg_i(conex_write_reg_WB_ID),
		.EX_MEM_reg_write_i(conex_reg_write_MEM_EX),
		.MEM_WB_reg_write_i(conex_reg_write_WB_EX),
		.EX_MEM_result_alu_i(conex_result_alu_EX_MEM),
		.MEM_WB_data_i(conex_data_write_WB_ID),

		.data_write_mem_o(conex_write_data_mem_EX_MEM), //STORE
		.result_alu_o(conex_result_alu_EX),
		.write_register_o(conex_write_reg_EX)

	);	

	reg_EX_MEM reg_EX_MEM
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.enable_pipe_i(enable_pipe_i),
		.halt_detected_i(conex_halt_detected_ID_EX_MEM),

		.WB_control_i(conex_WB_ctrl_EX_MEM),
		.MEM_control_i(conex_M_ctrl_EX_MEM),
		.alu_result_i(conex_result_alu_EX), //salida de la ALU de la etapa EX		
		.data_inm_i(conex_inm_ext_ID_EX), //LUI
		.data_write_i(conex_write_data_mem_EX_MEM), //store	
		.pc_i(conex_pc_EX_MEM),		
		.write_register_i(conex_write_reg_EX), //registro a escribir
	
		.WB_control_o(conex_WB_ctrl_MEM_WB),
		.MEM_control_o(conex_M_ctrl_MEM),
		.write_register_o(conex_write_reg_MEM_WB), //registro a escribir
		.pc_o(conex_pc_MEM_WB),
		.alu_result_o(conex_result_alu_EX_MEM),	
		.data_write_o(conex_write_data_MEM), 
		.data_inm_o(conex_inm_ext_MEM_WB), //dato inmediato a escribir en memoria	*/
	
		.halt_detected_o(conex_halt_detected_EX_MEM_WB),
		.reg_write_o(conex_reg_write_MEM_EX)

	);	
	
	MEM stage_memory
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.enable_mem_i(enable_mem_i),
		.alu_result_i(conex_result_alu_EX_MEM[`ADDRWIDTH-1:0]),
		.MEM_control_i(conex_M_ctrl_MEM),
		.data_write_i(conex_write_data_MEM),

		.addr_mem_debug_unit_i(addr_mem_debug_unit_i),
		.cntl_addr_debug_mem_i(cntl_addr_debug_mem_i),
		.cntl_wr_debug_mem_i(cntl_wr_debug_mem_i),
		.bit_sucio_o(bit_sucio_o),
		.data_mem_debug_unit_o(data_mem_debug_unit_o),
		.mem_data_o(conex_mem_data_MEM_WB)	

	);
	reg_MEM_WB reg_MEM_WB
	(
		.clock_i(clock),
		.reset_i(reset_i),
		.enable_pipe_i(enable_pipe_i),
		.halt_detected_i(conex_halt_detected_EX_MEM_WB),
		.WB_control_i(conex_WB_ctrl_MEM_WB),


		.pc_i(conex_pc_MEM_WB),
		.mem_data_i(conex_mem_data_MEM_WB), //dato de la memoria
		.alu_result_i(conex_result_alu_EX_MEM), //resultado de la alu		
		.data_inm_i(conex_inm_ext_MEM_WB),// instruccion lui

		.write_register_i(conex_write_reg_MEM_WB), //registro a escribir		
		.mem_to_reg_o(conex_mem_to_reg_WB),
		.mem_data_o(conex_mem_data_WB),
		.alu_result_o(conex_alu_result_WB),
		.inm_ext_o(conex_inm_ext_WB),
		.pc_o(conex_pc_WB), //deberia entrar en la etapa ID 

		.write_register_o(conex_write_reg_WB_ID),// va tanto a ID como EX
		.reg_write_o(conex_reg_write_WB_EX), //va a EX para unit forward
		.halt_detected_o(halt_o)
		
	);

	/* RECIBE 4 DATOS A ESCRIBIR EN REGISTROS */
	
	WB stage_write_back
	(		
		.alu_result_i(conex_alu_result_WB),
		.pc_i(conex_pc_WB),
		.mem_data_i(conex_mem_data_WB),
		.mem_to_reg_i(conex_mem_to_reg_WB),
		.inm_ext_i(conex_inm_ext_WB),

		.data_o(conex_data_write_WB_ID) //dato a escribir en registro
	);

	branch_forward_unit branch_forward_unit
	(
		.ID_rs_i(conex_rs_ID),
		.ID_rt_i(conex_rt_ID),

		.EX_MEM_reg_write_i(conex_reg_write_MEM_EX),//write ?
		.EX_MEM_write_reg_i(conex_write_reg_MEM_WB),//registro a escribir


		.forward_A_o(forw_branch_A),
		.forward_B_o(forw_branch_B)
	);

endmodule