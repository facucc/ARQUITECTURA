`include "parameters.vh"

module reg_MEM_WB
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_WB_CTRL = 3,
		parameter NB_MEM_TO_REG = 2
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire enable_pipe_i,
		input wire halt_detected_i,
		input wire [NB_DATA-1:0] mem_data_i,
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [NB_DATA-1:0] data_inm_i, //dato a escribir en registro (LUI) 
		input wire [NB_WB_CTRL-1:0] WB_control_i,
		input wire [NB_REG-1:0] write_register_i,
		
		output wire [NB_REG-1:0] write_register_o,
		output wire [NB_MEM_TO_REG-1:0] mem_to_reg_o,

		output wire [NB_DATA-1:0] mem_data_o,
		output wire [NB_DATA-1:0] alu_result_o,
		output wire [`ADDRWIDTH-1:0] pc_o,
		output wire [NB_DATA-1:0] inm_ext_o,

		output wire reg_write_o,
		output wire halt_detected_o	
	
	);

	reg [NB_MEM_TO_REG-1:0] mem_to_reg;
	reg [NB_REG-1:0] write_reg;
	reg reg_write;
	reg [NB_DATA-1:0] mem_data_reg, alu_result_reg, inm_ext_reg;

	reg [`ADDRWIDTH-1:0] pc_reg;
	reg halt_detected;

	assign halt_detected_o = halt_detected;
	
	assign mem_to_reg_o     = mem_to_reg;
	assign reg_write_o      = reg_write;
	assign write_register_o = write_reg;

	assign mem_data_o       = mem_data_reg;
	assign alu_result_o     = alu_result_reg;
	assign pc_o             = pc_reg;
	assign inm_ext_o        = inm_ext_reg;

	always @(negedge clock_i)
		begin
			if (reset_i)
				begin
					halt_detected  <= 1'b0;
					mem_to_reg     <= 2'b0;
					reg_write      <= 1'b0;
					write_reg      <= 5'b0;
					mem_data_reg   <= 32'b0;
					alu_result_reg <= 32'b0;
					pc_reg         <= 32'b0;
					inm_ext_reg    <= 32'b0;
				end
			else
				begin
					if (enable_pipe_i)
						begin
							halt_detected  <= halt_detected_i;
							mem_to_reg     <= WB_control_i[1:0];
							reg_write      <= WB_control_i[2];
							write_reg      <= write_register_i;
							mem_data_reg   <= mem_data_i;
							alu_result_reg <= alu_result_i;
							pc_reg         <= pc_i;
							inm_ext_reg    <= data_inm_i;
						end
					else
						begin
							halt_detected  <= halt_detected;
							mem_to_reg     <= mem_to_reg;
							reg_write      <= reg_write;
							write_reg      <= write_reg;
							mem_data_reg   <= mem_data_reg;
							alu_result_reg <= alu_result_reg;
							pc_reg         <= pc_reg;
							inm_ext_reg    <= inm_ext_reg;
						end
				end

		end
endmodule