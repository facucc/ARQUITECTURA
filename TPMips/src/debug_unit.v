`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000

module debug_unit
	#(
		parameter CLK        = 50E6,
		parameter BAUD_RATE  = 9600,
		parameter NB_DATA    = 32,
		parameter NB_REG     = 5,
		parameter N_BITS     = 8,
		parameter N_BYTES    = 4,		
		parameter NB_STATE   = 12,
		parameter N_COUNT	 = 10,
		parameter N_REGISTER = 32				
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire halt_i,	
		input wire rx_data_i,	
		input wire [`ADDRWIDTH-1:0] data_send_pc_i, //pc + 1
		input wire [N_BITS-1:0] count_cycles_i,
		input wire [NB_DATA-1:0] data_reg_debug_unit_i, //viene del banco de registros
		input wire bit_sucio_i,
		input wire [NB_DATA-1:0] data_mem_debug_unit_i,

		output reg [NB_REG-1:0] addr_debug_unit_o,// direccion a leer del registro para enviar a pc

		output wire [`ADDRWIDTH:0] addr_mem_debug_unit_o, //direccion a leer en memoria
		output reg cntl_addr_debug_mem_o,
		output reg cntl_wr_debug_mem_o,
		output wire tx_data_o,
		output wire en_write_o,
		output wire en_read_o,		
		output reg enable_pipe_o,
		output reg enable_mem_o,
		output reg cntl_read_debug_reg_o,
		output wire debug_unit_o,				
		output wire [NB_DATA-1:0] inst_load_o, //instruccion a cargar en memoria
		output wire [`ADDRWIDTH-1:0] address_o, //direccion donde se carga la instruccion
		output reg ack_debug_o, //avisa al test que ya puede enviar el comando
		output reg end_send_data_o //avisa al test que ya se termino de enviar datos de memoria

		/* para DEBUG */
		/*
		output wire data_ready_o,		
		output wire en_read_load_inst_o,
		output wire receive_full_byte_o,
		output wire bit_finish_o,
		output wire [NB_STATE-1:0] state_o,
		output wire [N_BITS-1:0] data_receive_o,
		output wire tx_start_o		*/	
	
	);

	localparam 	[NB_STATE-1:0]          Count_Instr        		=  12'b000000000001;
	localparam 	[NB_STATE-1:0]			Receive_Instr      		=  12'b000000000010;
	localparam 	[NB_STATE-1:0]			Sending_Instr 	   		=  12'b000000000100;
	localparam 	[NB_STATE-1:0]			Waiting_operation  		=  12'b000000001000;
	localparam 	[NB_STATE-1:0]			Check_Operation    		=  12'b000000010000;
	localparam 	[NB_STATE-1:0]			Step_to_step       		=  12'b000000100000; //32
	localparam 	[NB_STATE-1:0]			Step_to_step_2     		=  12'b000001000000; //64
	localparam 	[NB_STATE-1:0]			Continue  		   		=  12'b000010000000; //128
	localparam 	[NB_STATE-1:0]			Sending_data_pc    	   	=  12'b000100000000; //256
	localparam 	[NB_STATE-1:0]			Sending_count_cyles 	=  12'b001000000000; //512
	localparam 	[NB_STATE-1:0]			Sending_data_registers	=  12'b010000000000; //1024
	localparam 	[NB_STATE-1:0]			Sending_data_mem		=  12'b100000000000; //2048

	
    wire data_ready_i;
	reg en_read_load_inst, read_byte_en, receive_full_byte, read_reg, rw_reg, send_instr_en, bit_finish, read_op_en;

	/* Finish send data*/
	reg data_send_pc_end;
	reg data_send_cycles_end;
	reg data_send_reg_end;
	reg data_send_mem_end;

	/******************/
	reg [N_BYTES-2:0] count_bytes;
	
	reg [N_BITS-1:0] mode_op;
	wire [N_BITS-1:0] data_i;
	reg [N_COUNT-1:0] count_instruction, count_instruction_now;
	reg [`ADDRWIDTH-1:0] address_reg;
	reg [NB_DATA-1:0] instructions;
	reg [NB_STATE-1:0] state, next_state;
	reg [NB_REG-1:0] addr_debug_unit_reg;
    reg [`ADDRWIDTH:0] addr_mem_debug_unit_reg;
	reg  debug_unit_reg, enable_pipe_reg;

	/* enable envio de datos */
	reg en_send_data_pc, en_send_data_reg, en_send_data_mem, en_send_count_cyles;	

	reg [N_BITS-1:0] cont_byte;
	//reg [N_BITS*5-1:0] mem_data;
		
	/* ********************************************** */
	reg tx_start;
	wire tx_done;
	reg data_ready, next_state_ok, tx_done_data, bit_end_send_reg;

	reg en_change_state, en_next_state;	
	reg [N_BITS-1:0] data_send, data_send_reg;   
		
	assign en_write_o    = rw_reg;
	assign en_read_o     = read_reg;
	assign inst_load_o   = instructions;
	assign address_o     = address_reg;
	assign debug_unit_o   = debug_unit_reg;		
	assign addr_mem_debug_unit_o = addr_mem_debug_unit_reg;

	/*
	assign state_o = state;
	assign data_ready_o = data_ready_i;
	assign data_receive_o = data_i;
	assign en_read_load_inst_o = en_read_load_inst;
	assign receive_full_byte_o = receive_full_byte;
	assign bit_finish_o = bit_finish;	
	*/

	/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge clock_i) 
		begin			
			if (reset_i)
				enable_pipe_o <= 1'b0;						
			else
				enable_pipe_o <= enable_pipe_reg;
		end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge clock_i) 
		begin			
			if (reset_i)
				state <= Count_Instr;						
			else
				state <= next_state;
		end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge clock_i)
    	begin
    		if (reset_i)
    			begin
    				//$display("Reset ok");
    				count_instruction <= {N_COUNT{1'b0}};
    				next_state_ok     = 1'b0;
    			end	
    		else
    			begin
    				if (en_read_load_inst)
    					begin
    						if (data_ready_i)
    							begin
    								next_state_ok     = 1'b1;
    								count_instruction = data_i;
    								//$display("Cantidad de instrucciones %d", count_instruction);
    							end
    						else
    							begin
    								next_state_ok     = 1'b0;
    								count_instruction <= count_instruction;    								    							
    							end    						
    					end		    			
		    		else
		    			begin
		    				next_state_ok  = next_state_ok;
		    				count_instruction <= count_instruction;		    				
		    			end	  
    			end
    	end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    always @(posedge clock_i)
    	begin
    		if (reset_i)
    			begin
    				receive_full_byte = 1'b0;
    				count_bytes <= {N_COUNT{1'b0}};
    			end  	
    		else
    			begin
    				if (read_byte_en)
    					begin    						
    						if (data_ready_i)
    							begin
    								if (count_bytes == N_BYTES-1)
		    							begin
		    							//$display("oandaan");		    								
		    								receive_full_byte = 1'b1;
		    								count_bytes <= {N_COUNT{1'b0}};
		    							end    						
		    						else
		    							begin		    								
		    								receive_full_byte = 1'b0;
		    								count_bytes <= count_bytes + {{N_COUNT-1{1'b0}},1'b1};
		    							end
		    					end
		    				else
		    					begin		    						
		    						receive_full_byte = 1'b0;
		    						count_bytes <= count_bytes; 
		    					end    						
    							
    					end		    			
		    		else
		    			begin		    			
		    				receive_full_byte = 1'b0;
		    				count_bytes <= count_bytes; 
		    			end 			
		    		
    			end
    	end

/* +++++++++++++++ INCREMENTO ADDRES LOAD INSTR ++++++++++ */
    always @(posedge clock_i)
    	begin
    		if (reset_i) 
    			address_reg <= {`ADDRWIDTH{1'b0}};
    		else
    			begin
    				if (send_instr_en)
    					address_reg <= count_instruction_now + 1;
    				else
    					address_reg <= address_reg;
    			end
    	end
/* +++++++++++++++ LOAD INSTRUCTION MEMORY +++++++++++++++ */
    always @(posedge clock_i)
    	begin
    		if (reset_i)
    			instructions <= {N_COUNT{1'b0}};
      		
    		else
    			begin
    				if (read_byte_en)
    					begin
    						if (data_ready_i)
   								instructions <= { data_i, instructions[31:8]};
      						else
    							instructions <= instructions;
    					end    			
		    		else
		    			instructions <= instructions; 
		    		
    			end
    	end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    always @(posedge clock_i)
    	begin
    		if (reset_i)
    			mode_op <= {N_COUNT{1'b0}};
      		
    		else
    			begin
    				if (read_op_en)
    					mode_op <= data_i;						
 	    					    			
		    		else
		    			mode_op <= mode_op;
		    		
    			end
    	end

	always @(posedge clock_i)
    	begin
    		if (reset_i)
    			en_change_state <= 1'b0;
    		else
    			begin
    				if (en_next_state)
    					begin
    						en_change_state <= 1'b0;

    						if (data_ready_i)
  								en_change_state <= 1'b1;
    					end		    			
		    		else
		    			en_change_state <= en_change_state;
    			end
    	end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    always @(posedge clock_i)
    	begin
    		if (reset_i)
    			begin
    				bit_finish = 1'b0;
    				count_instruction_now <= {N_COUNT{1'b0}};
    			end
    			
    		else
    			begin
    				if (send_instr_en)
    					begin
    						if (count_instruction_now == count_instruction-1)
    							begin
    								bit_finish = 1'b1;    								
    								count_instruction_now <= {N_COUNT{1'b0}}; 
    							end    							
    						else
    							begin
    								bit_finish = 1'b0;
    								count_instruction_now <= count_instruction_now + 1;
    							end
    							
    					end
    					
    				else
    					begin
    						bit_finish = bit_finish;
    						count_instruction_now <= count_instruction_now;  						
    					end
    					
    			end
    	end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */     
   always @(negedge clock_i)
    	begin 			
    		if (reset_i)
    			begin
    				addr_debug_unit_o <= 5'b0;
    				data_send_reg_end <= 1'b0;
    				data_send_cycles_end <= 1'b0;
    				addr_mem_debug_unit_reg <= 8'b0;
    				data_send 		  <= 8'b0;
    				cont_byte 		  <= 8'b0;
    				data_send_pc_end  <= 1'b0;
    				//mem_data          <= 40'b0;    				   				 				
    			end    			
    		else
    			begin //envio de pc
    				if (en_send_data_pc)
    					begin  
    						data_send_pc_end = 1'b0;    						

    						if (tx_done)
    							begin 	
		    						if (cont_byte == 1'b1)
		    							begin
		    								data_send_pc_end = 1'b1;		    								
		    								cont_byte 		 <= 8'b0;
		    							end	    						 
		    						else
		    							begin
		    										    						 	
		    						 		data_send = data_send_pc_i;		    						 		
		    						 		cont_byte = cont_byte + 1;    						
    										tx_start = 1'b1;    										
		    						 	end 						  				
						  		end						    	  							
  
	    					else
	    						tx_start = 1'b0;						    	  						
		    			end
		    		else if (en_send_count_cyles)
		    			begin
							data_send_cycles_end = 1'b0;

							if (tx_done)
				    			begin
				    			    if (cont_byte == 1'b1)
										begin
											data_send_cycles_end = 1'b1;
											cont_byte 		 <= 8'b0;											
										end
									else
										begin
											data_send = count_cycles_i;
					    					cont_byte = cont_byte + 1;					    					     								
					    					tx_start = 1'b1;					    					
										end	 
		    					end
		    				else
		    					begin
		    						tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
		    					end 
		    			end
		    		else if (en_send_data_reg)
						begin							
							data_send_reg_end = 1'b0;

							addr_debug_unit_o <= addr_debug_unit_o;							
							if (tx_done)
	    						begin	
	    							if (cont_byte == N_BYTES)
				    					begin
				    						data_send_reg_end = 1'b1;
				    						addr_debug_unit_o <= addr_debug_unit_o + 1;				    						
				    						cont_byte 		  <= 8'b0;
				    					end
				    				else 
				    					begin
					    					data_send = data_reg_debug_unit_i[8*cont_byte+:8];
					    					cont_byte = cont_byte + 1;
					    					//data_send = data_reg_debug_unit_i>>(8*cont_byte);								    		
								    		
								    		tx_start = 1'b1;  								
					    				end	 
			    				end
			    			else
			    				begin			    					
			    					tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
			    				end
			    		end
			    	else if (en_send_data_mem)
						begin
							data_send_mem_end = 1'b0;
							addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg;

							if (tx_done)
				    			begin				    				
				    				if (bit_sucio_i)
				    					begin
				    						if (cont_byte == N_BYTES)
				    							begin
				    								data_send_mem_end = 1'b1;
				    								addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;				    								
				    								cont_byte 		 <= 8'b0;
				    							end
				    						else
				    							begin
				    								//mem_data = {data_mem_debug_unit_i, addr_mem_debug_unit_reg};
						    						data_send = data_mem_debug_unit_i[8*cont_byte+:8];	
						    						//data_send = mem_data[8*cont_byte+:8];					    											    						
						    						cont_byte = cont_byte + 1;			                                            									    		
										    		tx_start = 1'b1;										    		
										    	end	
				    					end
				    				else
				    					begin
				    						data_send_mem_end = 1'b1;
				    						addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;					    						
										end
			    						
				    			end
				    		else
			    				begin			    					
			    					tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
			    				end
				    	end 
		    		else 
		    			begin
		    				data_send_pc_end  = 1'b0;
		    				data_send_reg_end = 1'b0;
							data_send_cycles_end = 1'b0;
		    				data_send_mem_end = 1'b0;
					    	data_send <= data_send;
					    	cont_byte <= cont_byte;  
		    			end
		    	end
		end
   	
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
		    
			next_state = state;

			read_op_en = 1'b0;
			rw_reg = 1'b0;
			read_reg = 1'b0;
			read_byte_en = 1'b0;  // habilita leer bytes de las instr.
			en_read_load_inst = 1'b0; // habilita leer la cantidad de instrucciones a cargar en memoria
			send_instr_en = 1'b0; // habilita cargar en memoria instruccion por instr.

			en_next_state = 1'b0;
			enable_mem_o = 1'b0;			
			debug_unit_reg = 1'b1; 
			
			enable_pipe_reg = 1'b0;			

			ack_debug_o = 1'b0;	//habilita a la pc a enviar datos				
			end_send_data_o = 1'b0;	
			/* envio de datos*/
			en_send_data_pc   = 1'b0;
			en_send_data_reg    = 1'b0;
			en_send_data_mem    = 1'b0;
			en_send_count_cyles = 1'b0;

			cntl_read_debug_reg_o = 1'b0;
				
			
			cntl_addr_debug_mem_o = 1'b0;
			cntl_wr_debug_mem_o = 1'b0;			
			case (state)
				Count_Instr:
					begin							
						en_read_load_inst = 1'b1;
						
						if (next_state_ok)
							begin								
								next_state  = Receive_Instr;
								en_read_load_inst = 1'b0;
							end								
						else
						    next_state  = Count_Instr;						      
						
											
					end			
				Receive_Instr:
					begin
						next_state = Receive_Instr;
						read_byte_en = 1'b1;					
						if (receive_full_byte)
							begin																												
								next_state = Sending_Instr;
								send_instr_en = 1'b1;
								rw_reg = 1'b1;																
							end								      
						  					
					end				
				Sending_Instr:					
					begin
						send_instr_en = 1'b0;
						//$display("Sending inst");						
						if (bit_finish)
							begin	
								ack_debug_o = 1'b1;
						//		$display("Pasando a waiting");
								next_state  = Waiting_operation;								
							end
						else
							next_state  = Receive_Instr;	
					end	
				Waiting_operation:
					begin
						//$display("state Waiting_operation");
						en_next_state = 1'b1;
						debug_unit_reg = 1'b0;						

						if (en_change_state)
							begin								
								next_state = Check_Operation;
								read_op_en = 1'b1;
							end											
						else
							next_state = Waiting_operation;				

					end					
				Check_Operation:
					begin						
						debug_unit_reg = 1'b0;
						case (mode_op)
							`mode_step_to_step:
								next_state = Step_to_step;	
							`mode_continue:
								next_state = Continue;	
							default:
								next_state = Waiting_operation;
						endcase				
					end						
				Step_to_step:
					begin
						read_reg = 1'b1;
						enable_pipe_reg = 1'b1;
						enable_mem_o = 1'b1;							
						
						debug_unit_reg = 1'b0;
						rw_reg = 1'b0;						
						next_state = Step_to_step_2;

					end
				Step_to_step_2:
					begin
						read_reg = 1'b1;	
						debug_unit_reg = 1'b0;
						rw_reg = 1'b0;	

						en_send_data_pc = 1'b1;
						next_state = Sending_data_pc;
						

						if (halt_i)
							begin
								enable_pipe_reg = 1'b0;															
								en_send_data_pc = 1'b1;
							end
					end	
				Continue:
					begin						
						read_reg = 1'b1;
						enable_pipe_reg = 1'b1;
						enable_mem_o = 1'b1;						
						next_state = Continue;
						debug_unit_reg = 1'b0;
						rw_reg = 1'b0;						
						
						if (halt_i)
							begin
								//$display("END halt");	
								enable_pipe_reg = 1'b0;
								en_send_data_pc = 1'b1;
								next_state = Sending_data_pc;
								
							end
				
					end				
				Sending_data_pc:
					begin							
						debug_unit_reg = 1'b0;
						en_send_data_pc = 1'b1;
						next_state = Sending_data_pc;						

						if (data_send_pc_end)
							begin																							
								en_send_data_pc = 1'b0;	
								next_state = Sending_count_cyles;							
							end	
					end	
				Sending_count_cyles:
					begin						
						debug_unit_reg = 1'b0;
						en_send_count_cyles = 1'b1;						
						next_state = Sending_count_cyles;

						if (data_send_cycles_end)
							begin
								en_send_count_cyles = 1'b0;
								cntl_read_debug_reg_o = 1'b1;													
								next_state = Sending_data_registers;
							end												
					end				
				Sending_data_registers:
					begin						
						debug_unit_reg = 1'b0;
						en_send_data_reg = 1'b1;
						cntl_read_debug_reg_o = 1'b1;
						next_state = Sending_data_registers;
					
						if (data_send_reg_end)
							begin								
								if (addr_debug_unit_o == 5'b0)
	    							begin
	    								//$display("Pasando a enviar memoria");
	    								cntl_read_debug_reg_o = 1'b0;
	      								en_send_data_reg = 1'b0;

										next_state = Sending_data_mem;										
										cntl_wr_debug_mem_o = 1'b1;
										cntl_addr_debug_mem_o = 1'b1;
										enable_mem_o = 1'b1;										
	    							end	    							
							end
					end				
				Sending_data_mem:
					begin	
						debug_unit_reg = 1'b0;
						cntl_wr_debug_mem_o = 1'b1;
						cntl_addr_debug_mem_o = 1'b1;
						en_send_data_mem = 1'b1;
						enable_mem_o = 1'b1;
					
						next_state = Sending_data_mem;
						if (data_send_mem_end)
							begin
								if (addr_mem_debug_unit_reg == `N_ELEMENTS-1)
									begin
										end_send_data_o = 1'b1;										
										en_send_data_mem = 1'b1;										
										ack_debug_o = 1'b1;
										next_state = Waiting_operation;
										//$display("FINISH ENVIO DE DATOS");	
									end	
							end		
					end
					
							
				default:
					next_state = Count_Instr;					
			endcase
		end
	

	uart#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) uart
	(
		.clock(clock_i),
		.reset(reset_i),
		.Alu_Result_i(data_send), //dato a enviar a la PC
		.rx_data_i(rx_data_i),
		.tx_done_o(tx_done),
		.rx_empty_o(data_ready_i),		
		.tx_data_o(tx_data_o),
		.tx_done_ticks(tx_start),
		//.tx_start_o(tx_start_o),
		.data_o(data_i)
	);

	
endmodule