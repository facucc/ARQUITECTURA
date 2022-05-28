`timescale 1ns / 1ps

`define BYTE  3'b001
`define HALF_WORD 3'b010
`define WORD 3'b100

`define N_BYTE 7:0
`define N_HALF 15:0

`define MEM_READ 5
`define MEM_WRITE 4
`define SIZE 3:1
`define SIGNED 0

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module controller_mem
	#(
		parameter NB_DATA     = 32,
		parameter NB_MEM_CTRL = 6	    
	)
	(
		input wire [NB_DATA-1:0] data_write_i,		
		input wire [NB_DATA-1:0] data_read_i,
   		input wire [NB_MEM_CTRL-1:0] MEM_control_i,

   		output wire [NB_DATA-1:0] data_write_o,
   		output wire [NB_DATA-1:0] data_read_o
	
	);

	reg [NB_DATA-1:0] reg_data_write;
	reg [NB_DATA-1:0] reg_data_read;	
/*************************************************************************/
	assign data_write_o = reg_data_write;
	assign data_read_o  = reg_data_read;
/*************************************************************************/

	always @(*) //Lectura
		begin	
			if (MEM_control_i[`MEM_READ])
	            begin 	
	                if (MEM_control_i[`SIGNED]) 
	                	begin 
			            	case (MEM_control_i[`SIZE])			            		
				                	`BYTE:	                		
				                		begin
				                			reg_data_read = {{24'b0}, data_read_i[`N_BYTE]};   			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin				                			                			
				                			reg_data_read = {16'b0, data_read_i[`N_HALF]};  
				                    	end
				                    	
				                	`WORD:
				                	  begin
									 		reg_data_read = data_read_i;                   	
				                		end

				                    default:
				                    	reg_data_read = 32'b0;        
	                    	
	                			endcase
	                	end
	              	else
	              		begin
	              			case (MEM_control_i[`SIZE])	              				
				                	`BYTE:	                		
				                		begin
				                			reg_data_read = {{24{data_read_i[7]}}, data_read_i[`N_BYTE]}; 			                			           			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin	                			
				                			reg_data_read = {{16{data_read_i[15]}}, data_read_i[`N_HALF]};   
				                    	end
				                    	
				                	`WORD:
				                	  begin
				                		reg_data_read = data_read_i;                 	
				                		end

				                    default:
				                    	reg_data_read = 32'b0;        
	                    	
	                		endcase
	              		end
	            end	
	        else
				reg_data_read = 32'b0;	  
		end

/*************************************************************************/
	always @(*) //Escritura
		begin
			if (MEM_control_i[`MEM_WRITE])
	            begin    
	            	case (MEM_control_i[`SIZE])
	                	`BYTE:
	                		reg_data_write = data_write_i[`N_BYTE];                
	                            
	                	`HALF_WORD:               
	                    	reg_data_write = data_write_i[`N_HALF];	                    

	                	`WORD:                    
	                    	reg_data_write = data_write_i;         
	                    default:
	                    	reg_data_write = 32'b0;
	                endcase
	            end
	        else
	            reg_data_write = 32'b0;
		end

endmodule