module branch_forward_unit
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] ID_rs_i,
		input wire [NB_REG-1:0] ID_rt_i,
		
		input wire [NB_REG-1:0] EX_MEM_write_reg_i,
		input wire EX_MEM_reg_write_i,	

		output reg forward_A_o, forward_B_o
	);

	initial 
		begin
			forward_A_o = 0;
			forward_B_o = 0;
		end

	always @(*)
		begin
			if ((EX_MEM_reg_write_i == 1'b1) && (ID_rs_i == EX_MEM_write_reg_i))
				forward_A_o = 1'b1;//viene de la etapa MEM		
			else
				forward_A_o = 1'b0; //viene del banco de registro
			/* ******************************************** */

			if ((EX_MEM_reg_write_i == 1'b1) && (ID_rt_i == EX_MEM_write_reg_i))
				forward_B_o = 1'b1;//viene de la etapa MEM			
			else
				forward_B_o = 1'b0; //viene del banco de registro

		end

endmodule