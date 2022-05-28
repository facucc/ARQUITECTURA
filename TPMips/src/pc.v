`include "parameters.vh"

module pc
	#(
		parameter NB_DATA = `ADDRWIDTH
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire enable_i,				
		input wire [NB_DATA-1:0] next_addr_i,
		output wire [NB_DATA-1:0] next_addr_o
	);

	reg [NB_DATA-1:0] reg_addr;

	always @(negedge clock_i)
		begin
		    if (reset_i)
		        reg_addr <= {NB_DATA{1'b0}};
		    else 
		    	begin
		    		if (enable_i) 
		    		    reg_addr <= next_addr_i;		    		    
	
			        else
			        	reg_addr <= reg_addr;

		    	end 
		end

	assign next_addr_o = reg_addr;

endmodule