`include "parameters.vh"

module reg_IF_ID
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire clock_i,  
		input wire enable_pipe_i,		
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [NB_DATA-1:0] instruction_i,

		output reg [`ADDRWIDTH-1:0] pc_o,
		output reg [NB_DATA-1:0] instruction_o			
	);
	
	always @(negedge clock_i)
		begin
			if (enable_pipe_i)
				begin					
					pc_o          <= pc_i;
					instruction_o <= instruction_i;		
				end
				
			else
				begin
					pc_o <= pc_o;
					instruction_o <= instruction_o;
				end
				
								
		end		
endmodule 