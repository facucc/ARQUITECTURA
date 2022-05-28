`include "parameters.vh"

module TOP
	#(	
		parameter CLK        = 50E6,
		parameter NB_OPCODE = 6,
		parameter BAUD_RATE  = 203400,
		parameter NB_STATE   = 12,		
		parameter NB_DATA = 32,	
		parameter NB_REG  = 5,
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
		output wire end_send_data_o
		/* DEBUG */
		/*
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
		output wire enable_reg_IF_ID,
		output wire [NB_OPCODE-1:0] op_code_o,


		output wire [NB_REG-1:0] EX_write_register_o,
		output wire [NB_REG-1:0] EX_rt_o,
		output wire ID_EX_mem_read_o,
		output wire EX_reg_write_o,
		output wire [NB_REG-1:0] rs_o, rt_o,
		output wire [NB_EX_CTRL-1:0] EX_control_o,
		output wire [NB_MEM_CTRL-1:0] M_control_o,
		output wire [NB_WB_CTRL-1:0] WB_control_o,

		output wire tx_start_o*/
	);


	wire [NB_DATA-1:0] conex_inst_load;
	wire [`ADDRWIDTH-1:0] conex_addr_load_inst; // instruccion a cargar y su direccion

	wire conex_en_write, conex_en_read, conex_debug_unit;	
    wire clock_w, locked_wz;
	wire conex_halt, conex_enable_pipe;
	wire conex_enable_mem;

	wire [`ADDRWIDTH-1:0] conex_data_send_pc;
	wire [NB_DATA-1:0] conex_data_send_reg;
	wire [N_BITS-1:0] conex_counter_cycles;
	wire [NB_REG-1:0] conex_addr_debug_unit; //direccion a registro a leer
	wire conex_bit_sucio;
	wire conex_cntl_addr_debug_mem;
	wire conex_cntl_wr_debug_mem;
	wire [`ADDRWIDTH:0] conex_addr_mem_debug_unit;
	wire [NB_DATA-1:0] conex_data_mem_debug_unit;
	wire conex_cntl_read_debug_reg;

	
	assign locked_o = locked_wz;
	assign halt_o = conex_halt;

	clk_wiz_0 clock_wz
  	(
	  // Clock out ports  
		.clk_out1(clock_w),
	  // Status and control signals               
	  	.reset(reset_wz_i), 
	  	.locked(locked_wz),
	 // Clock in ports
	  	.clk_in1(clock_i)
	 );


	pipeline_segmentado processor
	(
		.clock(clock_w),
		.reset_i(reset_i),		
		.inst_load_i(conex_inst_load),
		.addr_inst_load_i(conex_addr_load_inst),
		.en_write_i(conex_en_write),
		.en_read_i(conex_en_read),
		.enable_mem_i(conex_enable_mem),
		.enable_pipe_i(conex_enable_pipe),					
		.debug_unit_i(conex_debug_unit),

		.addr_mem_debug_unit_i(conex_addr_mem_debug_unit[`ADDRWIDTH-1:0]),
		.cntl_addr_debug_mem_i(conex_cntl_addr_debug_mem),
		.cntl_wr_debug_mem_i(conex_cntl_wr_debug_mem),
		.cntl_read_debug_reg_i(conex_cntl_read_debug_reg),
		.addr_debug_unit_i(conex_addr_debug_unit),

		.data_send_pc_o(conex_data_send_pc),
		.count_cycles_o(conex_counter_cycles),
		.data_reg_debug_unit_o(conex_data_send_reg),

		.bit_sucio_o(conex_bit_sucio),
		.data_mem_debug_unit_o(conex_data_mem_debug_unit),
		.halt_o(conex_halt)

		/*
		.IF_ID_write_o(IF_ID_write_o),
		.pc_write_o(pc_write_o),
		.pc_src_o(pc_src_o),
		.pc_i_mem_o(pc_i_mem_o),
		.pc_o(pc_o),
		.op_code_o(op_code_o),
		.enable_reg_IF_ID(enable_reg_IF_ID),
		.instruction_o(instruction_o),

		.EX_rt_o(EX_rt_o),
		.EX_reg_write_o(EX_reg_write_o),
		.ID_EX_mem_read_o(ID_EX_mem_read_o),
		.EX_write_register_o(EX_write_register_o),
		.rs_o(rs_o),
		.rt_o(rt_o),
		.M_control_o(M_control_o),
		.EX_control_o(EX_control_o),
		.WB_control_o(WB_control_o)*/

	);	

	debug_unit#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) debug_unit
	(
		
		.clock_i(clock_w),
		.reset_i(reset_i),
		.halt_i(conex_halt),

		.bit_sucio_i(conex_bit_sucio),
		.data_mem_debug_unit_i(conex_data_mem_debug_unit),

		.data_send_pc_i(conex_data_send_pc),
		.count_cycles_i(conex_counter_cycles),
		.data_reg_debug_unit_i(conex_data_send_reg),


		.addr_debug_unit_o(conex_addr_debug_unit), //address register
		.addr_mem_debug_unit_o(conex_addr_mem_debug_unit), //address mem data

		.cntl_addr_debug_mem_o(conex_cntl_addr_debug_mem),
		.cntl_wr_debug_mem_o(conex_cntl_wr_debug_mem),
		.cntl_read_debug_reg_o(conex_cntl_read_debug_reg),
		.tx_data_o(tx_data_o),			
		.enable_pipe_o(conex_enable_pipe),
		.enable_mem_o(conex_enable_mem),	
		
		.debug_unit_o(conex_debug_unit),
		.en_write_o(conex_en_write),
		.en_read_o(conex_en_read),
		.rx_data_i(rx_data_i),		
		.address_o(conex_addr_load_inst),
		.inst_load_o(conex_inst_load),
		.ack_debug_o(ack_debug_o), //avisa al test que ya puede ejecutar otro ciclo.
		.end_send_data_o(end_send_data_o) //fin de envio de data.

		/* DEBUG */
		/*.state_o(state_o),
		.data_ready_o(data_ready_o),
		.data_receive_o(data_receive_o),
		.bit_finish_o(bit_finish_o),
		.en_read_load_inst_o(en_read_load_inst_o),
		.receive_full_byte_o(receive_full_byte_o),
		.tx_start_o(tx_start_o)
		*/
		
	);
endmodule