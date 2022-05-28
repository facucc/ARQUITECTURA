`include "parameters.vh"

module TOP_mem_inst
	#(	
		parameter CLK         = 30E6,
		parameter BAUD_RATE  = 203400,	
		parameter NB_DATA = 32,	
		parameter NB_REG  = 5,
		parameter N_BITS  = 8				
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire reset_wz_i,		

		input wire en_write_i, en_read_i,
		input wire [`ADDRWIDTH-1:0] wr_addr_i, // enviado por debug_unit para cargar instruccion 			
		input wire [NB_DATA-1:0] inst_load_i, //instruccion a cargar en la memoria por debug_unit
		
		output wire locked_o,	
		//output wire [`ADDRWIDTH-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o			
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

	mem_inst mem_instruction
	(
		.clock_i(clock_processor),				
		.addr_i(wr_addr_i),
		.en_write_i(en_write_i),
		.en_read_i(en_read_i),
		.data_i(inst_load_i),
		.data_o(instruction_o)
	);


endmodule