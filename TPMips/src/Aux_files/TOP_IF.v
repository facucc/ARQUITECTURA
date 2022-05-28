`include "parameters.vh"

module TOP_IF
	#(
		parameter NB_DATA = 32,
		parameter N_BITS_DATA = 8
	)
	(
		input wire clock_i,
		input wire reset_wz_i,
		input wire reset_i,

		input wire en_write_i,
		input wire en_read_i,
		input wire debug_unit_i,
		input wire enable_i,
		//input wire enable_mem_i,		
		input wire [1:0] pc_src_i,

		input wire [`ADDRWIDTH-1:0] wr_addr_i,
		input wire [NB_DATA-1:0] instruction_i,

		input wire [`ADDRWIDTH-1:0] addr_register_i,
		input wire [`ADDRWIDTH-1:0] addr_branch_i,
		input wire [`ADDRWIDTH-1:0] addr_jump_i,

		output wire locked_o,
		output wire halt_o,
		output wire [NB_DATA-1:0] instruction_o,
		output wire [`ADDRWIDTH-1:0] pc_o	
	);	
	wire clock_o, locked_wz;

	assign clock_processor = (locked_wz == 1'b1) ? (clock_o) : 1'b0;		
	assign locked_o = locked_wz;
	
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
		.en_write_i(en_write_i),
		.en_read_i(en_read_i),
		.debug_unit_i(debug_unit_i),

		//.enable_mem_i(enable_mem_i),
		.enable_i(enable_i),
		.inst_load_i(instruction_i),
		.wr_addr_i(wr_addr_i), //address instr debu_unit		
		.pc_src_i(pc_src_i), //viene de ID
		
		.addr_register_i(addr_register_i),
		.addr_branch_i(addr_branch_i),
		.addr_jump_i(addr_jump_i),

		.instruction_o(instruction_o),
		/*.pc_src_o(pc_src_o),
		.pc_i_mem_o(pc_i_mem_o),*/		
		.pc_o(pc_o),
		.halt_o(halt_o)
	);
	
endmodule