`timescale 1ns / 1ps

module TOP
	#(
		parameter N_BITS_DATA = 8,
		parameter N_BITS_OP   = 6
	)
	(
		input wire clock,
		input wire reset,
		input wire rx_data_i,
		output wire tx_data_o						
	);

    wire [N_BITS_DATA-1:0] data_out, result, conex_result;
    wire [N_BITS_DATA-1:0] A, B;
    wire [N_BITS_OP-1:0]  Op;
    wire conex_rx_empty, tx_start, conex_tx_sticks;
    wire rd_uart;

    uart uart
	(
		.clock(clock),
		.reset(reset),
		.rx_data_i(rx_data_i),
		.Alu_Result_i(conex_result),
		.tx_done_ticks(conex_tx_sticks),
		.tx_data_o(tx_data_o), //salida del TOP
		.rx_empty_o(conex_rx_empty),
		.data_o(data_out)
	);
	Int_Alu interfaceALU
	(
		.clock(clock),
		.reset(reset),
		.rx_empty_i(conex_rx_empty),
		.data_i(data_out),
		.result_alu_i(result),
		.tx_done_ticks(conex_tx_sticks),
		.dataA_o(A),
		.dataB_o(B),
		.dataOp_o(Op),
		.result_alu_o(conex_result)		
	);
	Alu alu
	(
		.A(A),
		.B(B),
		.Op(Op),
		.salida(result)
	);


endmodule