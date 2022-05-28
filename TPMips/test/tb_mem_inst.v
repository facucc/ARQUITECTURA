`timescale 1ns / 1ps

`define ClockPeriodo 10
`define N_INSTRUCTIONS 3


module tb_mem_inst; 

    parameter NB_DATA = 32;
    parameter ADDRWIDTH = $clog2(128);	    
    /* top */
	reg clk;
	reg rst, reset_wz;  
    reg en_read;
    reg en_write;   
    reg [NB_DATA-1:0] memory [0:`N_INSTRUCTIONS]; 

    reg [NB_DATA-1:0] data_in;
    reg [ADDRWIDTH-1:0] wr_addr;      

    wire locked;
    wire [NB_DATA-1:0] instruction_o;
    integer i;  

	initial

        begin   
        
        #0          
           clk  = 0;
           rst  = 0;          
           data_in = 0;
           wr_addr = 0;
           en_read = 0;
           en_write = 0;
           reset_wz = 0;          
           i= 0;          
        #5  
            reset_wz = 1;
            
        #10
            reset_wz = 0;
          
            $readmemh("code_machine.txt", memory);
            for (i=0; i<`N_INSTRUCTIONS; i=i+1)
                begin
                    $display("valor :%h",memory[i]);
                end                 
        

        wait(locked == 1'b1);
        
        #5  
            rst = 1;
            
        #10
            rst = 0;
        
        for (i = 0; i < `N_INSTRUCTIONS; i = i+1)
            begin
                #(`ClockPeriodo*5)
                    data_in = memory[i];
                    wr_addr = i;
                    en_read = 1'b0;
                    en_write = 1'b1;
                    $display("sending data [%d] [%b][%h], addr: %h", i, data_in, data_in, wr_addr);
                 
            end 
        for (i = 0; i < `N_INSTRUCTIONS; i = i+1)
            begin
                #(`ClockPeriodo*5)                    
                    wr_addr = i;
                    en_read = 1'b1;
                    en_write = 1'b0;
                    $display("receive data [%d] [%b][%h], addr: %h", i, instruction_o, instruction_o, wr_addr);
                 
            end 
            
     end
              
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk;
	   end
		


    TOP_mem_inst TOP_mem_inst
    (
        .clock_i(clk),
        .reset_i(rst),       
        .reset_wz_i(reset_wz),
        .inst_load_i (data_in),
        .wr_addr_i(wr_addr),       
        
        .en_read_i(en_read),
        .en_write_i(en_write),      

        .instruction_o(instruction_o),        
        .locked_o(locked)
    );    
      

endmodule