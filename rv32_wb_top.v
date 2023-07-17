
module rv32_wb_top(
	
	// system clock and synchronous reset
	input clk,
	input reset,
	
	// from mem
	input [31:0] pc_in,
	input [31:0] iw_in,

	input [31:0] alu_in,
	input [4:0] wb_reg_in,
	input wb_enable_in,
	
	// register interface
	output regif_wb_enable,
	output [4:0] regif_wb_reg,
	output [31:0] regif_wb_data,
	
	// data hazard: df from wb
	output df_wb_enable,
	output [4:0] df_wb_reg,
	output [31:0] df_wb_data,
	
	input wb_from_mem_wb,
	output reg wb_from_wb_ex,
	
	//from mem
	input [31:0] memif_rdata_from_mem,
	input [31:0] io_rdata_from_mem,
	
	input [1:0] control_wb

	);
	
	always @(posedge(clk)) begin
		if (reset) begin
			
		end 
		else begin
		
			wb_from_wb_ex = wb_from_mem_wb;		
		end
	end
	
	assign regif_wb_enable = wb_enable_in; 											//(1)
	assign regif_wb_reg = wb_reg_in;														//(2)
	assign regif_wb_data = (control_wb == 2'b00) ? alu_in : 
								  (control_wb == 2'b01) ? memif_rdata_from_mem : 
								  (control_wb == 2'b10) ? io_rdata_from_mem : 0; 	//(3)
	
	
	
	assign df_wb_enable = wb_enable_in;													//(1)
	assign df_wb_reg = wb_reg_in;															//(2)
	assign df_wb_data = (control_wb == 2'b00) ? alu_in : 
							  (control_wb == 2'b01) ? memif_rdata_from_mem : 
							  (control_wb == 2'b10) ? io_rdata_from_mem : 0; 		//(3)

endmodule

	