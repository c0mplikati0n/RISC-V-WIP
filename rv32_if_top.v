
module rv32_if_top(

	// system clock and synchronous reset
	input clk,
	input reset,
	
	// memory interface
	output [31:2] memif_addr,
	input [31:0] memif_data,

	// to id
	output reg [31:0] pc_out,
	output [31:0] iw_out, // note this was registered in the memory already
	
	// from id
	input jump_enable_in,
	input [31:0] jump_addr_in,
	
	input pc_stop
	
	);
	
	reg [31:0] PC;
	parameter PC_RESET = 32'h00000000;

	// set PC
	always @(posedge(clk)) begin
		if (reset) begin
			PC = PC_RESET;
			pc_out = PC;
		end 
		else begin
			pc_out = (jump_enable_in) ? jump_addr_in : PC + 4'b0100;
			PC = pc_out;
		end
	end
	
	// PC to RAM
	assign memif_addr = PC[31:2];
	assign iw_out = memif_data;

endmodule








