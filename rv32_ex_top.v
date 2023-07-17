
module rv32_ex_top(
	
	// system clock and synchronous reset
	input clk,
	input reset,
	
	// from id
	input [31:0] pc_in,
	input [31:0] iw_in,
	input [31:0] rs1_data_in,
	input [31:0] rs2_data_in,
	input [4:0] wb_reg_in,
	input wb_enable_in,
	
	// to mem
	output reg [31:0] pc_out,
	output reg [31:0] iw_out,
	
	output reg [31:0] alu_out,
	output reg [4:0] wb_reg_out,
	output reg wb_enable_out,
	
	// data hazard: df from ex
	output df_ex_enable,
	output [4:0] df_ex_reg,
	output [31:0] df_ex_data,
	
	input wb_from_mem_id,
	output reg wb_from_mem_ex,
	
	input [31:0]  rs2_data_from_id,
	output reg [31:0] rs2_data_to_mem,
	
	input df_wb_from_mem_wb,
	input [4:0] df_wb_reg,
	input [31:0] df_wb_data
	
	);
	
	//add signed signals for calculations
	wire signed [31:0] rs1_data = $signed(rs1_data_in);
	wire signed [31:0] rs2_data = $signed(rs2_data_in);
	
	reg signed [31:0] alu_result = 32'h0;

	
	// decode instruction
	wire [6:0] opcode = iw_in[6:0];
	wire [2:0] funct3 = iw_in[14:12];
	wire [6:0] funct7 = iw_in[31:25];
	wire [4:0] shamt = iw_in[24:20];
	
	wire is_R = (opcode == 7'b0110011);
	wire is_B = (opcode == 7'b1100011);
	wire is_S = (opcode == 7'b0100011);
	
	wire [4:0] regif_rs1_reg = iw_in[19:15]; 
	wire [4:0] regif_rs2_reg = (is_R || is_B || is_S) ? iw_in[24:20] : 5'b00000;
	
   wire signed [31:0] imm_i = $signed(iw_in[31:20]);
   wire signed [31:0] imm_s = $signed({iw_in[31:25], iw_in[11:7]});
   wire signed [31:0] imm_b = $signed({iw_in[31], iw_in[7], iw_in[30:25], iw_in[11:8]});
   wire signed [31:0] imm_u = $signed(iw_in[31:12]);
   wire signed [31:0] imm_j = $signed({iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21]});
	
	// unsigned
	wire [31:0] imm_i_u = iw_in[31:20];
	 
	// WIP
	// Perform ALU operation based on opcode, funct3, funct7, and immediate
	always @ (*) begin
		/*
		if (iw_in == 32'h00000013) begin
			//alu_out = (iw_in == 32'h00000013) ? 32'h00000000 : alu_result;
			alu_result = 32'h00000000;
			//alu_result = rs1_data + imm_i;
		end 
		*/
		//else begin			
			case (opcode)
				// R-type instructions
				7'b0110011: begin
					case (funct3)
						3'b000: begin
							if (funct7 == 7'b0000000) begin
								alu_result = rs1_data + rs2_data; 					// ADD 				1
							end 
							else begin
								alu_result = rs1_data - rs2_data; 					// SUB 				3
							end
						end
						3'b001: alu_result = rs1_data << rs2_data[4:0]; 		// SLL 				10
						3'b010: alu_result = (rs1_data < rs2_data) ? 1 : 0; 	// SLT 				16
						3'b011: alu_result = ($unsigned(rs1_data) < $unsigned(rs1_data)) ? 1 : 0; 	// SLTU 				18
						
						3'b100: alu_result = rs1_data ^ rs2_data;	 				// XOR 				8
						3'b101: begin
							if (funct7 == 7'b0000000) begin
								alu_result = rs1_data >> rs2_data[4:0]; 			// SRL 				12
							end 
							else begin
								alu_result = rs1_data >> rs2_data[4:0]; 			// SRA 				14
							end
						end
						3'b110: alu_result = rs1_data | rs2_data; 				// OR 				6
						3'b111: alu_result = rs1_data & rs2_data; 				// AND 				4
						//default: alu_out = 0;
					endcase
				end

				
				// I-type instructions
				7'b1100111:	alu_result = pc_in + 4; 										// JALR 				20		//
					
				7'b0000011: begin
					case (funct3)
						3'b000: alu_result = rs1_data + imm_i; 						// LB 				24
						3'b001: alu_result = rs1_data + imm_i; 						// LH 				26
						3'b010: alu_result = rs1_data + imm_i; 						// LW 				28
						3'b100: alu_result = rs1_data + imm_i; 						// LBU 				25
						3'b101: alu_result = rs1_data + imm_i; 						// LHU 				27
						//default: alu_out = 0;
					endcase
				end
					
				7'b0010011: begin
					case (funct3)
						3'b000: alu_result = rs1_data + imm_i; 						// ADDI 				2
						3'b010: alu_result = (rs1_data < imm_i) ? 1 : 0; 			// SLTI 				17
						3'b011: alu_result = ($unsigned(rs1_data) < $unsigned(imm_i)) ? 1 : 0; 			// SLTIU 			19
						3'b100: alu_result = rs1_data ^ imm_i; 						// XORI 				9
						3'b110: alu_result = rs1_data | imm_i; 						// ORI 				7
						3'b111: alu_result = rs1_data & imm_i; 						// ANDI 				5
						3'b001: alu_result = rs1_data << shamt; 						// SLLI 				11
						3'b101: begin
							if (funct7 == 7'b0000000) begin
								alu_result = rs1_data >> shamt; 							// SRLI 				13
							end 
							else begin
								alu_result = rs1_data >> shamt; 							// SRAI 				15
							end
						end
						//default: alu_out = 0;
					endcase
				end
					
				// S-type instructions
				7'b0100011: begin
					case (funct3)
						3'b000: alu_result = rs1_data + imm_s; 			// SB 				29
						3'b001: alu_result = rs1_data + imm_s; 			// SH 				30
						3'b010: alu_result = rs1_data + imm_s; 			// SW 				31
						//default: alu_out = 0;
					endcase
				end
					
				// B-type instructions
				7'b1100011: begin
					alu_result = 0;
					case (funct3)
						3'b000: begin																		// BEQ
							if (rs1_data == rs2_data) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
							
						3'b001: begin																		// BNE
							if (rs1_data != rs2_data) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
							
						3'b100: begin																		// BLT
							if (rs1_data < rs2_data) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
							
						3'b101: begin																		// BGE
							if (rs1_data >= rs2_data) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
							
						3'b110: begin																		// BLTU
							if ($unsigned(rs1_data_in) < $unsigned(rs2_data_in)) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
							
						3'b111: begin																		// BGEU
							if ($unsigned(rs1_data_in) >= $unsigned(rs2_data_in)) begin
								//alu_result = 0;
							end
							else begin
								//alu_result = 0;
							end
						end
			
						default: alu_result = 0;
					endcase	
				end

				// U-type instructions
				7'b0110111: alu_result = {imm_u[19:0],12'b0}; 							// LUI 				22
				7'b0010111: alu_result = {imm_u[19:0],12'b0} + pc_in; 				// AUIPC 			23
	
				// J-type instructions
				7'b1101111: alu_result = pc_in + 4; 										// JAL 				21		//
				
				//default: alu_out = 32'h0;
			endcase
		//end
	end
	
	always @ (posedge(clk)) begin
		if (reset) begin
			pc_out = 32'h00000000;
			iw_out = 32'h00000000;
			alu_out = 32'h00000000;
			wb_reg_out = 5'b00000;
			wb_enable_out = 1'b0;
		end 
		else begin
			pc_out = pc_in;
			iw_out = iw_in;
			alu_out = alu_result;
		
			wb_reg_out = wb_reg_in;				//(2)
			wb_enable_out = wb_enable_in;		//(1)
			
			rs2_data_to_mem = rs2_data_from_id;
			
			wb_from_mem_ex = wb_from_mem_id;
		end
	end
	
	assign df_ex_enable = wb_enable_in;		//(1)
	assign df_ex_reg = wb_reg_in;				//(2)
	assign df_ex_data = alu_result;			//(N/A)
	
endmodule
	
	
	
	
	
	