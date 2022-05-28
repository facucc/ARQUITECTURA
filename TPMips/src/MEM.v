`timescale 1ns / 1ps

`include "parameters.vh"

`define MEM_READ 5
`define MEM_WRITE 4

module MEM
	#(
		parameter NB_DATA = 32,
		parameter NB_MEM_CTRL = 6
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire enable_mem_i,
		input wire [NB_MEM_CTRL-1:0] MEM_control_i,
		input wire [`ADDRWIDTH-1:0] alu_result_i, //address
		input wire [NB_DATA-1:0] data_write_i, //dato a escribir en memoria

		input wire [`ADDRWIDTH-1:0] addr_mem_debug_unit_i,
		input wire cntl_addr_debug_mem_i, //addres para mem or debug
		input wire cntl_wr_debug_mem_i, //leyendo para debug
		output wire bit_sucio_o,
		output wire [NB_DATA-1:0] data_mem_debug_unit_o,
	
		output wire [NB_DATA-1:0] mem_data_o		
	);		
	wire [NB_DATA-1:0] conex_data_mem_read;
	wire [NB_DATA-1:0] conex_data_mem_write;

	wire [`ADDRWIDTH-1:0] conex_addr_mem;
	wire [NB_MEM_CTRL-1:0] MEM_control;

	assign data_mem_debug_unit_o = conex_data_mem_read;

	Mux2_1#(.NB_DATA(`ADDRWIDTH)) mux_addr_debug_mem
	(
		.inA(addr_mem_debug_unit_i),
		.inB(alu_result_i),
		.sel(cntl_addr_debug_mem_i),
		.out(conex_addr_mem)
	);
	Mux2_1#(.NB_DATA(NB_MEM_CTRL)) mux_wr_debug_mem
	(
		.inA(6'b101001), //lectura signed para debug
		.inB(MEM_control_i),
		.sel(cntl_wr_debug_mem_i),
		.out(MEM_control)
	);
	cntl_bit_sucio cntl_bit_sucio
	(
		.clock_i(clock_i),
		.reset_i(reset_i),
		.addr_i(conex_addr_mem),
		.mem_write_i(MEM_control[`MEM_WRITE]),

		.bit_sucio_o(bit_sucio_o)

	);
	controller_mem controller_mem
	(		
		.data_write_i(data_write_i),
		.data_read_i(conex_data_mem_read),
		.MEM_control_i(MEM_control),

		.data_write_o(conex_data_mem_write),
		.data_read_o(mem_data_o)		
	);

	mem_data memory_data
	(
		.clock_i(clock_i),
		.enable_mem_i(enable_mem_i),
		.addr_i(conex_addr_mem),		
		.data_write_i(conex_data_mem_write),
		.mem_read_i(MEM_control[`MEM_READ]),
		.mem_write_i(MEM_control[`MEM_WRITE]),

		.data_o(conex_data_mem_read)
	);
endmodule