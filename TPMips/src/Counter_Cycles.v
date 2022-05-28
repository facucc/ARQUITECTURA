module Counter_Cycles
	#(
		parameter NB_COUNT = 8
	)
	(
		input wire clock_i,
		input wire reset_i,

		input wire en_count_i,

		output wire [NB_COUNT-1:0] count_cycles_o

	);
	reg [NB_COUNT-1:0] count_cycles_reg;

	assign count_cycles_o = count_cycles_reg;

	always @(posedge clock_i)
		begin
			if (reset_i)
				count_cycles_reg <= 8'b0;
			else
				if (en_count_i)
					begin
						count_cycles_reg <= count_cycles_reg + 1;
					end
				else
					count_cycles_reg <= count_cycles_reg;

		end


endmodule 