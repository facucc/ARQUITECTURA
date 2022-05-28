`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 8'b00001111
`define mode_continue 8'b11110000

`define ClockPeriodo 10

`define CANT_TICKS 16

`define CLK 50E6
`define CLK_AUX 20

`define BAUD_RATE 203400

`define N_BYTES 4
`define N_REGISTER 32
`define N_BYTES_MEM 128
`define N_BYTES_CYCLES 1
`define N_BYTES_PC 4

`define N_INSTRUCTIONS 23

`define CICLOS 5

`define Time_Delay (`ClockPeriodo*50)


module tb_TOP; 

    parameter N_BITS_DATA = 8;
    parameter NB_STATE   = 12;
    parameter NB_REG = 5;
    parameter NB_DATA = 32;	
    parameter N_BITS_OP   = 6;
    parameter NB_EX_CTRL  = 7;
    parameter NB_MEM_CTRL = 6;
    parameter NB_WB_CTRL  = 3;
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
    reg [N_BITS_DATA-1:0] address_mem;   
    wire [N_BITS_DATA-1:0] data_out;   
    reg [4:0] num_reg;    
    wire data_ready;
    wire locked;
    wire tx_done;
    /*  Debug */

/*
    wire bit_finish_o;
    wire [N_BITS_DATA-1:0] data_receive_o;
    wire en_read_load_inst_o;
    wire receive_full_byte_o;    
    wire data_ready_o;
    wire pc_write_o, IF_ID_write_o, halt_o;
    wire [`ADDRWIDTH-1:0] pc_o;
    wire [NB_DATA-1:0] instruction_o;
    wire [NB_STATE-1:0] state_o;
    wire [1:0] pc_src_o;
    wire [`ADDRWIDTH-1:0] pc_i_mem_o;
    wire [N_BITS_OP-1:0] op_code_o;
    wire enable_reg_IF_ID;

    wire [NB_EX_CTRL-1:0] EX_control_o;
    wire [NB_MEM_CTRL-1:0] M_control_o;
    wire [NB_WB_CTRL-1:0] WB_control_o;

    wire [NB_REG-1:0] EX_write_register_o;
    wire [NB_REG-1:0] EX_rt_o;
    wire ID_EX_mem_read_o;
    wire EX_reg_write_o, tx_start_o;
    wire [NB_REG-1:0] rs_o, rt_o;
*/
    integer i, j, k;  
    integer cant_bytes;    

	initial

        begin   
        #0          
            clk  = 0;
            clk_2 = 0;            
            rst_wz = 0;
            data_in = 0;  
            num_reg = 0;
            cant_bytes = 0;            
            rst = 1; 
                            
        #5             
            rst_wz = 1;
            
        #10            
            rst_wz = 0;
           
   
        $readmemh("../../../../../code_machine.txt", memory); //beha
        //$readmemh("../../../../../../code_machine.txt", memory); //sintesis
            for (i=0; i<`N_INSTRUCTIONS; i=i+1)
                begin
                    $display("valor :%h",memory[i]);
               end

        #20
        
        wait(locked == 1'b1);
        

        #(`CLK_AUX*2)
            rst = ~rst;

        #`CLK_AUX
          
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
                        #8               
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
                #8
                tx_start = 1'b1;
                #`CLK_AUX
                tx_start = 1'b0;
            wait(tx_done == 1'b1);
            $display("Terminando");


   end
   
   always
        begin
	       #(`ClockPeriodo/2) clk = ~clk; //100 MHZ
	    end
    always
        begin
            #(`ClockPeriodo) clk_2 = ~clk_2; //50 MHZ
        end

    always @(negedge clk_2)
    begin
        if (rst)
            data_receive = 32'b0;
        else
            begin
                if (end_send_data == 1'b1)
                    begin
                        cant_bytes = ((`N_BYTES*`N_REGISTER) + `N_BYTES_MEM + `N_BYTES);
                        //$display("Estoy aca %d", cant_bytes);
                    end
                if (data_ready)
                    begin                         
                        cant_bytes = cant_bytes + 1;
                        //$display("Bytes recibidos: %d, Dato recibido %d, %h", cant_bytes, data_out, data_out);

                        data_receive = {data_out, data_receive[31:8]};

                        if (cant_bytes == 1'b1)
                            begin
                                data_receive = 32'b0;
                                j = 0;
                                $display("DATO RECBIDO PC: %d %b %h ", data_out, data_out, data_out);                                
                            end
                        else if (cant_bytes == 2'b10)
                            begin
                                data_receive = 32'b0;
                                j = 0;
                                $display("DATO RECBIDO CICLOS: %d %b %h",data_out, data_out, data_out);
                            end 
                       
                        else if (cant_bytes <= ((`N_BYTES*`N_REGISTER) + 2))
                           begin
                           	j = j + 1;
                               if (j == `N_BYTES)
                               	begin
                               		$display("DATO RECBIDO R[%d]: %d %b %h ", num_reg ,  $signed(data_receive), data_receive, data_receive);
                               		num_reg =  num_reg + 1;
                                    j = 0; 
                               	end                                                                              
                           end
                        else
                            begin                      		
		                       	j = j + 1;
		                        if (j == `N_BYTES)
		                          begin         
                               	    $display("MEMORIA: %b", data_receive);                               		
                                    data_receive = 32'b0;
                                    j = 0;
                               		
                               	    end
                               	                      	
                      	    end         
                     end
                    
                else
                    data_receive = data_receive;
            end
            
            
    end

    TOP#(.CLK(`CLK), .BAUD_RATE(`BAUD_RATE)) test_TOP
    (
        .clock_i(clk),
        .reset_i(rst),
        .reset_wz_i(rst_wz),
        .rx_data_i(tx_data_out),
        .tx_data_o(data_sending),
        .locked_o(locked),       
        .ack_debug_o(ack_debug),
        .end_send_data_o(end_send_data)

        /* DEBUG */
        /*
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

        .enable_reg_IF_ID(enable_reg_IF_ID),
        .op_code_o(op_code_o),        
        .rs_o(rs_o),
        .rt_o(rt_o),
        .EX_rt_o(EX_rt_o),
        .EX_reg_write_o(EX_reg_write_o),
        .ID_EX_mem_read_o(ID_EX_mem_read_o),
        .EX_write_register_o(EX_write_register_o),
        .M_control_o(M_control_o),
        .EX_control_o(EX_control_o),
        .WB_control_o(WB_control_o),
        .tx_start_o(tx_start_o)*/

    );  
    
    uart_AUX#(.CLK(`CLK), .BAUD_RATE(`BAUD_RATE)) uart_aux
    (
        .clock(clk_2),
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
