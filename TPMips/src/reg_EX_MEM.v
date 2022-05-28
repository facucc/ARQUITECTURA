`include "parameters.vh"

module reg_EX_MEM
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL = 3
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire enable_pipe_i,
		input wire halt_detected_i,	
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [NB_DATA-1:0] data_write_i, //dato a escribir en memoria
		input wire [NB_DATA-1:0] data_inm_i, //dato a escribir en registro (LUI)
		input wire [NB_REG-1:0] write_register_i,
		input wire [`ADDRWIDTH-1:0] pc_i,

		input wire [NB_MEM_CTRL-1:0] MEM_control_i, //write o read
		input wire [NB_WB_CTRL-1:0] WB_control_i, 
			

		output wire [NB_DATA-1:0] alu_result_o,
		output wire [NB_DATA-1:0] data_write_o, //store
		output wire [NB_DATA-1:0] data_inm_o,
		output wire [NB_REG-1:0] write_register_o,// registro a escribir

		output wire [NB_MEM_CTRL-1:0] MEM_control_o,
		output wire [NB_WB_CTRL-1:0] WB_control_o,		

		output wire [`ADDRWIDTH-1:0] pc_o,
		output wire reg_write_o,
		output wire halt_detected_o	
		
	);

	reg [NB_REG-1:0] write_reg;	
	reg [NB_DATA-1:0] mem_data_reg, alu_result_reg, data_inm_reg;

	reg [NB_MEM_CTRL-1:0] MEM_control_reg;
	reg [NB_WB_CTRL-1:0] WB_control_reg;	
	reg [`ADDRWIDTH-1:0] pc_reg;
	
	reg reg_write, halt_detected;

	assign MEM_control_o    = MEM_control_reg;
	assign WB_control_o     = WB_control_reg;
	assign write_register_o = write_reg;	
	assign alu_result_o     = alu_result_reg;
	assign data_write_o     = mem_data_reg;
	assign data_inm_o       = data_inm_reg;
	assign pc_o             = pc_reg;
	assign reg_write_o      = reg_write;
	
	assign halt_detected_o = halt_detected;

	always @(negedge clock_i)
		begin
			if (reset_i)
				begin
					MEM_control_reg <= 6'b0;
					WB_control_reg  <= 3'b0;					
					pc_reg          <= {`ADDRWIDTH{1'b0}};				
					write_reg       <= 5'b0;					
					alu_result_reg  <= 32'b0;
					mem_data_reg    <= 32'b0;
					data_inm_reg    <= 32'b0;
					reg_write       <= 1'b0;					
				end
			else
				begin
					if (enable_pipe_i)
						begin
							halt_detected   <= halt_detected_i;
							MEM_control_reg <= MEM_control_i;
							WB_control_reg  <= WB_control_i;					
							pc_reg          <= pc_i;					
							write_reg       <= write_register_i;					
							alu_result_reg  <= alu_result_i;
							mem_data_reg    <= data_write_i;
							data_inm_reg    <= data_inm_i;
							reg_write       <= WB_control_i[2];
						end
					else
						begin
							halt_detected   <= halt_detected;
							MEM_control_reg <= MEM_control_reg;
							WB_control_reg  <= WB_control_reg;					
							pc_reg          <= pc_reg;					
							write_reg       <= write_reg;					
							alu_result_reg  <= alu_result_reg;
							mem_data_reg    <= mem_data_reg;
							data_inm_reg    <= data_inm_reg;
							reg_write       <= reg_write;
						end
				end

		end

endmodule