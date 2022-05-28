`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2021 16:12:25
// Design Name: 
// Module Name: TOP_Alu
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
/////////////////////////////////////////////////////////////////////////////////


module TOP_Alu
  #(
      parameter N_BITS = 8,
      parameter N_OP   = 6
  ) 
 (
  input wire signed [N_BITS-1:0] entrada,
  input wire boton1,
  input wire boton2,
  input wire boton3,
  input wire clock,
  output reg signed [N_BITS-1:0] led_out 
  );
// registros internos
reg  [N_OP-1:0] Reg_Op;
reg  signed [N_BITS-1:0] Reg_A;
reg  signed [N_BITS-1:0] Reg_B;
wire signed [N_BITS-1:0] Alu_Result;

always @(posedge clock) //read entradas y op sincronizado al clock
	begin
		if(boton1) begin
			Reg_A <= entrada;
		end
		if(boton2) begin
			Reg_B <= entrada;
		end
		if(boton3) begin
			Reg_Op <= entrada[N_OP-1:0];
		end
	end
always @(posedge clock) 
	begin
	   led_out <= Alu_Result;
	end
//instanceamos la Alu
Alu alu(.Op(Reg_Op),.A(Reg_A), .B(Reg_B), .salida(Alu_Result));

endmodule