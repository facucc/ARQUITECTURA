`timescale 10ns / 1ps

`define NUM_TICKS 16

module baud_rate_gen_AUX
	#(
		parameter CLK        = 100E6,
		parameter BAUD_RATE  = 9600
		//parameter BAUD_RATE  = 230400		
	)
	(	    
		input wire clock,
		input wire reset,
		output wire ticks
	);	

	localparam integer N_CONT = (CLK / (BAUD_RATE*`NUM_TICKS));
    localparam N_BITS = $clog2 (N_CONT);
	// Registros.
	reg [N_BITS-1:0] count;		

	always @(posedge clock)
		begin : contador
	        
			if(reset || count == N_CONT-1)
				count <= {N_BITS{1'b0}};
			
			else
				count <= count + {{N_BITS-1{1'b0}},1'b1};				

		end
	 
	assign ticks = (count == N_CONT-1) ? 1'b1 : 1'b0;

endmodule