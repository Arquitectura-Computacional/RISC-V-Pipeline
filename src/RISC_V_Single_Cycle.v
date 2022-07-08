/******************************************************************
* Description
*	This is the top-level of a RISC-V Microprocessor that can execute the next set of instructions:
*		add
*		addi
* This processor is written Verilog-HDL. It is synthesizabled into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be executed. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	16/08/2021
******************************************************************/

module RISC_V_Single_Cycle
#(
	parameter PROGRAM_MEMORY_DEPTH = 64,
	parameter DATA_MEMORY_DEPTH = 128
)

(
	// Inputs
	input clk,
	input reset

);
//******************************************************************/
//******************************************************************/

//******************************************************************/
//******************************************************************/
/* Signals to connect modules*/

/**Control**/
wire alu_src_w;
wire reg_write_w;
wire mem_to_reg_w;
wire mem_write_w;
wire mem_read_w;
wire [2:0] alu_op_w;

/** Program Counter**/
wire [31:0] pc_plus_4_w;
wire [31:0] pc_w;


/**Register File**/
wire [31:0] read_data_1_w;
wire [31:0] read_data_2_w;

/**Inmmediate Unit**/
wire [31:0] immediate_data_w;

/**ALU**/
wire [31:0] alu_result_w;

/**Multiplexer MUX_DATA_OR_IMM_FOR_ALU**/
wire [31:0] read_data_2_or_imm_w;

/**ALU Control**/
wire [3:0] alu_operation_w;

/**Instruction Bus**/	
wire [31:0] instruction_bus_w;

/** Pipeline IF -> ID**/
wire [31:0] pipe_instruction_w_o;
wire [31:0] pipe_pc_plus_4_w;

/** Pipeline ID -> EX**/
wire [31:0] pipe_immediate_data_w_o;
wire [31:0] pipe_read_data_1_w_o;
wire [31:0] pipe_read_data_2_w_o;
wire [3:0] pipe_alu_operation_w_o;
wire [31:0] pipe_mux_output;
wire pipe_reg_write_w_o;
wire [4:0] pipe_write_register_w_o;

/** Pipeline EX -> MEM**/
wire [31:0] pipe_alu_result_w;
wire pipe_reg_write_o;
wire [4:0] pipe_write_register;

/** Pipeline MEM -> WB**/

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
CONTROL_UNIT
(
	/****/
	.OP_i(pipe_instruction_w_o[6:0]),
	/** outputus**/
	.ALU_Op_o(alu_op_w),
	.ALU_Src_o(alu_src_w),
	.Reg_Write_o(reg_write_w),
	.Mem_to_Reg_o(mem_to_reg_w),
	.Mem_Read_o(mem_read_w),
	.Mem_Write_o(mem_write_w)
);

PC_Register
PROGRAM_COUNTER
(
	.clk(clk),
	.reset(reset),
	.Next_PC(pipe_pc_plus_4_w),
	.PC_Value(pc_w)
);

Program_Memory
#(
	.MEMORY_DEPTH(PROGRAM_MEMORY_DEPTH)
)
PROGRAM_MEMORY
(
	.Address_i(pc_w),
	.Instruction_o(instruction_bus_w)
);


Adder_32_Bits
PC_PLUS_4
(
	.Data0(pc_w),
	.Data1(4),
	
	.Result(pc_plus_4_w)
);


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/



Register_File
REGISTER_FILE_UNIT
(
	.clk(clk),
	.reset(reset),
	.Reg_Write_i(pipe_reg_write_o),
	.Write_Register_i(pipe_write_register),
	.Read_Register_1_i(pipe_instruction_w_o[19:15]),
	.Read_Register_2_i(pipe_instruction_w_o[24:20]),
	.Write_Data_i(pipe_alu_result_w),
	.Read_Data_1_o(read_data_1_w),
	.Read_Data_2_o(read_data_2_w)

);



Immediate_Unit
IMM_UNIT
(  .op_i(pipe_instruction_w_o[6:0]),
   .Instruction_bus_i(pipe_instruction_w_o),
   .Immediate_o(immediate_data_w)
);



Multiplexer_2_to_1
#(
	.NBits(32)
)
MUX_DATA_OR_IMM_FOR_ALU
(
	.Selector_i(alu_src_w),
	.Mux_Data_0_i(pipe_read_data_2_w_o),
	.Mux_Data_1_i(pipe_immediate_data_w_o),
	
	.Mux_Output_o(pipe_mux_output)

);


ALU_Control
ALU_CONTROL_UNIT
(
	.funct7_i(pipe_instruction_w_o[30]),
	.ALU_Op_i(alu_op_w),
	.funct3_i(pipe_instruction_w_o[14:12]),
	.ALU_Operation_o(alu_operation_w)

);



ALU
ALU_UNIT
(
	.ALU_Operation_i(pipe_alu_operation_w_o),
	.A_i(pipe_read_data_1_w_o),
	.B_i(pipe_mux_output),
	.ALU_Result_o(alu_result_w)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

PIPE_IF_ID
IF_ID
(
	.clk(clk),
	.reset(reset),
	.instruction_w(instruction_bus_w),
	.pc_plus_4_w(pc_plus_4_w),
	
	.instruction_w_o(pipe_instruction_w_o),
	.pc_plus_4_w_o(pipe_pc_plus_4_w)
);

PIPE_ID_EX
ID_EX
(
	.clk(clk),
	.reset(reset),
	.immediate_data_w(immediate_data_w),
	.read_data_1_w(read_data_1_w),
	.read_data_2_w(read_data_2_w),
	.alu_operation_w(alu_operation_w),
	.write_w(reg_write_w),
	.write_register_w(pipe_instruction_w_o[11:7]),

	.immediate_data_w_o(pipe_immediate_data_w_o),
	.read_data_1_w_o(pipe_read_data_1_w_o),
	.read_data_2_w_o(pipe_read_data_2_w_o),
	.alu_operation_w_o(pipe_alu_operation_w_o),
	.write_w_o(pipe_reg_write_w_o),
	.write_register_w_o(pipe_write_register_w_o)
);

PIPE_EX_MEM
EX_MEM
(
	.clk(clk),
	.reset(reset),
	.alu_result_w(alu_result_w),
	.write_w(pipe_reg_write_w_o),
	.write_register_w(pipe_write_register_w_o),

	.alu_result_w_o(pipe_alu_result_w),
	.write_o(pipe_reg_write_o),
	.write_register_w_o(pipe_write_register)
);

PIPE_MEM_WB
MEM_WB
(
	.clk(clk),
	.reset(reset)


);

endmodule
