
module rv32_id_top(

	// system clock and synchronous reset
	input clk,
	input reset,
	
	// from if
	input [31:0] pc_in,
	input [31:0] iw_in,
	
	// to if
	output jump_enable_out,
	output [31:0] jump_addr_out,
	
	// register interface
	output [4:0] regif_rs1_reg,
	output [4:0] regif_rs2_reg,
	
	input [31:0] regif_rs1_data,
	input [31:0] regif_rs2_data,
	
	// to ex
	output reg [31:0] pc_out,
	output reg [31:0] iw_out,
	output reg [31:0] reg_rs1_data,
	output reg [31:0] reg_rs2_data,
	output reg [4:0] wb_reg_out,
	output reg wb_enable_out,
	
	// data hazard: df from ex
	input df_ex_enable,
	input [4:0] df_ex_reg,
	input [31:0] df_ex_data,
	
	// data hazard: df from mem
	input df_mem_enable,
	input [4:0] df_mem_reg,
	input [31:0] df_mem_data,
	
	// data hazard: df from wb
	input df_wb_enable,
	input [4:0] df_wb_reg,
	input [31:0] df_wb_data,
	
	output reg wb_from_mem,
	
	//rs2 Data to mem
	output reg [31:0] rs2_data_to_ex,
	
	// register df from ex
	input df_wb_from_mem_ex,
	// register df from mem
	input df_wb_from_mem_mem,
	
	//disable PC if branch
	output pc_stop
	
	);
	
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [4:0] rd;
	
	wire is_R;
	wire is_S;
	
	wire rs1_ex_check;
	wire rs1_mem_check;
	wire rs1_wb_check;
	
	wire rs2_ex_check;
	wire rs2_mem_check;
	wire rs2_wb_check;
	
	wire [31:0] rs1_data_jump;
	wire [31:0] rs2_data_jump;
	
	wire is_JAL;
	wire is_JALR;
	wire is_B;
	
	wire is_BEQ;
	wire is_BNE;
	wire is_BLT;
	wire is_BGE;
	wire is_BLTU;
	wire is_BGEU;
	
	wire branch_condition;
	
	wire [11:0] imm_i;			//iw_in[31:20];
   wire [11:0] imm_b;			//{iw_in[31], iw_in[7], iw_in[30:25], iw_in[11:8]};
   wire [19:0] imm_j;			//{iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21]};
	
	wire [31:0] i_imm_32;
	wire [31:0] sb_imm_32;
	wire [31:0] uj_imm_32;
	
	wire [31:0] addr_JALR;	//I	rs1 + signex(i[11:0])
	wire [31:0] addr_B;		//B	pc + 2*signex(i[12:1])
	wire [31:0] addr_JAL;	//J	pc + 2*signex(i[20:1])
	
	
	
	
	
	
	
	assign opcode = iw_in[6:0];
	assign funct3 = iw_in[14:12];
	assign rd = 	 iw_in[11:7];
	
	assign is_R = (opcode == 7'b0110011);
	assign is_B = (opcode == 7'b1100011);
	assign is_S = (opcode == 7'b0100011);
	//wire is_I = (opcode == 7'b0000011) || (opcode == 7'b0010011) || (opcode == 7'b1100111);
	
	// To rv32i_regs
	assign regif_rs1_reg = iw_in[19:15]; //rs1 okay because its the same for R&I	
	assign regif_rs2_reg = (is_R || is_B || is_S) ? iw_in[24:20] : 5'b00000; // Assign regif_rs2_reg based on the type of instruction (R or I)
	
	//Lab6
	assign rs1_ex_check =  (((regif_rs1_reg == df_ex_reg)  && df_ex_enable)  && (regif_rs1_reg != 0));
	assign rs1_mem_check = (((regif_rs1_reg == df_mem_reg) && df_mem_enable) && (regif_rs1_reg != 0));
	assign rs1_wb_check =  (((regif_rs1_reg == df_wb_reg)  && df_wb_enable)  && (regif_rs1_reg != 0));
	
	assign rs2_ex_check =  (((regif_rs2_reg == df_ex_reg)  && df_ex_enable)  && (regif_rs2_reg != 0));
	assign rs2_mem_check = (((regif_rs2_reg == df_mem_reg) && df_mem_enable) && (regif_rs2_reg != 0));
	assign rs2_wb_check =  (((regif_rs2_reg == df_wb_reg)  && df_wb_enable)  && (regif_rs2_reg != 0));
	
	reg ebreak_detected;
	
	
	wire signed [31:0] signed_df_ex_data =  $signed(df_ex_data);
	wire signed [31:0] signed_df_mem_data = $signed(df_mem_data);
	wire signed [31:0] signed_df_wb_data =  $signed(df_wb_data);
	wire signed [31:0] signed_df_rs1_data = $signed(regif_rs1_data);
	wire signed [31:0] signed_df_rs2_data = $signed(regif_rs2_data);
		
	wire [31:0] unsigned_rs1_data_jump = (rs1_ex_check) ? df_ex_data : (rs1_mem_check) ? df_mem_data : (rs1_wb_check) ? df_wb_data : regif_rs1_data;
	wire [31:0] unsigned_rs2_data_jump = (rs2_ex_check) ? df_ex_data : (rs2_mem_check) ? df_mem_data : (rs2_wb_check) ? df_wb_data : regif_rs2_data;
	
	wire signed [31:0] signed_rs1_data_jump = (rs1_ex_check) ? signed_df_ex_data : (rs1_mem_check) ? signed_df_mem_data : (rs1_wb_check) ? signed_df_wb_data : signed_df_rs1_data;
	wire signed [31:0] signed_rs2_data_jump = (rs2_ex_check) ? signed_df_ex_data : (rs2_mem_check) ? signed_df_mem_data : (rs2_wb_check) ? signed_df_wb_data : signed_df_rs2_data;
		

	
	assign is_JAL =  (opcode == 7'b1101111);
	assign is_JALR = (opcode == 7'b1100111);
	
	assign is_BEQ =  is_B && (funct3 == 3'b000) && (signed_rs1_data_jump == signed_rs2_data_jump);
	assign is_BNE =  is_B && (funct3 == 3'b001) && (signed_rs1_data_jump != signed_rs2_data_jump);
	
	assign is_BLT =  is_B && (funct3 == 3'b100) && (signed_rs1_data_jump < signed_rs2_data_jump);
	assign is_BGE =  is_B && (funct3 == 3'b101) && (signed_rs1_data_jump >= signed_rs2_data_jump);
	
	assign is_BLTU = is_B && (funct3 == 3'b110) && (unsigned_rs1_data_jump < unsigned_rs2_data_jump);	//unsigned
	assign is_BGEU = is_B && (funct3 == 3'b111) && (unsigned_rs1_data_jump >= unsigned_rs2_data_jump);	//unsigned

	// Branch condition
	assign branch_condition = is_BEQ || is_BNE || is_BLT || is_BGE || is_BLTU || is_BGEU;
	
	// Jump enable
	assign jump_enable_out = (ebreak_detected) ? 32'h0 : (is_JAL || is_JALR || (is_B && branch_condition));
		
	assign imm_i = iw_in[31:20];
   assign imm_b = {iw_in[31], iw_in[7], iw_in[30:25], iw_in[11:8]};
   assign imm_j = {iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21]};
	
	//JALR
	wire signed [11:0] signed_imm_i;
	wire signed [31:0] extended_imm_i;
	assign signed_imm_i = $signed(imm_i);
	assign extended_imm_i = {{20{signed_imm_i[11]}}, signed_imm_i};
	
	//BRANCH
	wire signed [11:0] signed_imm_b;
	wire signed [31:0] extended_imm_b;
	assign signed_imm_b = $signed(imm_b);
	assign extended_imm_b = {{20{signed_imm_b[11]}}, signed_imm_b};
	
	//JAL
	wire signed [19:0] signed_imm_j;
	wire signed [31:0] extended_imm_j;
	assign signed_imm_j = $signed(imm_j);
	assign extended_imm_j = {{12{signed_imm_j[19]}}, signed_imm_j};
	
	wire signed [31:0] signed_pc_out = $signed(pc_out);
	
	assign addr_JALR = df_mem_data + extended_imm_i[11:0];	//I	rs1 + signex(i[11:0])
	assign addr_B = signed_pc_out + (2*extended_imm_b);		//B	pc + 2*signex(i[12:1])
	assign addr_JAL = signed_pc_out + (2*extended_imm_j);		//J	pc + 2*signex(i[20:1])

	assign jump_addr_out = (ebreak_detected) ? 32'h0 : (is_B && branch_condition) ? addr_B : (is_JAL) ? addr_JAL : (is_JALR) ? addr_JALR : 32'h0;
	
	//stall will be sequential logic, for branch stall, use temp iw.
	reg [31:0] iw_out_next;
	reg jump_detected;

	always @(posedge(clk)) begin
		if (reset) begin
			ebreak_detected = 0;
			jump_detected = 0;
			iw_out_next = 32'h00000013;
			
			pc_out = 32'h00000000;
			iw_out = 32'h00000013;
			reg_rs1_data = 32'h00000000;
			reg_rs2_data = 32'h00000000;
			wb_reg_out = 5'b00000;
			wb_enable_out = 1'b0;
		end 
		else begin
			if (iw_in == 32'h00100073) begin
				ebreak_detected = 1'b1;				
			
				pc_out = 32'h00000000;
				iw_out = 32'h00000013;
				reg_rs1_data = 32'h00000000;
				reg_rs2_data = 32'h00000000;
				wb_reg_out = 5'b00000;
				wb_enable_out = 1'b1;
			end 
			else if (ebreak_detected == 0) begin
				if (jump_enable_out) begin
					jump_detected = 1'b1;
				end
				else if (jump_detected) begin
					jump_detected = 1'b0;
					iw_out_next = (!jump_detected) ? 32'h00000013 : iw_in;
				end
				else begin
					iw_out_next = iw_in;
				end
				
				pc_out = pc_in;
				iw_out = (jump_enable_out) ? iw_in : iw_out_next;
				
				// Data forwarding logic
				reg_rs1_data = (rs1_ex_check) ? df_ex_data : (rs1_mem_check) ? df_mem_data : (rs1_wb_check) ? df_wb_data : regif_rs1_data;
				reg_rs2_data = (rs2_ex_check) ? df_ex_data : (rs2_mem_check) ? df_mem_data : (rs2_wb_check) ? df_wb_data : regif_rs2_data;
				
				rs2_data_to_ex = reg_rs2_data;
				wb_from_mem = (is_S) ? 1'b1 : 1'b0;
								
				case (opcode)
					// R-type instructions
					7'b0110011: begin
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					// I-type instructions
					7'b1100111: begin					//jalr
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					7'b0000011: begin					//load instructions
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					7'b0010011: begin //addi
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					// S-type instructions
					7'b0100011: begin					//store instructions
						wb_reg_out = 0;
						wb_enable_out = 1'b1;
					end
					
					// B-type instructions
					7'b1100011: begin 				//Branch 
						wb_reg_out = 0;
						wb_enable_out = 1'b0;
					end
					
					// U-type instructions
					7'b0110111: begin 				//lui
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					7'b0010111: begin 				//auipc
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end

					// J-type instructions
					7'b1101111: begin					//jal
						wb_reg_out = rd;
						wb_enable_out = 1'b1;
					end
						
					//EBREAK
					7'b1110011: begin
						if (iw_in == 32'h00100073) begin
							ebreak_detected = 1'b1;
							wb_enable_out = 1'b0;
						end
					end
				endcase
			end 
			else begin
				if (ebreak_detected == 1'b1) begin					
					pc_out = 32'h00000000;
					iw_out = 32'h00000013;
					reg_rs1_data = 32'h00000000;
					reg_rs2_data = 32'h00000000;
					wb_reg_out = 5'b00000;
					wb_enable_out = 1'b1;
				end
			end
		end
	end
	
endmodule	
	
	