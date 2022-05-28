module shift_left2
	#(
		parameter NB_DATA_1 = 28,
		parameter NB_DATA_2 = 26
	)
	(
		input wire [NB_DATA_1-1:0] data_to_shift_i,
		output wire [NB_DATA_2-1:0] data_to_shift_o	
	);

    assign data_to_shift_o = data_to_shift_i << 2; 
    
endmodule