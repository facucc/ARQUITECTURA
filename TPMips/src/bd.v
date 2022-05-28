`timescale 1ns / 1ps

`define NUM_TICKS 16

module baud_rate_gen
	#(
		parameter CLK        = 50E6,
		//parameter BAUD_RATE  = 9600
		parameter BAUD_RATE  = 230400		
	)
	(	    
		input wire clock,
		input wire reset,
		output wire ticks
	);	

	localparam integer N_CONT = (CLK / (BAUD_RATE*`NUM_TICKS));
  localparam integer N_BITS = $clog2 (N_CONT);
	// Registros.
	reg [N_BITS-1:0] count;	

	always @(posedge clock)
        begin : contador
            
            if(reset || count == N_CONT-1)
              count <= 0;		
            else
              count <= count + 1;
            
        end	 
	assign ticks = (count == N_CONT-1) ? 1'b1 : 1'b0;

endmodule