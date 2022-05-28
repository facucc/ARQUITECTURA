`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000

`define ClockPeriodo 10

`define CANT_TICKS 16

`define CLK_AUX 20
`define BAUD_RATE 115200

`define N_BYTES 4
`define N_REGISTER 32
`define N_BYTES_MEM 128
`define N_BYTES_CYCLES 1
`define N_BYTES_PC 4

`define N_INSTRUCTIONS 2

`define CICLOS 5

`define Time_Delay (`ClockPeriodo*163*`CANT_TICKS*3)


module tb_uart; 

    parameter N_BITS_DATA = 8;
    parameter NB_STATE   = 12;
    parameter NB_DATA = 32;	
    parameter N_BITS_OP   = 6;
    /* top */
	reg clk, clk_2;
	reg rst, rst_wz;
    wire tx_data_o_uart1;
    wire tx_data_o_uart2;    
    reg tx_start;
    wire locked;
    reg [NB_DATA-1:0] memory [0:`N_INSTRUCTIONS*4]; 
        /* uart aux */
    reg [N_BITS_DATA-1:0] data_in;      
    wire [N_BITS_DATA-1:0] data_out; 

     
    wire data_ready, data_ready_2; 
    wire tx_done, rx_done;
    integer i, j;
    
	initial

          begin   
        #0          
            clk  = 0;
            clk_2 = 0;
            rst  = 0;
            rst_wz = 0;
            data_in = 0;
            tx_start = 1'b0; 
                          
        #5             
            rst_wz = 1;
            
        #10            
            rst_wz = 0;
   
        $readmemh("code_machine.txt", memory); //beha
        //$readmemh("../../../../../../code_machine.txt", memory); //sintesis
            for (i=0; i<`N_INSTRUCTIONS; i=i+1)
                begin
                    $display("valor :%h",memory[i]);
               end

        #20
        
        wait(locked == 1'b1);
        
        #8
            rst = 1;

        #`CLK_AUX
            rst = 0;
        #5
        data_in = `N_INSTRUCTIONS; //numero de instrucciones

        tx_start = 1'b1;
        #`CLK_AUX
        tx_start = 1'b0; 

        for (i = 0; i < `N_INSTRUCTIONS; i = i+1)
            begin           
                for (j = 0; j < `N_BYTES; j = j+1)
                    begin
                        #`Time_Delay 
                        wait(tx_done == 1'b1);  
                        data_in = memory[i]>>(8*j);
                        $display("sending data [%b][%h]", data_in, data_in);
                        #5               
                        tx_start = 1'b1;
                        #`CLK_AUX
                        tx_start = 1'b0;                        
                    end  
            end
        j = 0;
        

   end
      always
        begin
           #(`ClockPeriodo/2) clk = ~clk; //100 MHZ
        end

    always
        begin
            #(`ClockPeriodo) clk_2 = ~clk_2; //20 MHZ
        end

    uart#(.CLK(20E6), .BAUD_RATE(`BAUD_RATE)) uart
    (
        .clock(clk),
        .reset(rst),
        .reset_wz_i(rst_wz),        
        .locked_o(locked),
        .rx_empty_o(data_ready_2),
        .rx_data_i(tx_data_o_uart1),        
        .tx_done_ticks(),
        .Alu_Result_i(),
        .tx_done_o(),        
        .tx_data_o(tx_data_o_uart2),        
        .data_o(data_out)
    );
    
    uart_AUX#(.CLK(20E6), .BAUD_RATE(`BAUD_RATE)) uart_aux
    (
        .clock(clk_2),
        .reset(rst),
        .rx_empty_o(data_ready),
        .rx_data_i(tx_data_o_uart2),        
        .tx_done_ticks(tx_start),
        .Alu_Result_i(data_in),
        .tx_done_o(tx_done),
        .tx_data_o(tx_data_o_uart1),        
        .data_o()
    );  

endmodule