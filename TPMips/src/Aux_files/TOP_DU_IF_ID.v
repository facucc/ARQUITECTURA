`include "parameters.vh"
`define RS_BIT    25:21
`define RT_BIT    20:16

module TOP_DU_IF_ID
	#(	
		parameter CLK        = 20E6,
		parameter BAUD_RATE  = 203400,
		parameter NB_STATE   = 12,		
		parameter NB_DATA = 32,	
		parameter NB_REG  = 5,
		parameter NB_FUNCTION = 6,
		parameter N_BITS  = 8,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3				
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire reset_wz_i,
		input wire rx_data_i,

		output wire tx_data_o,
		output wire locked_o,	
		output wire ack_debug_o,
		output wire end_send_data_o,

		/* DEBUG */
		output wire pc_write_o,
		output wire IF_ID_write_o,			
		output wire [NB_DATA-1:0] instruction_o,
		output wire [`ADDRWIDTH-1:0] pc_i_mem_o,
		output wire [1:0] pc_src_o,
		output wire enable_pipe_o,
		output wire halt_o,
		output wire data_ready_o,
		output wire en_read_load_inst_o,
		output wire receive_full_byte_o,
		output wire bit_finish_o, en_next_state_o,		
		output wire [NB_STATE-1:0] state_o,
		output wire [N_BITS-1:0] data_receive_o,
		output wire [NB_FUNCTION-1:0] op_code_o,
		/* REG_ID_EX */
		output wire [NB_DATA-1:0] data_ra_o,
		output wire [NB_DATA-1:0] data_rb_o,
		output wire [NB_DATA-1:0] inm_ext_o,

		output wire [NB_DATA-1:0] inst_o_mem, instruction_i_o,

		output wire branch_or_jump_o,
		output wire [NB_REG-1:0] shamt_o,


		output wire [`ADDRWIDTH-1:0] pc_o,
		output wire [NB_REG-1:0] rs_o, rt_o, rd_o,

		output wire [NB_FUNCTION-1:0] function_o,
		
		output wire [NB_EX_CTRL-1:0] EX_control_o,
		output wire [NB_MEM_CTRL-1:0] M_control_o,
		output wire [NB_WB_CTRL-1:0] WB_control_o,

		output wire beq_o,
		output wire bne_o,
		output wire jump_o


	);	
	wire conex_en_write, conex_en_read;	
	wire [NB_DATA-1:0] conex_inst_load, conex_inst_IF_ID;
	wire [`ADDRWIDTH-1:0] conex_addr_load_inst;
	wire [`ADDRWIDTH-1:0] conex_pc, conex_pc_IF_ID;
	wire [NB_DATA-1:0] conex_inst_o, conex_instruction_in;
	
	wire conex_debug_unit;	
	wire conex_enable_pipe;	
	wire clock_o, locked_wz;
	wire [NB_DATA-1:0] conex_data_reg;
	wire conex_read_reg;
	wire [NB_REG-1:0] conex_addr_reg;
	/* output data stage ID */
	wire [NB_DATA-1:0] conex_data_ra_ID, conex_data_rb_ID, conex_inm_ext_ID;	
	wire [NB_EX_CTRL-1:0] conex_EX_ctrl_ID; 
	wire [NB_MEM_CTRL-1:0] conex_M_ctrl_ID;
	wire [NB_WB_CTRL-1:0] conex_WB_ctrl_ID;
	/* ------------------------------------------ */
	
	wire [NB_REG-1:0] conex_rt_ID, conex_rs_ID, conex_rd_ID;
	wire [NB_REG-1:0] conex_rt_ID_EX;
	wire [NB_REG-1:0] conex_shamt_ID;	
	wire [NB_REG-1:0] conex_write_reg_EX;
	wire [NB_FUNCTION-1:0] conex_function_ID;
	/* Direccion a cargar en PC */
	wire conex_branch_or_jump_IF_ID;
	wire [`ADDRWIDTH-1:0] conex_addr_reg_ID_IF; 
	wire [`ADDRWIDTH-1:0] conex_addr_branch_ID_IF;
	wire [`ADDRWIDTH-1:0] conex_addr_jump_ID_IF;
	wire [`ADDRWIDTH-1:0] conex_pc_o;
	/* conexion entre EX y reg_EX_MEM */	
	wire [1:0] conex_pc_src_ID_IF;	
	wire conex_halt_o;
	wire conex_pc_write;	

/* HAZARD */
	wire conex_IF_ID_write;
	/* conexiones halt*/
	wire conex_halt_detected_IF_ID_EX;
		
	assign clock_processor = (locked_wz == 1'b1) ? (clock_o) : 1'bz;
	
	assign instruction_o = conex_inst_IF_ID;	
	assign locked_o = locked_wz;
	assign pc_write_o = conex_pc_write;		
	assign IF_ID_write_o = conex_IF_ID_write;
	assign enable_pipe_o = conex_enable_pipe;
	assign halt_o = conex_halt_o;

	assign inst_o_mem  = conex_inst_o;
	assign branch_or_jump_o = conex_branch_or_jump_IF_ID;
	assign instruction_i_o  = conex_instruction_in;
	assign pc_o = conex_pc_o;
	assign function_o = conex_function_ID;


	clk_wiz_0 clock_wz
  	(
	  // Clock out ports  
		.clk_out1(clock_o),
	  // Status and control signals               
	  	.reset(reset_wz_i), 
	  	.locked(locked_wz),
	 // Clock in ports
	  	.clk_in1(clock_i)
	 );

	IF instruccion_fetch
	(
		.clock_i(clock_processor),
		.reset_i(reset_i),		
		.en_write_i(conex_en_write),
		.en_read_i(conex_en_read),
		.debug_unit_i(conex_debug_unit),

		.enable_i(conex_enable_pipe&&conex_pc_write),
		.inst_load_i(conex_inst_load),
		.wr_addr_i(conex_addr_load_inst), //address instr debu_unit		
		.pc_src_i(conex_pc_src_ID_IF), //viene de ID
		
		.addr_register_i(conex_addr_reg_ID_IF),
		.addr_branch_i(conex_addr_branch_ID_IF),
		.addr_jump_i(conex_addr_jump_ID_IF),

		.instruction_o(conex_inst_o),
		.pc_src_o(pc_src_o),
		.pc_i_mem_o(pc_i_mem_o),		
		.pc_o(conex_pc)		
		
	);	
  	Mux2_1#(.NB_DATA(NB_DATA)) mux_input_reg
  	(
  		.inA(32'hF8000000),
  		.inB(conex_inst_o),
  		.sel(conex_branch_or_jump_IF_ID),
  		.out(conex_instruction_in)
  	);
	reg_IF_ID reg_IF_ID
	(
		.clock_i(clock_processor),		
		.enable_pipe_i(conex_enable_pipe&&conex_IF_ID_write),
		.instruction_i(conex_instruction_in),
		.pc_i(conex_pc),		
		.instruction_o(conex_inst_IF_ID),	
		.pc_o(conex_pc_IF_ID)	
	);
	ID instruction_decode
	(
		.clock_i(clock_processor),
		.reset_i(reset_i),
		.enable_i(conex_enable_pipe),
		.cntl_read_debug_reg_i(conex_read_reg),			
		.instruction_i(conex_inst_IF_ID),		
		.pc_i(conex_pc_IF_ID),

		.data_rw_i(32'b0),
		.write_register_i(5'b0),
		.reg_write_i(1'b0),
		.addr_debug_unit_i(conex_addr_reg),

		.forward_A_i(1'b0),
		.forward_B_i(1'b0),
		.data_forward_EX_MEM_i(32'b0),

		.EX_rt_i(5'b0),
		.ID_EX_mem_read_i(1'b0), //mem_read (LOAD)
		.EX_write_register_i(1'b0),//HAZARD BRANCH
		.EX_reg_write_i(1'b0),

		.pc_write_o(conex_pc_write),
		.IF_ID_write_o(conex_IF_ID_write),
		.data_reg_debug_unit_o(conex_data_reg),
		.halt_o(conex_halt_detected_IF_ID_EX),
		.op_code_o(op_code_o),


		
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
		.rd_o(conex_rd_ID),

		.beq_o(beq_o),
		.bne_o(bne_o),
		.jump_o(jump_o)


	);
	
	reg_ID_EX reg_ID_EX
	(
		.clock_i(clock_processor),		
		.enable_pipe_i(conex_enable_pipe),
		.halt_detected_i(conex_halt_detected_IF_ID_EX),

		.EX_control_i(conex_EX_ctrl_ID),
		.M_control_i (conex_M_ctrl_ID),
		.WB_control_i(conex_WB_ctrl_ID),

		.pc_i(conex_pc_IF_ID),
		.halt_detected_o(conex_halt_o),		

		.data_ra_i(conex_data_ra_ID),
		.data_rb_i(conex_data_rb_ID),
		.inm_ext_i(conex_inm_ext_ID),
		.function_i(conex_function_ID),
		.shamt_i(conex_shamt_ID),
		.rs_i(conex_rs_ID),
		.rt_i(conex_rt_ID),
		.rd_i(conex_rd_ID),


		.EX_control_o(EX_control_o),
		.M_control_o (M_control_o),
		.WB_control_o(WB_control_o),
		.pc_o(conex_pc_o),
		.data_ra_o(data_ra_o),
		.data_rb_o(data_rb_o),
		.inm_ext_o(inm_ext_o),
		.shamt_o(shamt_o),
		.rs_o(rs_o),
		.rt_o(rt_o),
		.rd_o(rd_o),		
		.function_o(function_o)
		
	);

	debug_unit#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) debug_unit
	(
		.clock_i(clock_processor),
		.reset_i(reset_i),
		.halt_i(conex_halt_o),
		.rx_data_i(rx_data_i),

		.bit_sucio_i(0),
		.data_mem_debug_unit_i(32'b0),
		
		
		.data_send_pc_i(conex_pc_o),
		.count_cycles_i(2),
		.data_reg_debug_unit_i(conex_data_reg),


		.addr_debug_unit_o(conex_addr_reg), //address register
		.addr_mem_debug_unit_o(), //address mem data

		.cntl_addr_debug_mem_o(),
		.cntl_wr_debug_mem_o(),
		.cntl_read_debug_reg_o(conex_read_reg),
		.tx_data_o(tx_data_o),	

		.enable_pipe_o(conex_enable_pipe),
		.enable_mem_o(),	
		
		.debug_unit_o(conex_debug_unit),
		.en_write_o(conex_en_write),
		.en_read_o(conex_en_read),	
		.address_o(conex_addr_load_inst),		
		.inst_load_o(conex_inst_load),
		.ack_debug_o(ack_debug_o), //avisa al test que ya puede ejecutar otro ciclo.
		.end_send_data_o(end_send_data_o), //fin de envio de data mem.
		
		.state_o(state_o),
		.data_ready_o(data_ready_o),
		.data_receive_o(data_receive_o),
		.en_next_state_o(en_next_state_o),

		.bit_finish_o(bit_finish_o),
		.en_read_load_inst_o(en_read_load_inst_o),
		.receive_full_byte_o(receive_full_byte_o)
		
	);
	
endmodule