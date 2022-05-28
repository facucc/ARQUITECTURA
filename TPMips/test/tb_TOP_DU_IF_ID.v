`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000
`define ClockPeriodo 10
`define CLK_AUX 50
`define BAUD_RATE 203400
`define N_INSTRUCTIONS 2
`define N_BYTES 4
`define CICLOS 5
`define Time_Delay (`ClockPeriodo*150)

module tb_TOP_DU_IF_ID; 

    parameter N_BITS_DATA = 8;
    parameter NB_STATE   = 12;
    parameter NB_DATA = 32;	
    parameter N_BITS_OP   = 6;
    parameter NB_EX_CTRL  = 7;
    parameter NB_MEM_CTRL = 6;
    parameter NB_WB_CTRL  = 3;
    parameter NB_REG  = 5;
    /* top */
	reg clk, clk_2;
	reg rst, rst_wz;
    wire tx_data_out;
    wire data_sending;
    reg tx_start;
    wire ack_debug;
    wire end_send_data;
    reg [NB_DATA-1:0] memory [0:`N_INSTRUCTIONS*4]; 
        /* uart aux */
    reg [N_BITS_DATA-1:0] data_in;
    reg [NB_DATA-1:0] data_receive;   
    wire [N_BITS_DATA-1:0] data_out;   
    reg [4:0] num_reg;    
    wire data_ready;
    wire locked;
    wire tx_done;
    /*  Debug */
    
    wire bit_finish_o;
    wire [N_BITS_DATA-1:0] data_receive_o;
    wire en_read_load_inst_o;
    wire receive_full_byte_o;
    wire branch_or_jump_o;
    wire data_ready_o;
    wire pc_write_o, IF_ID_write_o, halt_o;
    wire [`ADDRWIDTH-1:0] pc_o;
    wire [NB_DATA-1:0] instruction_o, inst_o_mem, instruction_i_o;
    wire [NB_STATE-1:0] state_o;
    wire [1:0] pc_src_o;
    wire [`ADDRWIDTH-1:0] pc_i_mem_o;
    wire enable_pipe_o, en_next_state_o;

    wire [5:0] function_o, op_code_o;
    wire [NB_REG-1:0] rd_o, rs_o,rt_o;
    wire [NB_REG-1:0] shamt_o;
    wire [NB_DATA-1:0] inm_ext_o, data_ra_o, data_rb_o;


    wire beq_o, bne_o, jump_o;
    wire [NB_EX_CTRL-1:0] EX_control_o;
    wire [NB_MEM_CTRL-1:0] M_control_o; 
    wire [NB_WB_CTRL-1:0] WB_control_o;
    integer i, j, k;   
    integer cant_bytes;
    
	initial

        begin   
        #0          
            clk  = 0;
            clk_2 = 0;
            rst  = 0;
            rst_wz = 0;
            data_in = 0;  
            num_reg = 0;
            cant_bytes = 0;                    
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
        #50
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
        /* MODO Paso a paso */
        /*
         for (k = 0; k < `CICLOS; k = k+1)
                    begin                        
                        wait(ack_debug == 1'b1);  
                        #`Time_Delay                      
                        data_in = `mode_step_to_step;
                        tx_start = 1'b1;
                        #10
                        tx_start = 1'b0;
                        $display("Saliendo del wait %d\n",k);
                   end
        */
        /*  MODO CONTINUO */
            wait(ack_debug == 1'b1); 
            $display("Despertando");
            wait(tx_done == 1'b1);
            #`Time_Delay                      
                data_in = `mode_continue;
                #25
                tx_start = 1'b1;
                #`CLK_AUX
                tx_start = 1'b0;
           
            $display("Terminando");


   end
   
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk; //100 MHZ
	    end
    always
        begin
            #(`ClockPeriodo*2.5) clk_2 = ~clk_2; //20 MHZ
        end

    TOP_DU_IF_ID#(.CLK(20E6), .BAUD_RATE(`BAUD_RATE)) test_TOP_DU_IF_ID
    (
        .clock_i(clk),
        .reset_i(rst),
        .reset_wz_i(rst_wz),
        .rx_data_i(tx_data_out),
        .tx_data_o(data_sending),
        .locked_o(locked),       
        .ack_debug_o(ack_debug),
        .end_send_data_o(end_send_data),


        .pc_src_o(pc_src_o),
        .pc_write_o(pc_write_o),
        .IF_ID_write_o(IF_ID_write_o),
        .halt_o(halt_o),
        .pc_i_mem_o(pc_i_mem_o),
        .pc_o(pc_o),
        .instruction_o(instruction_o), 
        .state_o(state_o),       
        .data_ready_o(data_ready_o),
        .bit_finish_o(bit_finish_o),
        .data_receive_o(data_receive_o),
        .en_read_load_inst_o(en_read_load_inst_o),
        .receive_full_byte_o(receive_full_byte_o),
        .enable_pipe_o(enable_pipe_o),

        .op_code_o(op_code_o),
        .data_ra_o(data_ra_o),
        .data_rb_o(data_rb_o),
        .M_control_o(M_control_o),
        .EX_control_o(EX_control_o),
        .WB_control_o(WB_control_o),
        .rd_o(rd_o),
        .rs_o(rs_o),
        .rt_o(rt_o),
        .shamt_o(shamt_o),
        .inm_ext_o(inm_ext_o),
        .function_o(function_o),
        .en_next_state_o    (en_next_state_o),
        .branch_or_jump_o   (branch_or_jump_o),
        .inst_o_mem         (inst_o_mem),
        .instruction_i_o    (instruction_i_o),
        .beq_o              (beq_o),
        .bne_o              (bne_o),
        .jump_o             (jump_o)

    ); 


    uart_AUX#(.CLK(20E6), .BAUD_RATE(`BAUD_RATE)) uart_aux
    (
        .clock((locked == 1'b1) ? clk_2 : 1'b0),
        .reset(rst),
        .rx_empty_o(data_ready),
        .rx_data_i(data_sending),        
        .tx_done_ticks(tx_start),
        .Alu_Result_i(data_in),
        .tx_done_o(tx_done),
        .tx_data_o(tx_data_out),        
        .data_o(data_out)
    );     
    
endmodule