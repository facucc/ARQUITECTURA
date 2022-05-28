
`timescale 10ns / 1ps
module IntUART_AUX
	#(
		parameter N_BITS_DATA = 8
	)
	(
		input wire clock,
		input wire reset,
		input wire [N_BITS_DATA-1:0] dout,
		input wire [N_BITS_DATA-1:0] Alu_Result_i,
		input wire rx_done_ticks,
		input wire tx_done_ticks,		
		output wire rx_empty_o,		
		output wire tx_start_o, 
		//output wire [N_BITS_DATA-1:0] r_data_o,
		output reg [N_BITS_DATA-1:0] r_data_o,
		output wire [N_BITS_DATA-1:0] tx_data_o			
	);

    reg rx_empty_reg, tx_start_reg;
    reg [N_BITS_DATA-1:0] tx_data_reg;
    
	/* TRANSMISOR */
    always @(posedge clock)
    	begin
        	if(reset)
        		tx_start_reg <= 1'b0;
        		
           	else
        		begin        		 	
        			if (tx_done_ticks)
        				tx_start_reg <= 1'b1;		        			
        			else
        				tx_start_reg <= 1'b0;     					
        		end           	
    	end

    always @(posedge clock)
    	begin
        	if(reset)
        		tx_data_reg <= {N_BITS_DATA{1'b0}};

        	else
        		begin
        			if (tx_done_ticks)
        				tx_data_reg <= Alu_Result_i;
        			else		
        				tx_data_reg <= tx_data_o;
        		end
        end

    always @(posedge clock)
		begin
			if (reset)
				rx_empty_reg <= 1'b0;

			else
				if (rx_done_ticks)
					rx_empty_reg <= 1'b1;
				else
					rx_empty_reg <= 1'b0;
		end

    /* RECEPTOR */
	always @(posedge clock)
		begin
			if (reset)
				r_data_o <= {N_BITS_DATA{1'b0}};
									
			else
				begin				 	
					if (rx_done_ticks)
						r_data_o <= dout;
					else				
						r_data_o <= dout;				
				end
		end

	assign tx_start_o    = tx_start_reg;
	assign rx_empty_o    = rx_empty_reg;
	assign tx_data_o     = tx_data_reg;		

endmodule