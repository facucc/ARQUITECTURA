module unit_forward
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] ID_EX_rs_i,
		input wire [NB_REG-1:0] ID_EX_rt_i,
		
		input wire [NB_REG-1:0] EX_MEM_write_reg_i,
		input wire [NB_REG-1:0] MEM_WB_write_reg_i,

		input wire EX_MEM_reg_write_i,
		input wire MEM_WB_reg_write_i,

		output reg [1:0] forward_A_o, forward_B_o
	);

	initial
		begin
			forward_A_o = 2'b00;
			forward_B_o = 2'b00;
		end

	always @(*)
		begin
			if ((EX_MEM_reg_write_i == 1'b1) && (ID_EX_rs_i == EX_MEM_write_reg_i))
				forward_A_o = 2'b01;//viene de la etapa MEM
			else if ((MEM_WB_reg_write_i == 1'b1) && (ID_EX_rs_i == MEM_WB_write_reg_i))
				forward_A_o = 2'b10; //viene de la etapa WB
			else
				forward_A_o = 2'b00; //viene del banco de registro
			/* ******************************************** */

			if ((EX_MEM_reg_write_i == 1'b1) && (ID_EX_rt_i == EX_MEM_write_reg_i))
				forward_B_o = 2'b01;//viene de la etapa MEM
			else if ((MEM_WB_reg_write_i == 1'b1) && (ID_EX_rt_i == MEM_WB_write_reg_i))
				forward_B_o = 2'b10; //viene de la etapa WB
			else
				forward_B_o = 2'b00; //viene del banco de registro

		end

endmodule