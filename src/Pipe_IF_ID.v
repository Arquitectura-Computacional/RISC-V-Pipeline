module PIPE_IF_ID
(
	input clk,
	input reset,
	input [31:0] instruction_w,
	input [31:0] pc_plus_4_w,
	
	output reg [31:0] instruction_w_o,
	output reg [31:0] pc_plus_4_w_o
);

always @(negedge reset or posedge clk)
	begin
		if (reset == 0)
			begin
				instruction_w_o <= 0;
				pc_plus_4_w_o <= 0;
			end
		else
			begin
				instruction_w_o <= instruction_w;
				pc_plus_4_w_o <= pc_plus_4_w;
			end
	end

endmodule