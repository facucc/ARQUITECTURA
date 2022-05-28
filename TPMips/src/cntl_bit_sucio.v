
`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module cntl_bit_sucio
	(
		input wire clock_i,
		input wire reset_i, 
		input wire [`ADDRWIDTH-1:0] addr_i,
		input wire mem_write_i,

		output wire bit_sucio_o
	);
	reg [`N_ELEMENTS-1:0] bit_sucio_reg;

	assign bit_sucio_o = bit_sucio_reg[addr_i];

	always @(negedge clock_i)
		begin
		    if (reset_i)
		    	begin
		    		bit_sucio_reg    <= 0;
		    		bit_sucio_reg[0] <= 1'b1;
		    		bit_sucio_reg[1] <= 1'b1;
		    		bit_sucio_reg[2] <= 1'b1;
		    		bit_sucio_reg[3] <= 1'b1;
		    		bit_sucio_reg[4] <= 1'b1;
		    		bit_sucio_reg[5] <= 1'b1;
		    	end
		    else
			    begin
			        if (mem_write_i) 
			            bit_sucio_reg[addr_i] <= 1'b1;
			       
			        else 
			            bit_sucio_reg <= bit_sucio_reg;	        
			    end
	  	end
endmodule
