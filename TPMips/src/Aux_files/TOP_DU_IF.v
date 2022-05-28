`include "parameters.vh"
`define RS_BIT    25:21
`define RT_BIT    20:16

module TOP_DU_IF
	#(	
		parameter CLK         = 20E6,
		parameter BAUD_RATE  = 203400,
		parameter NB_STATE   = 12,		
		parameter NB_DATA = 32,	
		parameter NB_REG  = 5,
		parameter N_BITS  = 8				
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
		output wire [`ADDRWIDTH-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o,
		output wire [`ADDRWIDTH-1:0] pc_i_mem_o,
		output wire [1:0] pc_src_o,
		output wire halt_o,
		output wire data_ready_o,
		output wire en_read_load_inst_o,
		output wire receive_full_byte_o,
		output wire bit_finish_o,		
		output wire [NB_STATE-1:0] state_o,
		output wire [N_BITS-1:0] data_receive_o,

		output wire clock_proc_o 

	);

	wire conex_pc_write;

	wire conex_en_write, conex_en_read;
	wire conex_IF_ID_write;
	wire [NB_DATA-1:0] conex_inst_load;
	wire [`ADDRWIDTH-1:0] conex_addr_load_inst;

	wire [NB_DATA-1:0] conex_inst_o;
	
	wire conex_debug_unit;	

	wire conex_halt, conex_enable_pipe;		


	wire clock_o, locked_wz;

	assign clock_processor = (locked_wz == 1'b1) ? (clock_o) : 1'bz;
	assign halt_o = conex_halt;
	assign instruction_o = conex_inst_o;	
	assign locked_o = locked_wz;
	assign pc_write_o = conex_pc_write;
	assign clock_proc_o = (locked_wz == 1'b1) ? (clock_o) : 1'b0;
	assign IF_ID_write_o = conex_IF_ID_write;

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

		.enable_i(conex_enable_pipe&conex_pc_write),
		.inst_load_i(conex_inst_load),
		.wr_addr_i(conex_addr_load_inst), //address instr debu_unit		
		.pc_src_i(2'b0), //viene de ID
		
		.addr_register_i({`ADDRWIDTH{1'b0}}),
		.addr_branch_i({`ADDRWIDTH{1'b0}}),
		.addr_jump_i({`ADDRWIDTH{1'b0}}),

		.instruction_o(conex_inst_o),
		.pc_src_o(pc_src_o),
		.pc_i_mem_o(pc_i_mem_o),		
		.pc_o(pc_o),
		.halt_o(conex_halt)
	);	
	reg_IF_ID reg_IF_ID
	(
		.clock_i(clock),		
		.enable_pipe_i(conex_IF_ID_write&conex_enable_pipe),		
		.jump_or_branch_i(conex_branch_or_jump_IF_ID),			
		.instruction_i(conex_inst_IF),
		.pc_i(conex_pc_adder),		
		.instruction_o(conex_inst_IF_ID),	
		.pc_o(conex_pc_IF_ID)	
	);
	hazard_detection hazard_detection
	(
		.ID_rs_i(conex_inst_o[`RS_BIT]),
		.ID_rt_i(conex_inst_o[`RT_BIT]),
		.EX_reg_write_i(),
		.EX_write_register_i(),
		.EX_rt_i(),
		.ID_EX_mem_read_i(),

		.halt_i(conex_halt),
		.pc_write_o(conex_pc_write),
		.IF_ID_write_o(conex_IF_ID_write)
	);

	debug_unit#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) debug_unit
	(
		.clock_i(clock_processor),
		.reset_i(reset_i),
		.halt_i(conex_halt),
		.rx_data_i(rx_data_i),

		.bit_sucio_i(0),
		.data_mem_debug_unit_i(32'b0),
		
		.data_send_pc_i({`ADDRWIDTH{1'b0}}),
		.count_cycles_i(2),
		.data_reg_debug_unit_i(32'b0),


		.addr_debug_unit_o(), //address register
		.addr_mem_debug_unit_o(), //address mem data

		.cntl_addr_debug_mem_o(),
		.cntl_wr_debug_mem_o(),
		.cntl_read_debug_reg_o(),
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

		.bit_finish_o         (bit_finish_o),
		.en_read_load_inst_o  (en_read_load_inst_o),
		.receive_full_byte_o  (receive_full_byte_o)
		
	);
	
endmodule