`timescale 10ns / 1ps

//`define ClockPeriodo 10 //(1/(`timescale *ClockPeriodo)) => frecuencia 1/(10ns*10) = 10 Mhz 
`define ClockPeriodo 2 // 50 Mhz

`define CANT_TICKS 16

`define ADD_F(A, B) A + B
`define SUB_F(A,B) A - B
`define AND_F(A,B) A & B
`define OR_F(A,B)  A | B
`define XOR_F(A,B) A ^ B
`define SRA_F(A,B) A >>> B
`define SRL_F(A,B) A >> B
`define NOR_F(A,B) ~(A | B)


`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define XOR 6'b100110 
`define SRA 6'b000011
`define SRL 6'b000010
`define NOR 6'b100111

`define N_OP 8
`define T_PASSED 255

`define Time_Delay (`ClockPeriodo*163*`CANT_TICKS*3)

module tb_TOP; 

    parameter N_BITS_DATA = 8;	
    parameter N_BITS_OP   = 6;
    /* top */
	reg clk;
	reg rst;
    wire tx_data_out;
    wire result_alu;
    reg tx_start, rd_uart;

    reg [`N_OP-1:0] test; 
    
        /* uart aux */
    reg [N_BITS_DATA-1:0] data_in;
    reg [N_BITS_DATA-1:0] reg_A, reg_B;
    reg [N_BITS_DATA-1:0] data_result_alu;
    wire [N_BITS_DATA-1:0] data_out;
    reg [N_BITS_OP-1:0] LIST_OP[0:`N_OP-1];

    integer i;
    integer fd;

	initial

        begin

        LIST_OP[0] = `ADD;
        LIST_OP[1] = `SUB;
        LIST_OP[2] = `AND;
        LIST_OP[3] = `OR;
        LIST_OP[4] = `XOR;
        LIST_OP[5] = `SRA;
        LIST_OP[6] = `SRL;
        LIST_OP[7] = `NOR; 
        
        fd = $fopen("log_test.txt", "w");        
       
        
       
        #0          
           clk  = 0;
           rst  = 0;
           test = 0;             
           data_result_alu = 0;
           test = 0;
        #5  

            rst = 1;
            
        #10
            rst = 0;

        end
    always
        begin        
    
            for (i = 0; i < `N_OP; i = i+1)
            begin
            #10
                //data_in  = 8'b00000111;
                data_in  = $urandom()%128;               
                reg_A    = data_in;                             
                tx_start = 1'b1;
            #10
                tx_start = 1'b0;
            #`Time_Delay
                //data_in  = 8'b00000011;
                data_in  = $urandom()%128;
                reg_B    = data_in;     
                tx_start = 1'b1;
            #10
                tx_start = 1'b0;

            #`Time_Delay          
                data_in  = LIST_OP[i];    
                tx_start = 1'b1;
            #10
                tx_start = 1'b0;                       


            #`Time_Delay 
            case (LIST_OP[i])
                `ADD:
                    begin
                        $fdisplay(fd,"Operacion SUMA %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `ADD_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == `ADD_F(reg_A , reg_B));
                    end
                `SUB:
                    begin
                        $fdisplay(fd,"Operacion RESTA %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `SUB_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == `SUB_F(reg_A , reg_B));
                    end
                `AND:
                    begin
                        test[i] = (data_result_alu == $signed(`AND_F(reg_A , reg_B)));
                       $fdisplay(fd,"Operacion AND %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B,data_result_alu , `AND_F(reg_A , reg_B), data_result_alu);                        
                    end
                `OR :
                    begin
                        $fdisplay(fd,"Operacion OR %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `OR_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == $signed(`OR_F(reg_A , reg_B)));
                    end
                `XOR:
                    begin
                        $fdisplay(fd,"Operacion XOR %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `XOR_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == $signed(`XOR_F(reg_A , reg_B)));

                    end
                `SRA:
                    begin
                       $fdisplay(fd,"Operacion SRA %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `SRA_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == `SRA_F(reg_A , reg_B));
                    end
                `SRL:
                    begin
                        $fdisplay(fd,"Operacion SRL %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `SRL_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == `SRL_F(reg_A , reg_B));
                    end
                `NOR: 
                    begin
                        $fdisplay(fd,"Operacion NOR %d Dato A: %d %b - Dato B: %d %b, Resultado: %d %d %b", i, reg_A, reg_A, reg_B, reg_B, data_result_alu , `NOR_F(reg_A , reg_B), data_result_alu);
                        test[i] = (data_result_alu == `NOR_F(reg_A , reg_B));
                    end
            endcase


            end

        wait (i == `N_OP)
           
        assert(test, `T_PASSED);

        $fclose(fd);
        
        $finish;

        end            
           
	   always begin
	       #(`ClockPeriodo/2) clk = ~clk;
	   end
		
    TOP test_TOP
    (
        .clock(clk),
        .reset(rst),
        .rx_data_i(tx_data_out),
        .tx_data_o(result_alu)
    );  
    
    uart_AUX uart_aux
    (
        .clock(clk),
        .reset(rst),
        .rx_data_i(result_alu),        
        .tx_done_ticks(tx_start),
        .Alu_Result_i(data_in),
        .tx_data_o(tx_data_out),        
        .data_o(data_out)
    );

    always @(posedge clk)
      begin  
        data_result_alu <= data_out;
      end
       
    task assert;
    input [`N_OP-1:0] A, B;
    begin    
       if (A == B)
            $display ("TEST PASSED: %b\n", A);
       else
            $display ("TEST FAILED: %b\n", A);
    end
    endtask

endmodule