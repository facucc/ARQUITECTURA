`timescale 1ns / 1ps

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module mem_inst
	#(
		parameter NB_DATA = 32,
		parameter NBYTE   = 8
	)
	( 
		input wire clock_i,
		input wire en_write_i,
		input wire en_read_i, 		
		
		input wire [`ADDRWIDTH-1:0] addr_i,
		input wire [NB_DATA-1:0] data_i,
		output wire [NB_DATA-1:0] data_o
	
	);

	reg [NB_DATA-1:0] RAM[`N_ELEMENTS-1:0];
    reg [NB_DATA-1:0] data_reg;
	
	always @(posedge clock_i)
		begin
			if (en_write_i) //escritura										
				RAM[addr_i] <= data_i; // little_endian

			else if (en_read_i)
				data_reg <= RAM[addr_i];			
			else 
				data_reg <= data_reg;							
		end
	assign data_o = data_reg;
	
  
endmodule

