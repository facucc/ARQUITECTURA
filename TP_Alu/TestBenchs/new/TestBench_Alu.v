`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Carrizo Facundo, Perez Esteban
// 
// Create Date: 19.09.2021 18:58:14
// Design Name: 
// Module Name: TestBench
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


module TestBench_Alu;

    localparam N_BITS = 8;
    localparam N_OP = 6;
    
	// entradas siempre van a ser registros
	reg [N_OP-1:0] Op;
	reg signed [N_BITS-1:0] A;
	reg signed [N_BITS-1:0] B;
	
	// salidas siempre van a ser wire
	wire signed [N_BITS-1:0] salida;

	// Instanciamos el test de la alu
	Alu testAlu (
		.Op(Op), 
		.A(A), 
		.B(B), 
		.salida(salida)
	);

	initial begin		
		// Initializamos las entradas
		#0
		Op = 0;
		A = 0;
		B = 0;
		#20		
		A  = $random()%128;
		B  = $random()%128;
		Op = 6'b100000; //ADD
		
		#100 Op=6'b100010;//SUB
		#100 Op=6'b100100;//AND
		#100 Op=6'b100101;//OR
		#100 Op=6'b100110;//XOR
		#100 Op=6'b000011;//SRA
		#100 Op=6'b000010;//SRL
		#100 Op=6'b100111;//NOR
		#100 Op = 6'b100000;
				
	end
	initial $monitor($time,A,B,Op,salida); //monitoreamos los datos de entrada, las operaciones y la salida
      
endmodule
