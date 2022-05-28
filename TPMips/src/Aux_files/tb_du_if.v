`timescale 10ns / 1ps

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000
//`define ClockPeriodo 10 //(1/(`timescale *ClockPeriodo)) => frecuencia 1/(10ns*10) = 10 Mhz 
`define ClockPeriodo 2 // 50 Mhz

`define CANT_TICKS 16
`define NULL 0 

`define N_BYTES 4
`define N_REGISTER 33
`define BYTE_PC 4
`define N_INSTRUCTIONS 8

`define T_PASSED 255

`define Time_Delay (`ClockPeriodo*163*`CANT_TICKS*3)

module tb_du_if; 

    parameter N_BITS_DATA = 8;
    parameter NB_DATA     = 32;	
    parameter N_BITS_OP   = 6;
    parameter NB_SEND     = ((`N_REGISTER+1)*NB_DATA)+N_BITS_DATA;
    /* top */
	reg clk;
	reg rst;
    wire tx_data_out;
    wire data_sending;
    reg tx_start, rd_uart;
   

	wire tx_data_o;
	wire rx_data_o;
	
	wire enable_pipe, enable_clock, debug_unit_o, en_write, en_read, en_read_reg;

	wire [NB_DATA-1:0] addr_load_inst, inst_load;
	reg halt;
	reg [NB_SEND-1:0] data_send;

    reg [NB_DATA-1:0] memory [0:`N_INSTRUCTIONS*4]; 
        /* uart aux */
    reg [N_BITS_DATA-1:0] data_in;

    wire [N_BITS_DATA-1:0] data_out;   
   
    wire data_ready;

    integer i, j;   
    
	initial

        begin   
        #0          
            clk  = 0;
            rst  = 0;
            data_in = 0;
            tx_start = 1'b0; 
            halt = 1'b0;
            data_send = 0;
           	                  
        #5  
            rst = 1;
            
        #10
            rst = 0;

        $readmemh("../../../../../../code_machine.txt", memory);
            for (i=0; i<`N_INSTRUCTIONS; i=i+1)
                begin
                    $display("valor :%h",memory[i]);
                end
           
        data_in = `N_INSTRUCTIONS; //numero de instrucciones

        tx_start = 1'b1;
        #10
        tx_start = 1'b0; 

        for (i = 0; i < `N_INSTRUCTIONS; i = i+1)
            begin           
                for (j = 0; j < `N_BYTES; j = j+1)
                    begin
                        #`Time_Delay   
                        data_in = memory[i]>>(8*j);
                        $display("sending data [%b][%h]", data_in, data_in);               
                        tx_start = 1'b1;
                        #10
                        tx_start = 1'b0;                        
                    end
            end
         #`Time_Delay 
            data_in = `mode_step_to_step;
            tx_start = 1'b1;
        #10
            tx_start = 1'b0;
            j = 0;           
            
            wait(en_read == 1'b1);

            $finish;
       end
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk;
	   end

	debug_unit debug_unit
	(
		.clock_i(clk),
		.reset_i(rst),

		.halt_i(halt),
		.data_send_i(data_send),
		.rx_data_i(tx_data_o),

		.tx_data_o(rx_data_o),

		.enable_pipe_o(enable_pipe),
		.enable_clock_o(enable_clock),
		.debug_unit_o(debug_unit_o),
		
		.en_write_o(en_write),
		.en_read_o(en_read),
		
		.enable_read_reg_o(en_read_reg),
		.address_o(addr_load_inst),
		.inst_load_o(inst_load)
	);

	uart_AUX uart_aux
    (
        .clock(clk),
        .reset(rst),
        .rx_empty_o(data_ready),
        .rx_data_i(rx_data_o),        
        .tx_done_ticks(tx_start),
        .Alu_Result_i(data_in),
        .tx_data_o(tx_data_o),        
        .data_o(data_out)
    );     

endmodule