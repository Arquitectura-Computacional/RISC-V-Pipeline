module PIPE_MEM_WB
(
	input clk,
	input reset
    
);


always @(negedge reset or posedge clk)
	begin
		if (reset == 0)
			begin
				
			end
		else
			begin
				
			end
	end

endmodule