`define R_TYPE_OPCODE   'b000000   //R-type instructions operations maps to RTYPE_ALUCODE
`define LB_OPCODE       'b100000   //I-type instructions opcodes
`define LH_OPCODE       'b100001   //Loads/stores/Addi maps to LOAD_STORE_ADDI_ALUCODE
`define LW_OPCODE       6'b100011
`define LWU_OPCODE      'b100111
`define LBU_OPCODE      'b100100
`define LHU_OPCODE      'b100101
`define SB_OPCODE       'b101000
`define SH_OPCODE       'b101001
`define SW_OPCODE       'b101011
`define ADDI_OPCODE     'b001000
`define ANDI_OPCODE     'b001100    //maps to ANDI_ALUCODE in Control module
`define ORI_OPCODE      'b001101    //maps to ORI_ALUCODE
`define XORI_OPCODE     'b001110    //maps to XORI_ALUCODE
`define LUI_OPCODE      'b001111    //maps to LUI_ALUCODE
`define SLTI_OPCODE     'b001010    //maps to BRANCH_ALUCODE
`define BEQ_OPCODE      'b000100        
`define BNE_OPCODE      'b000101
`define J_OPCODE        'b000010   //J-type instructions opcodes, do not map to any alu operation since alu module is not used
`define JAL_OPCODE      'b000011   
`define HALT_OPCODE     6'b111111
module tb_unit_control;

    
   parameter N_BITS_OP   = 6;
   parameter NB_EX_CTRL  = 7;
   parameter NB_MEM_CTRL = 6;
   parameter NB_WB_CTRL  = 3;
   
	reg [N_BITS_OP-1:0] op_code, function_i;
      
   
   reg clk;
    wire [1:0] pc_src_o;
    wire [N_BITS_OP-1:0] op_code_o;
    wire beq_o, bne_o, jump_o, halt_detected_o;
    wire [NB_EX_CTRL-1:0] EX_control_o;
    wire [NB_MEM_CTRL-1:0] M_control_o; 
    wire [NB_WB_CTRL-1:0] WB_control_o;


	initial

        begin   
        
        #0          
           clk  = 0;
           op_code = 0;
           function_i = 0;
           /*           
        #10
        	op_code = `R_TYPE_OPCODE;
        #10
        	op_code = `LB_OPCODE;
        #10
        	op_code = `LH_OPCODE;*/
        #10
        	op_code = `LW_OPCODE;

         #10
         op_code = `HALT_OPCODE;
 
         /*
        #10
        	op_code = `LWU_OPCODE;
        #10
        	op_code = `LHU_OPCODE;

        #10
        	op_code = `SB_OPCODE;
        #10
        	op_code = `SH_OPCODE;
        #10
        	op_code = `SW_OPCODE;
        #10
        	op_code = `ADDI_OPCODE;
        #10
        	op_code = `ANDI_OPCODE;
        #10
        	op_code = `ORI_OPCODE;

        #10
        	op_code = `XORI_OPCODE;
        #10
        	op_code = `LUI_OPCODE;
        #10
        	op_code = `SLTI_OPCODE;
        #10
        	op_code = `BEQ_OPCODE;
        #10
        	op_code = `BNE_OPCODE;
        #10
        	op_code = `J_OPCODE;
        #10
        	op_code = `JAL_OPCODE;

      */
    end
        unit_control test_unit_control
        (
        	.op_code_i (op_code),
         .pc_src_o       (pc_src_o),
         .op_code_o      (op_code_o),
         .M_control_o    (M_control_o),
         .EX_control_o   (EX_control_o),
         .WB_control_o   (WB_control_o),
         .function_i     (function_i),
         .halt_detected_o(halt_detected_o),

         .beq_o              (beq_o),
        .bne_o              (bne_o),
        .jump_o             (jump_o)
        );



	always
        begin
	       #(10) clk = ~clk;
	   end
		

endmodule 