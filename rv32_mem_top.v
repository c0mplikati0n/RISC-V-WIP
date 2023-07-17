
module rv32_mem_top(
	
	// system clock and synchronous reset
	input clk,
	input reset,
	
	// from ex
	input [31:0] pc_in,
	input [31:0] iw_in,
	input [31:0] alu_in,
	input [4:0] wb_reg_in,
	input wb_enable_in,
	
	// to wb
	output reg [31:0] pc_out,
	output reg [31:0] iw_out,
	output reg [31:0] alu_out,
	output reg [4:0] wb_reg_out,
	output reg wb_enable_out,
	
	// data hazard: df from mem
	output df_mem_enable,
	output [4:0] df_mem_reg,
	output [31:0] df_mem_data,
	
	// memory interface
	output [31:2] memif_addr,
	input [31:0] memif_rdata,
	output memif_we,
	output [3:0] memif_be,
	output [31:0] memif_wdata,

	// io interface
	output [31:2] io_addr,
	input [31:0] io_rdata,
	output io_we,
	output [3:0] io_be,
	output [31:0] io_wdata,
	
	input wb_from_ex_mem,
	output reg wb_from_mem_wb,
	
	//rs2 Data from id
	input [31:0] rs2_data_from_ex,
	
	//to wb already registered?
	output [31:0] memif_rdata_to_wb,
	output [31:0] io_rdata_to_wb,
	
	output reg [1:0] control_wb, // (00: alu_out, 01: memif_rdata, 10: io_rdata)
	
	input [31:0] alu_data_in
	
	);
	
	wire [6:0] opcode = iw_in[6:0];
	wire [2:0] funct3 = iw_in[14:12];
	wire [4:0] rd = iw_in[11:7];
	wire A31 = alu_in[31];
	
	wire is_S = (opcode == 7'b0100011);
	wire is_load = (opcode == 7'b0000011);
	
	wire [1:0] width = funct3[1:0];
	wire [1:0] addr_be = alu_in[1:0];
	
	
	
	wire is_word = ((is_S) && (width == 2'b10)) ? 1'b1 : 1'b0;
	
	wire is_hw0 = ((is_S) && (width == 2'b01) && (addr_be == 2'b00)) ? 1'b1 : 1'b0;
	wire is_hw1 = ((is_S) && (width == 2'b01) && (addr_be == 2'b01)) ? 1'b1 : 1'b0;
	wire is_hw2 = ((is_S) && (width == 2'b01) && (addr_be == 2'b10)) ? 1'b1 : 1'b0;
	
	wire is_byte0 = ((is_S) && (width == 2'b00) && (addr_be == 2'b00)) ? 1'b1 : 1'b0;
	wire is_byte1 = ((is_S) && (width == 2'b00) && (addr_be == 2'b01)) ? 1'b1 : 1'b0;
	wire is_byte2 = ((is_S) && (width == 2'b00) && (addr_be == 2'b10)) ? 1'b1 : 1'b0;
	wire is_byte3 = ((is_S) && (width == 2'b00) && (addr_be == 2'b11)) ? 1'b1 : 1'b0;
	
	// 000 = Byte		001 = HalfWord			010 = Word
	wire [3:0] be = (is_S) ? ((is_word) ? 4'b1111 : (is_hw0) ? 4'b0011 : (is_hw1) ? 4'b0110 : (is_hw2) ? 4'b1100 : (is_byte0) ? 4'b0001 : (is_byte1) ? 4'b0010 : (is_byte2) ? 4'b0100 : (is_byte3) ? 4'b1000 : 4'b0000) : 4'b0000;
	//*/
	
	wire [6:0] opcode_out = iw_out[6:0];
	wire [2:0] funct3_out = iw_out[14:12];
	
	wire is_S_out = (opcode_out == 7'b0100011);
	wire is_load_out = (opcode_out == 7'b0000011);
	
	wire [1:0] width_out = funct3_out[1:0];
	wire [1:0] addr_be_out = alu_out[1:0];
	
	wire is_unsigned = funct3_out[2];
	
	
	
	wire is_word_out = ((is_load_out) && (width_out == 2'b10)) ? 1'b1 : 1'b0;
	
	wire is_hw_out0 = ((is_load_out) && (width_out == 2'b01) && (addr_be_out == 2'b00)) ? 1'b1 : 1'b0;
	wire is_hw_out1 = ((is_load_out) && (width_out == 2'b01) && (addr_be_out == 2'b01)) ? 1'b1 : 1'b0;
	wire is_hw_out2 = ((is_load_out) && (width_out == 2'b01) && (addr_be_out == 2'b10)) ? 1'b1 : 1'b0;
	
	wire is_byte_out0 = ((is_load_out) && (width_out == 2'b00) && (addr_be_out == 2'b00)) ? 1'b1 : 1'b0;
	wire is_byte_out1 = ((is_load_out) && (width_out == 2'b00) && (addr_be_out == 2'b01)) ? 1'b1 : 1'b0;
	wire is_byte_out2 = ((is_load_out) && (width_out == 2'b00) && (addr_be_out == 2'b10)) ? 1'b1 : 1'b0;
	wire is_byte_out3 = ((is_load_out) && (width_out == 2'b00) && (addr_be_out == 2'b11)) ? 1'b1 : 1'b0;
	
	
	
	wire [3:0] be_load = (is_load_out) ? ((is_word_out) ? 4'b1111 : (is_hw_out0) ? 4'b0011 : (is_hw_out1) ? 4'b0110 : (is_hw_out2) ? 4'b1100 : (is_byte_out0) ? 4'b0001 : (is_byte_out1) ? 4'b0010 : (is_byte_out2) ? 4'b0100 : (is_byte_out3) ? 4'b1000 : 4'b0000) : 4'b0000;	
	
	
	
	reg [31:0] memif_rdata_register;
	reg [1:0] control_wb_register;
		
	always @(posedge(clk)) begin
		if (reset) begin
			pc_out = 32'h00000000;
			iw_out = 32'h00000013;
			alu_out = 32'h00000000;
			wb_reg_out = 5'b00000;
			wb_enable_out = 1'b0;
		end 
		else begin
			pc_out = pc_in;
			iw_out = iw_in;
			
			alu_out = alu_in;					//(3)
			wb_enable_out = wb_enable_in; //(1)
			wb_reg_out = wb_reg_in;			//(2)
						
			control_wb = ((is_load) && (A31 == 1'b1)) ? 2'b10 : ((is_load) && (A31 == 1'b0)) ? 2'b01 : 2'b00;
						
			wb_from_mem_wb = wb_from_ex_mem;
		end
	end
	
	//Lab 5 - to id
	assign df_mem_enable = wb_enable_in;	//(1)
	assign df_mem_reg = wb_reg_in;			//(2)
	assign df_mem_data = alu_in;				//(3)
	
	assign memif_addr = (wb_from_ex_mem) ? alu_in[31:2] : (is_load) ? alu_in[31:2] : 0;
	assign io_addr = (wb_from_ex_mem) ? alu_in[31:2] : (is_load) ? alu_in[31:2] : 0;
	
	assign memif_we = ((wb_from_ex_mem) && (A31 == 1'b0)) ? 1'b1 : 1'b0; //final
	assign io_we =    ((wb_from_ex_mem) && (A31 == 1'b1)) ? 1'b1 : 1'b0; //final
	
	assign memif_be = be;									//bits we are writing to
	assign io_be = be;
		
	// WIP
	assign memif_wdata = (wb_from_ex_mem) ? ((is_word)  ? rs2_data_from_ex :
														  (is_hw0)   ? {16'h0000, rs2_data_from_ex[15:0]} :
														  (is_hw1)   ? {8'h00, rs2_data_from_ex[15:0], 8'h00} :
													     (is_hw2)   ? {rs2_data_from_ex[15:0], 16'h0000} :
													     (is_byte0) ? {24'h0, rs2_data_from_ex[7:0]} :
														  (is_byte1) ? {16'h0000, rs2_data_from_ex[7:0], 8'h00} :
														  (is_byte2) ? {8'h00, rs2_data_from_ex[7:0], 16'h0000} :
														  (is_byte3) ? {rs2_data_from_ex[7:0], 24'h000000} : 0) : 0;

	// WIP									  
	assign io_wdata = (wb_from_ex_mem) ? ((is_word)  ? rs2_data_from_ex :
												     (is_hw0)   ? {16'h0000, rs2_data_from_ex[15:0]} :
													  (is_hw1)   ? {8'h00, rs2_data_from_ex[15:0], 8'h00} :
													  (is_hw2)   ? {rs2_data_from_ex[15:0], 16'h0000} :
													  (is_byte0) ? {24'h0, rs2_data_from_ex[7:0]} :
													  (is_byte1) ? {16'h0000, rs2_data_from_ex[7:0], 8'h00} :
													  (is_byte2) ? {8'h00, rs2_data_from_ex[7:0], 16'h0000} :
													  (is_byte3) ? {rs2_data_from_ex[7:0], 24'h000000} : 0) : 0;
	
	
	
	
	
	assign memif_rdata_to_wb = (!is_unsigned) ? ((is_word_out)  ? memif_rdata :
														      (is_hw_out2)   ? {{16{memif_rdata[15]}}, memif_rdata[15:0]} :
																(is_hw_out1)   ? {{16{memif_rdata[23]}}, memif_rdata[23:8]} :
																(is_hw_out0)   ? {{16{memif_rdata[31]}}, memif_rdata[31:16]} :
																(is_byte_out3) ? {{24{memif_rdata[7]}}, memif_rdata[7:0]}   :
																(is_byte_out2) ? {{24{memif_rdata[15]}}, memif_rdata[15:8]}  :
																(is_byte_out1) ? {{24{memif_rdata[23]}}, memif_rdata[23:16]} :
																(is_byte_out0) ? {{24{memif_rdata[31]}}, memif_rdata[31:24]} : 0) :
																
																(is_word_out)  ? memif_rdata :
																(is_hw_out2)   ? {16'h0000, memif_rdata[15:0]} :
																(is_hw_out1)   ? {16'h0000, memif_rdata[23:8]} :
																(is_hw_out0)   ? {16'h0000, memif_rdata[31:16]} :
																(is_byte_out3) ? {24'h0, memif_rdata[7:0]}   :
																(is_byte_out2) ? {24'h0, memif_rdata[15:8]}  :
																(is_byte_out1) ? {24'h0, memif_rdata[23:16]} :
																(is_byte_out0) ? {24'h0, memif_rdata[31:24]} : 0;
															
	assign io_rdata_to_wb = (!is_unsigned) ? ((is_word_out)  ? io_rdata :
														   (is_hw_out2)   ? {{16{io_rdata[15]}}, io_rdata[15:0]} :
													      (is_hw_out1)   ? {{16{io_rdata[23]}}, io_rdata[23:8]} :
														   (is_hw_out0)   ? {{16{io_rdata[31]}}, io_rdata[31:16]} :
														   (is_byte_out3) ? {{24{io_rdata[7]}}, io_rdata[7:0]}   :
														   (is_byte_out2) ? {{24{io_rdata[15]}}, io_rdata[15:8]}  :
														   (is_byte_out1) ? {{24{io_rdata[23]}}, io_rdata[23:16]} :
														   (is_byte_out0) ? {{24{io_rdata[31]}}, io_rdata[31:24]} : 0) :
															 
															(is_word_out)  ? io_rdata :
														   (is_hw_out2)   ? {16'h0000, io_rdata[15:0]} :
													      (is_hw_out1)   ? {16'h0000, io_rdata[23:8]} :
														   (is_hw_out0)   ? {16'h0000, io_rdata[31:16]} :
														   (is_byte_out3) ? {24'h0, io_rdata[7:0]}   :
														   (is_byte_out2) ? {24'h0, io_rdata[15:8]}  :
														   (is_byte_out1) ? {24'h0, io_rdata[23:16]} :
														   (is_byte_out0) ? {24'h0, io_rdata[31:24]} : 0;
	
	
endmodule




