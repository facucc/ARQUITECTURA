`timescale 10ns / 1ps

`define CLK 50000000
`define BAUD_RATE 230400
`define NUM_TICKS 16

module baud_rate_gen_AUX
	#(
		parameter N_BITS = 8,
		parameter N_CONT = `CLK / (`BAUD_RATE * `NUM_TICKS)		
	)
	(	    
		input wire clock,
		input wire reset,
		output wire ticks
	);	

	reg [N_BITS-1:0] count;	

	always @(posedge clock)
	begin : contador
        
		if(reset || count == N_CONT-1)
			begin
			 count <= {N_BITS{1'b0}};
			end			
		else
			begin			    
				count <= count + {{N_BITS-1{1'b0}},1'b1};				
			end
	end
	 
	assign ticks = (count == N_CONT-1) ? 1'b1 : 1'b0;

endmodule