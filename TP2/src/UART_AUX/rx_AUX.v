`timescale 10ns / 1ps
module rx_AUX
	#(
		parameter N_BITS_DATA  = 8,
		parameter N_CONT_TICKS = 4,
		parameter N_BITS_STATE = 5
	)
	(
		input wire s_ticks,
		input wire clock,
		input wire reset,
		input wire rx_data,				
		output wire rx_done_tick,
		output wire [N_BITS_DATA-1:0] data_o
	);
	localparam COUNT_READ_DATA = 16;

	localparam TICKS_SAMPLE = 3'd7;
	
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
    reg  reg_done_tick, rx_flag, bit_flag, en_reg_done_ticks;
	reg [N_BITS_STATE-1:0] state, next_state;
	reg [N_BITS_DATA-1:0] shift_reg, reg_data_o;
	

	always @(posedge clock) //cambio de estado
		begin		
			if (reset)
				state <= Idle;							
				
			else
				state <= next_state;
		end	

	/* señal de mitad de bit*/
	always @(posedge clock)

		begin
			if(reset)
				bit_flag <= 1'b0;
			else 
				if (count_ticks == TICKS_SAMPLE)
					bit_flag <= 1'b1;
				else 
					bit_flag <= 1'b0;
		end


    /* conteo de  ticks */
	always @(posedge clock) 
		begin: COUNT_TICKS		
			if (reset)
				count_ticks <= {N_CONT_TICKS{1'b0}};		
			
			else
				begin
					if (s_ticks)
						begin
							if (rx_flag)
								begin									
									if (count_ticks == (COUNT_READ_DATA-1))
										count_ticks <= {N_CONT_TICKS{1'b0}};
									else
										count_ticks <= count_ticks + {{N_CONT_TICKS-1{1'b0}},1'b1};
								end		

							else
								count_ticks <= {N_CONT_TICKS{1'b0}};
						end
					else
						count_ticks <= count_ticks;
				end			 
		end

	/* conteo de bits */

	always @(posedge clock) 

		begin	
			if (reset)
				count_bit <= {N_CONT_TICKS{1'b0}};
			
			else
				begin
					if (rx_flag)
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


 	/* Guardado de datos */
	always @(posedge clock)
		begin
			if (reset)
				shift_reg <= {N_BITS_DATA{1'b0}};
			else 
				if(rx_flag)
					if(bit_flag)
						if (count_bit >= 4'd1 && count_bit <= BIT_DATA)
							shift_reg [count_bit-1] <= rx_data; 
						else
							shift_reg <= shift_reg;
					else 
						shift_reg <= shift_reg;
				else 
					shift_reg <= {N_BITS_DATA{1'b0}};
		end

	/* envio de una señal de dato valido a la interfaz RXTX*/
	always @(posedge clock)
		begin
			if (reset)
				reg_done_tick <= 1'b0;

			else
				if (en_reg_done_ticks)
					reg_done_tick <= 1'b1;
				else
					reg_done_tick <= 1'b0;			

		end
    /* Envio la trama recibida a la salida cuando ya haya terminado de recibir la trama*/
	always @(posedge clock)
		begin
			if (reset)
				reg_data_o <= 8'b0;

			else
				if (count_bit ==  BIT_STOP)
					if (bit_flag && rx_data)
						reg_data_o <= shift_reg;
					else
						reg_data_o <= reg_data_o;
				else
					reg_data_o <= reg_data_o;
        end

	always @(*)//logica de cambio de estado
		begin: next_state_logic		
			
			rx_flag = 1'b0;
			en_reg_done_ticks = 1'b0;	
			next_state = state;

			case (state)
				Idle:
					begin : STATE_IDLE
						rx_flag = 1'b0;						
						next_state = (rx_data) ? Idle : Start;
					end
				
				Start:
					begin: STATE_START					
						rx_flag = 1'b1;
						if (bit_flag)
							begin
								if (rx_data)
									next_state = Idle;
								else
									next_state = Start;
							end
						else
							next_state = (count_bit == BIT_START) ? Start : Data; 
					end
				
				Data: 
					begin: STATE_DATA
						rx_flag = 1'b1;
						next_state = (count_bit <= BIT_DATA) ? Data : Parity;
					end			
				
				Parity: 
					begin : STATE_PARITY
						rx_flag = 1'b1;
						next_state = (count_bit == BIT_PARITY) ? Parity : Stop;
					end
				Stop:
					begin: STATE_STOP
						rx_flag = 1'b1;
						if (bit_flag)
							begin
								if (rx_data)
									 begin
                                        next_state = Idle;
                                        en_reg_done_ticks = 1'b1;
                                    end
								else
									next_state = Start;
							end
						else
							next_state = (count_bit == BIT_STOP) ? Stop : Idle;											
					end
				
				default:
					begin
						rx_flag = 1'b0;						
						next_state = Idle;
					end
				 
				
			endcase
		end

	assign data_o 			 = reg_data_o;	
	assign rx_done_tick		 = reg_done_tick;

		
endmodule	