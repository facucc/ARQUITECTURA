`include "parameters.vh"
`define NOP_INST 32'hF8000000

module TOP_REG_IF_ID
	#(			
		parameter NB_DATA = 32				
	)
	(
		input wire clock_i,		
		input wire reset_wz_i,

		input wire enable_pipe_i,
		input wire jump_or_branch_i,
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [NB_DATA-1:0] instruction_nop,
		input wire [NB_DATA-1:0] instruction_i,	

		output wire locked_o,	
		/* DEBUG */		
		output wire [`ADDRWIDTH-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o

	);

	wire clock_o, locked_wz;
    wire [NB_DATA-1:0] conex_instruction_in;
    
	assign clock_processor = (locked_wz == 1'b1) ? (clock_o) : 1'bz;	
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

  	Mux2_1#(.NB_DATA(NB_DATA)) mux_input_reg
  	(
  		.inA(instruction_nop),
  		.inB(instruction_i),
  		.sel(jump_or_branch_i),
  		.out(conex_instruction_in)
  	);
	reg_IF_ID reg_IF_ID
	(
		.clock_i(clock_processor),		
		.enable_pipe_i(enable_pipe_i),
		.instruction_i(conex_instruction_in),
		.pc_i(pc_i),		
		.instruction_o(instruction_o),	
		.pc_o(pc_o)	
	);

endmodule