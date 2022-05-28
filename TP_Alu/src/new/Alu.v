`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2021 18:24:57
// Design Name: 
// Module Name: Alu
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

module Alu
#(
    parameter N_BITS = 8,
    parameter N_OP   = 6
)
(
	input wire signed [N_BITS-1:0] A,
	input wire signed [N_BITS-1:0] B,	    // entradas a la ALU
	input wire [N_OP-1:0] Op,
	output reg signed [N_BITS-1:0] salida	
);
    always @(*) begin: alu
        case (Op)
            6'b100000 : salida = A + B; // ADD
            6'b100010 : salida = A - B; // SUB
            6'b100100 : salida = A & B; // AND
            6'b100101 : salida = A | B; // OR
            6'b100110 : salida = A ^ B; // XOR
            6'b000011 : salida = A >>> B; // SRA
            6'b000010 : salida = A >> B; // SRL
            6'b100111 : salida = ~(A | B); // NOR
            default : salida = 0;
	    endcase
    end
endmodule
