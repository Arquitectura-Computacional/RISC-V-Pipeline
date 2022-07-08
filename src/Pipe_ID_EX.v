module PIPE_ID_EX
(
	input clk,
	input reset,
	input [31:0] immediate_data_w,
	input [31:0] read_data_1_w,
	input [31:0] read_data_2_w,
	input [3:0] alu_operation_w,
	input write_w,
	input [4:0] write_register_w,

	output reg [31:0] immediate_data_w_o,
	output reg [31:0] read_data_1_w_o,
	output reg [31:0] read_data_2_w_o,
	output reg [3:0] alu_operation_w_o,
	output reg write_w_o,
	output reg [4:0] write_register_w_o
);

always @(negedge reset or posedge clk)
	begin
		if (reset == 0)
			begin
				immediate_data_w_o <= 0;
				read_data_1_w_o <= 0;
				read_data_2_w_o <= 0;
				alu_operation_w_o <= 0;
				write_w_o <= 0;
				write_register_w_o <= 0;
			end
		else
			begin
				immediate_data_w_o <= immediate_data_w;
				read_data_1_w_o <= read_data_1_w;
				read_data_2_w_o <= read_data_2_w;
				alu_operation_w_o <= alu_operation_w;
				write_w_o <= write_w;
				write_register_w_o <= write_register_w;
			end
	end

endmodule