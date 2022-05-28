`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2021 16:40:13
// Design Name: 
// Module Name: testb_TOP_Alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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

`define ClockPeriodo 2 
       
module testb_TOP_Alu;

    parameter BUS_LENGTH = 8;
     
    // entradas
	reg btn_A;
	reg btn_B;
	reg btn_Op;
	reg clk;
	reg signed [BUS_LENGTH-1:0] datos;
	
	// salida
	wire signed [BUS_LENGTH-1:0] Resultado;
	
integer i = 0;
integer fd;
 
initial
    begin
		datos = 0;
		btn_A=0;
		btn_B = 0;
		btn_Op= 0;
		clk = 0;
		fd = $fopen("log_test.txt", "w"); 
		        
	 forever
        begin
            #(`ClockPeriodo/2) clk = ~clk;
        end
    end

always
    begin
        for(i=0;i<3;i=i+1)
            begin
            #10;
            datos=30;
            $fdisplay(fd,"--------------------------------START------------------------------");
            $fdisplay(fd,"Dato del switch: %d...%b\n",datos, datos);
            //Cargo valores random a A y B
            #10
            datos=$random%128;
            #20;
            btn_A=1;
            #5
            btn_A=0;
            #5
            datos=$random%128;
            
            #20;
            btn_B=1;
            #5
            btn_B=0;
                        
            //Realizo todas las Operaciones
            #10  datos = `ADD;
            #10  btn_Op= 1;
            #10  btn_Op = 0;        
            
            //256 & bit_Test 
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n ", "ADD", `ADD);                  
            assert(`ADD_F( $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B)),Resultado);    
                                   
            #10  datos = `SUB;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
            
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "SUB", `SUB);             
            assert(`SUB_F(test_TOP.Reg_A, test_TOP.Reg_B),Resultado);
            
            #10  datos = `AND;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
            
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "AND", `AND); 
            assert(`AND_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);
            
            #10  datos = `OR;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
           
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "OR", `OR); 
            assert(`OR_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);
            
            #10  datos = `XOR;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
            
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "XOR", `XOR); 
            assert(`XOR_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);       
                        
            #10  datos = `SRA;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
            
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "SRA", `SRA); 
            assert(`SRA_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);
            
            #10  datos = `SRL;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
            
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "SRL", `SRL); 
            assert(`SRL_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);          

            #10  datos = `NOR;
            #10  btn_Op = 1;
            #10  btn_Op = 0;
           
            $fdisplay(fd ,"Dato_A: %d, Dato_B: %d\nDato_A: %b, Dato_B: %b\n", $signed(test_TOP.Reg_A), $signed(test_TOP.Reg_B), test_TOP.Reg_A,test_TOP.Reg_B);
            $fdisplay(fd,"Operacion: %s : %b\n", "NOR", `NOR); 
            assert(`NOR_F($signed(test_TOP.Reg_A),$signed(test_TOP.Reg_B)) ,Resultado);
            
            
            $fdisplay(fd,"--------------------------------END------------------------------");
            end
            
	end
   
// Instanciamos el modulo a testear
	TOP_Alu test_TOP (
	   .entrada(datos),
	   .boton1(btn_A),
	   .boton2(btn_B),
	   .boton3(btn_Op),
	   .clock(clk),
	   .led_out(Resultado)
	);	
	task assert;
    input  signed [BUS_LENGTH:0] A, B;
    begin    
       if (A == B)
            $fdisplay (fd, "TEST PASSED: value1 %d %b es igual a value2 %d %b \n", A, B, A, B);
       else
            $fdisplay (fd,"TEST FAILED: value1 %d %b es distinto a value2 %d %b \n", A, B, A, B);
    end
    endtask
    
endmodule



