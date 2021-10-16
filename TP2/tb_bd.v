`timescale 10ns / 1ps
`define ClockPeriodo 10

module tb_bd;   
	// entradas
	reg clk;
	reg rst;
	wire cont_ticks;

	
	initial

        begin
        #0
           clk = 0;
           rst = 0;        
        #5
            rst = 1;
            
        #10
            rst = 0;
        
	   end
	   always begin
	       #(`ClockPeriodo/2) clk = ~clk;
	   end
	// Instanciamos el test del baud rate generator
    baud_rate_gen test_bd (
        .clock(clk), 
        .reset(rst), 
        .ticks(cont_ticks)
    );
      
endmodule