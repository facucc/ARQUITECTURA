`timescale 1ns / 1ps

`define ClockPeriodo 10
`define N_INSTRUCTIONS 3
`define N_ELEMENTS 128

module tb_IF; 

    parameter NB_DATA = 32;
    parameter ADDRWIDTH = $clog2(`N_ELEMENTS);	    
    /* top */
	reg clk;
	reg rst, reset_wz;   
    reg debug_unit;
    reg en_read;
    reg en_write;
    reg enable_pipe;
    reg [1:0] pc_src;
    reg [NB_DATA-1:0] memory [0:`N_INSTRUCTIONS]; 

    reg [NB_DATA-1:0] data_in;
    reg [ADDRWIDTH-1:0] wr_addr;     
    wire [ADDRWIDTH-1:0] pc_o;
    wire halt, locked;
    wire [NB_DATA-1:0] instruction_o;
    integer i;  

	initial

        begin   
        
        #0          
           clk  = 0;
           rst  = 0;
           debug_unit = 1'b1;
           data_in = 0;
           wr_addr = 0;
           en_read = 0;
           en_write = 0;
           enable_pipe = 0;
           pc_src = 0;
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
                #(`ClockPeriodo*3)
                    data_in = memory[i];
                    debug_unit = 1'b1; 
                    wr_addr = i;
                    en_read = 1'b0;
                    en_write = 1'b1;
                    $display("sending data [%d] [%b][%h], addr: %h", i, data_in, data_in, wr_addr);

                 
            end
        for (i = 0; i < `N_INSTRUCTIONS; i = i+1)
            begin
                #(`ClockPeriodo*3)                    
                    wr_addr = i;
                    enable_pipe = 1'b1;
                    debug_unit = 1'b0; 
                    en_read = 1'b1;
                    en_write = 1'b0;
                    $display("receive data [%d] [%b][%h], addr: %h", i, instruction_o, instruction_o, wr_addr);                 
            end  
                

        wait(halt == 1'b1)
            #`ClockPeriodo
            $finish;
       end
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk;
	   end		


    TOP_IF tb_IF
    (
        .clock_i(clk),
        .reset_wz_i(reset_wz),
        .reset_i(rst),
        //.enable_mem_i(1'b1),
        .enable_i(enable_pipe),
        .debug_unit_i(debug_unit),
        
        .wr_addr_i(wr_addr),
        .instruction_i(data_in),

        .pc_src_i(pc_src),

        .addr_jump_i(7'b0),
        .addr_register_i(7'b0),
        .addr_branch_i(7'b0),

        .en_read_i(en_read),
        .en_write_i(en_write),        

        .instruction_o(instruction_o),
        .pc_o(pc_o),
        .halt_o(halt),
        .locked_o(locked)
    );    
      

endmodule