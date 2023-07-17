
module rv32i_regs (
 
	// system clock and synchronous reset
	input clk,
	input reset,
	
	// inputs
	input [4:0] rs1_reg,		//from id
	input [4:0] rs2_reg,		//from id
	
	input wb_enable,			//from wb	are we writing?
	input [4:0] wb_reg,		//from wb 	register were putting some data in
	input [31:0] wb_data,	//from wb 	data going in
	
	// outputs
	output [31:0] rs1_data,	//to id
	output [31:0] rs2_data	//to id
	
);

	reg [31:0] reg_file [0:31];

	always @(posedge clk) begin
		if (reset) begin
			// Synchronously clear all registers
			reg_file[0] = 32'h0; reg_file[1] = 32'h0; reg_file[2] = 32'h0; reg_file[3] = 32'h0; 
			reg_file[4] = 32'h0; reg_file[5] = 32'h0; reg_file[6] = 32'h0; reg_file[7] = 32'h0; 
			reg_file[8] = 32'h0; reg_file[9] = 32'h0; reg_file[10] = 32'h0; reg_file[11] = 32'h0; 
			reg_file[12] = 32'h0; reg_file[13] = 32'h0; reg_file[14] = 32'h0; reg_file[15] = 32'h0; 
			reg_file[16] = 32'h0; reg_file[17] = 32'h0; reg_file[18] = 32'h0; reg_file[19] = 32'h0; 
			reg_file[20] = 32'h0; reg_file[21] = 32'h0; reg_file[22] = 32'h0; reg_file[23] = 32'h0; 
			reg_file[24] = 32'h0; reg_file[25] = 32'h0; reg_file[26] = 32'h0; reg_file[27] = 32'h0; 
			reg_file[28] = 32'h0; reg_file[29] = 32'h0; reg_file[30] = 32'h0; reg_file[31] = 32'h0;
		end
		else begin

			// Synchronously writeback to the register file
			if (wb_enable && (wb_reg != 5'b0)) begin
				reg_file[wb_reg] = wb_data;
			end
		end
	end
	
	// Asynchronously output rs1_data and rs2_data
	assign rs1_data = reg_file[rs1_reg];
	assign rs2_data = reg_file[rs2_reg];

endmodule




