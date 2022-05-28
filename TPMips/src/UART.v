`timescale 1ns / 1ps


module uart
	#(
		parameter CLK        = 20E6,
		parameter BAUD_RATE  = 115200,
		parameter NB_DATA = 8
	)
	(		
		input wire clock,
		input wire reset,		
		input wire tx_done_ticks,
		input wire rx_data_i,		 
		input wire [NB_DATA-1:0] Alu_Result_i,
		

		//output wire tx_start_o,
		output wire tx_data_o,
		output wire rx_empty_o,
		output wire tx_done_o,			
		output wire [NB_DATA-1:0] data_o
	);
	/* Señales intermedias para unir los modulos */
	wire conex_1, conex_tx_start, conex_rx_done;
	wire [NB_DATA-1:0] conex_3, conex_tx_result;


	//assign tx_start_o = conex_tx_start;

	baud_rate_gen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) bd
	(
		.clock(clock),
		.reset(reset),
		.ticks(conex_1)
	);

	tx tx
	(
		.clock(clock),
		.reset(reset),
		.s_ticks(conex_1),
		.tx_start(conex_tx_start),						
		.tx_data_in(conex_tx_result),
		.tx_done_o(tx_done_o),
		.tx_data_out(tx_data_o)


	);	

	rx rx
	(
		.clock(clock),
		.reset(reset),
		.s_ticks(conex_1),			
		.rx_data(rx_data_i),
		.rx_done_tick(conex_rx_done),				
		.data_o(conex_3)
	);
	
	IntUART interfaceRXTX
	(
		.clock(clock),
		.reset(reset),
		.rx_done_ticks(conex_rx_done),					
		.dout(conex_3),
		.r_data_o(data_o),			
		.rx_empty_o(rx_empty_o),
		.Alu_Result_i(Alu_Result_i),		
		.tx_data_o(conex_tx_result),
		.tx_start_o(conex_tx_start),
		.tx_done_ticks(tx_done_ticks)
	);

endmodule


