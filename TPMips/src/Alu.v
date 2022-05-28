`timescale 1ns / 1ps

`include "parameters.vh"


module Alu
#(
    parameter N_BITS = 32,
    parameter N_OP   = 4
)
(
	input wire signed [N_BITS-1:0] A,
	input wire signed [N_BITS-1:0] B,	    // entradas a la ALU
	input wire [N_OP-1:0] Op,

	output reg signed [N_BITS-1:0] result_o	
);
    always @(*) begin: alu

        case (Op)
            `SLL : result_o = B << A;
            `SRL : result_o = B >> A;
            `SRA : result_o = B >>> A;
            `ADD : result_o = A + B; 
            `SUB : result_o = A - B;
            `AND : result_o = A & B; 
            `OR  : result_o = A | B; 
            `XOR : result_o = A ^ B;       
            `NOR : result_o = ~(A | B);
            `SLT:  result_o = A < B;
            `LUI:  result_o = B << 16;

            default : result_o = 32'b0;
	    endcase
    end
    

endmodule
