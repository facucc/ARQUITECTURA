`include "parameters.vh"

module reg_ID_EX
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_FUNCTION = 6,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3
	)
	(
		input wire clock_i,   
		input wire reset_i,
		input wire enable_pipe_i,
		input wire halt_detected_i,
		input wire [`ADDRWIDTH-1:0] pc_i,
		input wire [NB_REG-1:0]	rs_i, rt_i, rd_i,
		input wire [NB_REG-1:0]	shamt_i,

		input wire [NB_FUNCTION-1:0] function_i,
		input wire [NB_DATA-1:0] data_ra_i,
		input wire [NB_DATA-1:0] data_rb_i,
		input wire [NB_DATA-1:0] inm_ext_i,

		input wire [NB_EX_CTRL-1:0] EX_control_i,
		input wire [NB_MEM_CTRL-1:0] M_control_i,
		input wire [NB_WB_CTRL-1:0] WB_control_i,

		output wire [NB_DATA-1:0] data_ra_o,
		output wire [NB_DATA-1:0] data_rb_o,
		output wire [NB_DATA-1:0] inm_ext_o,

		output wire [NB_REG-1:0] shamt_o,

		output wire [`ADDRWIDTH-1:0] pc_o,
		output wire [NB_REG-1:0] rs_o, rt_o, rd_o,

		output wire [NB_FUNCTION-1:0] function_o,
		
		output wire [NB_EX_CTRL-1:0] EX_control_o,
		output wire [NB_MEM_CTRL-1:0] M_control_o,
		output wire [NB_WB_CTRL-1:0] WB_control_o,

		output wire halt_detected_o	

		
	);

	reg [`ADDRWIDTH-1:0] pc_reg;
	reg [NB_DATA-1:0] data_ra_reg, data_rb_reg, inm_ext_reg;
	reg [NB_REG-1:0] rs_reg, rt_reg, rd_reg, shamt_reg;

	reg [NB_FUNCTION-1:0] function_reg;
	reg halt_detected;
	reg [NB_EX_CTRL-1:0] EX_control_reg;
	reg [NB_MEM_CTRL-1:0] M_control_reg;
	reg [NB_WB_CTRL-1:0] WB_control_reg;


	assign halt_detected_o = halt_detected;

	always @(negedge clock_i)
		begin
			if (reset_i)
				begin 
					pc_reg     	 <= {`ADDRWIDTH{1'b0}};
					data_ra_reg  <= 32'b0;
					data_rb_reg  <= 32'b0;
					inm_ext_reg  <= 32'b0;
					shamt_reg    <= 5'b0;
					function_reg <= 6'b0;

				end
			else
				begin
					if (enable_pipe_i)
						begin
							halt_detected <= halt_detected_i;
						    pc_reg        <= pc_i;
							data_ra_reg   <= data_ra_i;
							data_rb_reg   <= data_rb_i;
							inm_ext_reg   <= inm_ext_i;
							shamt_reg     <= shamt_i;
							function_reg  <= function_i;
						end
					else
						begin
							halt_detected <= halt_detected;
							pc_reg 	  <= pc_reg;
							data_ra_reg   <= data_ra_reg;
							data_rb_reg   <= data_rb_reg;
							inm_ext_reg   <= inm_ext_reg;
							shamt_reg     <= shamt_reg;
							function_reg  <= function_reg;
						end
				end
		end	

	always @(negedge clock_i)
		begin
			if (reset_i)
				begin
					rs_reg <= 5'b0;
					rt_reg <= 5'b0;
					rd_reg <= 5'b0;
				end
			else
				begin
					if (enable_pipe_i)
						begin
							rs_reg <= rs_i;
							rt_reg <= rt_i;
							rd_reg <= rd_i;
						end	
					else
						begin
							rs_reg <= rs_reg;
							rt_reg <= rt_reg;
							rd_reg <= rd_reg;
						end
				end
		end


	always @(negedge clock_i)
		begin
			if (reset_i)
				begin
					EX_control_reg <= 7'b0;
					M_control_reg  <= 6'b0;
					WB_control_reg <= 3'b0;
				end				
			else
				begin
					if (enable_pipe_i)
						begin
							EX_control_reg <= EX_control_i;
							M_control_reg  <= M_control_i;
							WB_control_reg <= WB_control_i;
						end
					else
						begin
							EX_control_reg <= EX_control_reg;
							M_control_reg  <= M_control_reg;
							WB_control_reg <= WB_control_reg;			
						end
				end				
		end

	assign pc_o    = pc_reg;
	assign data_ra_o = data_ra_reg;
	assign data_rb_o = data_rb_reg;
	assign inm_ext_o = inm_ext_reg;

	assign function_o = function_reg;
	assign shamt_o    = shamt_reg;

	assign rs_o      = rs_reg;
	assign rt_o      = rt_reg;
	assign rd_o      = rd_reg;

	assign EX_control_o = EX_control_reg;
	assign M_control_o = M_control_reg;
	assign WB_control_o = WB_control_reg;


endmodule 