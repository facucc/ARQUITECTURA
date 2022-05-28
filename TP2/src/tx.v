`timescale 10ns / 1ps
module tx
	#(
		parameter N_BITS_DATA  = 8,
		parameter N_CONT_TICKS = 4,
		parameter N_BITS_STATE = 5
	)
	(
		input wire s_ticks,
		input wire tx_start,
		input wire clock,
		input wire reset,
		input wire [N_BITS_DATA-1:0] tx_data_in,
		output wire tx_data_out					
	);
	
	localparam COUNT_READ_DATA = 16;

	localparam BIT_START    = 4'd0;
	localparam BIT_DATA     = 4'd8;
	localparam BIT_PARITY   = 4'd9;
	localparam BIT_STOP     = 4'd10;

	localparam 	[N_BITS_STATE-1:0]          Idle   =  5'b00001;
	localparam 	[N_BITS_STATE-1:0]			Start  =  5'b00010;
	localparam 	[N_BITS_STATE-1:0]			Data   =  5'b00100;
	localparam	[N_BITS_STATE-1:0]			Parity =  5'b01000;
	localparam	[N_BITS_STATE-1:0]			Stop   =  5'b10000;
		
	reg [N_CONT_TICKS-1:0] count_ticks;
	reg [N_CONT_TICKS-1:0] count_bit;
    reg tx_reg_out, tx_flag;
	reg [N_BITS_STATE-1:0] state, next_state;
	reg [N_BITS_DATA-1:0] shift_reg;	


	/* guardado del dato de entrada para enviarlo */
	always @(posedge clock) 
		begin			
			if (reset)
				begin										
					shift_reg <= {N_BITS_DATA{1'b0}};					
				end
			else
				begin				
					if (tx_start)
						shift_reg <= tx_data_in;
					else
						shift_reg <= shift_reg;
				end
		end

	always @(posedge clock) //cambio de estado
		begin		
			if (reset)
				state <= Idle;							
			
			else
				state <= next_state;
		end	

    /* conteo de ticks */
	always @(posedge clock) 
		begin		
			if (reset)
				count_ticks <= {N_CONT_TICKS{1'b0}};
			
			else
				begin
					if (tx_flag)
						begin
							if (s_ticks)
								begin									
									if (count_ticks == (COUNT_READ_DATA-1))
										count_ticks <= {N_CONT_TICKS{1'b0}};
									else
										count_ticks <= count_ticks + {{N_CONT_TICKS-1{1'b0}},1'b1};
								end		

							else
								count_ticks <= count_ticks;
						end
					else
						count_ticks <= {N_CONT_TICKS{1'b0}};
				end			 
		end

	/* Conteo de bits */
	always @(posedge clock) 

		begin	
			if (reset)
				count_bit <= {N_CONT_TICKS{1'b0}};
			
			else
				begin
					if (tx_flag)
						begin
							if (s_ticks)
								begin									
									if (count_ticks == (COUNT_READ_DATA-1))
										count_bit <= count_bit + {{N_CONT_TICKS-1{1'b0}},1'b1};
									
									else
										count_bit <= count_bit;
								end		

							else
								count_bit <= count_bit;		
						end
					else
						count_bit <= {N_CONT_TICKS{1'b0}};	
						
				end			 
		end	

	/* Envio de bits */
	always @(posedge clock)
		
		begin
			if(tx_flag)
				begin
					if (count_bit == BIT_START)
						tx_reg_out <= 1'b0;

					else if (count_bit >= 4'd1 && count_bit <= BIT_DATA)
						tx_reg_out <= shift_reg [count_bit-1];

					else if (count_bit == BIT_PARITY)
						tx_reg_out <= 1'b0;

					else //BIT DE STOP 
						tx_reg_out <= 1'b1;
				end
			else 
				tx_reg_out <= 1'b1;				 
					
		end
			
	always @(*)//logica de cambio de estado
		begin: next_state_logic		
		
			tx_flag = 1'b0;			
			next_state = state;
			
			case (state)
				Idle:
					begin : STATE_IDLE								
						next_state = (~tx_start) ? Idle : Start;
					end
				
				Start:
					begin: STATE_START					
						tx_flag = 1'b1;
						next_state = (count_bit == BIT_START) ? Start : Data; 
					end
				
				Data: 
					begin: STATE_DATA
						tx_flag = 1'b1;
						next_state = (count_bit <= BIT_DATA) ? Data : Parity;
					end			
				
				Parity: 
					begin : STATE_PARITY
						tx_flag = 1'b1;
						next_state = (count_bit == BIT_PARITY) ? Parity : Stop;
					end
				Stop:
					begin: STATE_STOP
						tx_flag = 1'b1;
						next_state = (count_bit == BIT_STOP) ? Stop : Idle;											
					end
				
				default:
					begin
						tx_flag = 1'b0;						
						next_state = Idle;
					end
			endcase
		end

	assign tx_data_out		 = tx_reg_out;	
	
endmodule	