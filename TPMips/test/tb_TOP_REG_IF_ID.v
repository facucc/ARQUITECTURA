`timescale 1ns / 1ps
`include "parameters.vh"

`define NOP_INST 32'hF8000000

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000
`define ClockPeriodo 10
`define CLK_AUX 50
`define BAUD_RATE 203400
`define N_INSTRUCTIONS 2
`define N_BYTES 4
`define CICLOS 5
`define Time_Delay (`ClockPeriodo*3)

module tb_TOP_REG_IF_ID; 

    parameter N_BITS_DATA = 8;
    parameter NB_STATE   = 12;
    parameter NB_DATA = 32;	
    parameter N_BITS_OP   = 6;
    /* top */
	reg clk, clk_2;
	reg rst, rst_wz;
    wire locked;   

    reg enable_pipe;
    reg jump_or_branch;
    reg [`ADDRWIDTH-1:0] pc;
    reg [NB_DATA-1:0] instruction;
    reg [NB_DATA-1:0] instruction_nop;
    wire [`ADDRWIDTH-1:0] pc_o;
    wire [NB_DATA-1:0] instruction_o;
  
    
	initial

        begin   
            #0          
                clk  = 0;
                clk_2 = 0;
                rst  = 0;
                rst_wz = 0;
                pc = 0;
                instruction = 0;
                instruction_nop = 0;
                enable_pipe = 1'b0;
                jump_or_branch = 1'b0;                                   
            #5             
                rst_wz = 1;
                
            #10            
                rst_wz = 0;       
           
            #20
            
                wait(locked == 1'b1);
            
            #8
                rst = 1;

            #`CLK_AUX
                rst = 0;
            #5

            enable_pipe = 1'b1;
            jump_or_branch = 1'b0;
            #`CLK_AUX       
            pc = 1;
            instruction = 32'h8c080000;
            instruction_nop = `NOP_INST;

            #`CLK_AUX       
            pc = 2;
            instruction = 32'h8c090004;
            instruction_nop = `NOP_INST;
            #`CLK_AUX       
            pc = 3;
            instruction = 32'h2911000f;
            instruction_nop = `NOP_INST;
            #`CLK_AUX       
            pc = 4;
            instruction = 32'hfc000000;
            instruction_nop = `NOP_INST;


        end
   
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk; //100 MHZ
	    end    

    TOP_REG_IF_ID test_TOP_REG_IF_ID
    (
        .clock_i(clk),        
        .reset_wz_i(rst_wz), 
        .enable_pipe_i(enable_pipe),
        .jump_or_branch_i(jump_or_branch),
        .instruction_i(instruction),
        .instruction_nop (instruction_nop),
        .pc_i(pc),       
        .locked_o(locked),
        .pc_o(pc_o),
        .instruction_o(instruction_o)        
                    
    );
    
endmodule