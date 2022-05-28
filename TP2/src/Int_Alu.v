`timescale 10ns / 1ps
module Int_Alu
	#(
		parameter N_BITS_DATA  = 8,
		parameter N_BITS_OP    = 6,
		parameter N_BITS_STATE = 4
	)
	(
		input wire clock,
		input wire reset,
		input wire rx_empty_i,
		input wire [N_BITS_DATA-1:0] data_i,
		input wire [N_BITS_DATA-1:0] result_alu_i,		
		output wire  tx_done_ticks,								
		output wire [N_BITS_DATA-1:0] dataA_o,
		output wire [N_BITS_DATA-1:0] dataB_o,
		output wire [N_BITS_OP-1:0] dataOp_o,
		output wire [N_BITS_DATA-1:0] result_alu_o
	);

	
	localparam 	[N_BITS_STATE-1:0]          DatoA     =  4'b0001;
	localparam 	[N_BITS_STATE-1:0]			DatoB     =  4'b0010;
	localparam 	[N_BITS_STATE-1:0]			DatoOp    =  4'b0100;
	localparam 	[N_BITS_STATE-1:0]			ResultALU =  4'b1000;


	reg [N_BITS_DATA-1:0] dataA, dataB, dataResult;
	reg [N_BITS_OP-1:0] dataOp;
	reg tx_done_ticks_reg;
	reg read_dataA_en, read_dataB_en, read_dataOp_en, send_tx_result;
	reg [N_BITS_STATE-1:0] state, next_state;

	always @(posedge clock) 
		begin			
			if (reset)
				begin
					state <= DatoA;						
				end
			else
				state <= next_state;
		end

	always @(posedge clock)
    	begin
    		if (reset)
    			dataA <= {N_BITS_DATA{1'b0}};
      		
    		else
    			begin
    				if (read_dataA_en)
		    			dataA <= data_i;
		    		else
		    			dataA <= dataA; 
		    		
    			end
    	end

   	always @(posedge clock)
    	begin
    		if (reset)
    			dataB  <= {N_BITS_DATA{1'b0}};
  
    		else
    			begin
    				if (read_dataB_en)
    					dataB <= data_i;
    				else
		    			dataB <= dataB;	
    			end
    	end

	always @(posedge clock)
    	begin
    		if (reset)
    			dataOp <= {N_BITS_DATA{1'b0}};
    		
    		else
    			begin
    				if (read_dataOp_en)
    					dataOp <= data_i;
    				else
		    			dataOp <= dataOp;
    					
    			end

    	end
    always @(posedge clock)
    	begin
    		if (reset)
   				dataResult <= {N_BITS_DATA{1'b0}};
	
    		else 
    			begin
    				if (send_tx_result)
    					begin
    						dataResult <= result_alu_i;
    						tx_done_ticks_reg <= 1'b1;
    					end
    				else
    					tx_done_ticks_reg <= 1'b0;
    			end
    							
       	end

	always @(*) //logica de cambio de estado
		begin: next_state_logic
		
		    read_dataA_en = 1'b0;
		    read_dataB_en = 1'b0;
			read_dataOp_en = 1'b0;
			send_tx_result = 1'b0;
			next_state = state;

			case (state)
				DatoA:
					begin
						if (rx_empty_i)
							begin
								read_dataA_en = 1'b1;
								next_state  = DatoB;																								
							end
						else
						  begin
						      next_state  = DatoA;						      
						  end
							
											
					end
				DatoB:
					begin
						if (rx_empty_i)
							begin
								read_dataB_en = 1'b1;
								next_state  = DatoOp;								
							end				
					   else
						  begin
						      next_state  = DatoB;						      
						  end						
					end
				DatoOp:					
					begin
						if (rx_empty_i)
							begin
								read_dataOp_en = 1'b1;
								next_state  = ResultALU;								
							end
						else
						  begin
						      next_state  = DatoOp;						      
						  end
								
					end						
				ResultALU: 
					begin
						send_tx_result = 1'b1;
						next_state   = DatoA;
					end
				default:
					next_state = DatoA;					
			endcase
		end
		
	/* salidas */
	assign dataA_o           = dataA;
	assign dataB_o           = dataB;
	assign dataOp_o          = dataOp;
	assign result_alu_o      = dataResult;
	assign tx_done_ticks     = tx_done_ticks_reg;

endmodule