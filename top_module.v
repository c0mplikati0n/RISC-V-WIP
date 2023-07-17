
module top_module(

   input ADC_CLK_10,
   input [1:0] KEY,
	input [9:0] SW
	 
	);
	
	
	
	//From if to memory
	wire [31:0] memif_addr;
	wire [31:0] memif_data;
	
	
	
	//From if to id
	wire [31:0] pc_if;
	wire [31:0] iw_if;
	
	//From id to if
	wire jump_enable_in;
	wire [31:0] jump_addr_in;
	
	wire pc_stop_signal;
	
	
	
	//From id to ex
	wire [31:0] pc_id;
	wire [31:0] iw_id;
	wire [31:0] rs1_data_id;
	wire [31:0] rs2_data_id;
	wire [4:0] wb_reg_out_id;
	wire wb_enable_out_id;
	
	wire wb_lab8_id_ex;
	
	//From id to mem
	wire [31:0] rs2_data_going_ex;
	wire [31:0] rs2_data_going_mem;
	
	//From ex to mem
	wire [31:0] pc_ex;
	wire [31:0] iw_ex;
	wire [31:0] alu_out_ex;
	wire [4:0] wb_reg_out_ex;
	wire wb_enable_out_ex;
	
	wire wb_lab8_ex_mem;
	
	//From mem to wb
	wire [31:0] pc_mem;
	wire [31:0] iw_mem;
	wire [31:0] alu_out_mem;
	wire [4:0] wb_reg_out_mem;
	wire wb_enable_out_mem;
	
	wire wb_lab8_mem_wb;
	
	wire [31:0] memif_rdata_top;
	wire [31:0] io_rdata_top;
	
	wire [1:0] ctrl_mem_to_wb;
	
	wire wb_lab8_wb_ex;
	
	
	
	//From id to register
	wire [4:0] rs1_reg;
	wire [4:0] rs2_reg;
	wire [31:0] rs1_data;
	wire [31:0] rs2_data;
	
	//From wb to register
	wire [4:0] wb_reg_out_wb;
	wire wb_enable_out_wb;
	wire [31:0] alu_out_wb;
	
	
	
	// data hazard: df from ex
	wire ex_enable;
	wire [4:0] ex_reg;
	wire [31:0] ex_data;
	
	// data hazard: df from mem
	wire mem_enable;
	wire [4:0] mem_reg;
	wire [31:0] mem_data;
	
	// data hazard: df from wb
	wire wb_enable;
	wire [4:0] wb_reg;
	wire [31:0] wb_data;
	
	
	
	// memory interface
	wire [31:0] memif_addr_RAM;
	wire [31:0] memif_rdata_RAM;
	wire memif_we_RAM;
	wire [3:0] memif_be_RAM;
	wire [31:0] memif_wdata_RAM;

	// io interface	
	wire [31:0] io_addr_io;
	wire [31:0] io_rdata_io;
	wire io_we_io;
	wire [3:0] io_be_io;
	wire [31:0] io_wdata_io;
		

		
	// local clock
	wire clk = ADC_CLK_10;
    
	// reset
	reg reset;
	reg pre_reset;
	
	always @ (posedge(clk))
	begin
		pre_reset <= !KEY[0];
		reset <= pre_reset;
	end
	

	
	sync_dual_port_ram ram (
		.clk(clk),			
		
		.i_addr(memif_addr),		
		.i_rdata(memif_data),	
		
		.d_addr(memif_addr_RAM),	//in
		.d_rdata(memif_rdata_RAM),	//out
		
		.d_we(memif_we_RAM),			//in
		.d_be(memif_be_RAM),			//in
		.d_wdata(memif_wdata_RAM)	//in
	);
	
	

	rv32i_regs regs_inst (
		.clk(clk),				
		.reset(reset),			
		
		.rs1_reg(rs1_reg),	
		.rs2_reg(rs2_reg),	
		
		.wb_enable(wb_enable_out_wb),
		.wb_reg(wb_reg_out_wb),
		.wb_data(alu_out_wb),
		
		.rs1_data(rs1_data),	
		.rs2_data(rs2_data)	
	);
		
		
		
	rv32_io_top inandout(
		.clk(clk),
		.reset(reset),
		
		// io interface
		.io_addr(io_addr_io),
		.io_rdata(io_rdata_io),
		.io_we(io_we_io),
		.io_be(io_be_io),
		.io_wdata(io_wdata_io),
		
		.btn_free(),
		.led_out()
	);
	
	
	
	rv32_if_top fetch(
	// system clock and synchronous reset
	.clk(clk),
	.reset(reset),
	
	// memory interface
	.memif_addr(memif_addr),
	.memif_data(memif_data),

	// to id
	.pc_out(pc_if),
	.iw_out(iw_if), // note this was registered in the memory already
	
	// from id
	.jump_enable_in(jump_enable_in),
	.jump_addr_in(jump_addr_in),
	
	.pc_stop(pc_stop_signal)
	
	);
   
	  
	  
	rv32_id_top decode(

	// system clock and synchronous reset
	.clk(clk),
	.reset(reset),
	
	// from if
	.pc_in(pc_if),
	.iw_in(iw_if),
	
	// to if
	.jump_enable_out(jump_enable_in),
	.jump_addr_out(jump_addr_in),
	
	// register interface
	.regif_rs1_reg(rs1_reg),	
	.regif_rs2_reg(rs2_reg),	
	.regif_rs1_data(rs1_data),	
	.regif_rs2_data(rs2_data),	
	
	// to ex
	.pc_out(pc_id),
	.iw_out(iw_id),
	.reg_rs1_data(rs1_data_id),
	.reg_rs2_data(rs2_data_id),
	.wb_reg_out(wb_reg_out_id),
	.wb_enable_out(wb_enable_out_id),
	
	// data hazard: df from ex
	.df_ex_enable(ex_enable),
	.df_ex_reg(ex_reg),
	.df_ex_data(ex_data),
	
	// data hazard: df from mem
	.df_mem_enable(mem_enable),
	.df_mem_reg(mem_reg),
	.df_mem_data(mem_data),
	
	// data hazard: df from wb
	.df_wb_enable(wb_enable),
	.df_wb_reg(wb_reg),
	.df_wb_data(wb_data),
	
	.wb_from_mem(wb_lab8_id_ex),
	
	//rs2 Data to mem
	.rs2_data_to_ex(rs2_data_going_ex),
	
	// register df from ex
	.df_wb_from_mem_ex(wb_lab8_id_ex),
	// register df from mem
	.df_wb_from_mem_mem(wb_lab8_ex_mem),
	
	.pc_stop(pc_stop_signal)
	
	);
	


	rv32_ex_top execute(
	
	// system clock and synchronous reset
	.clk(clk),
	.reset(reset),
	
	// from id
	.pc_in(pc_id),
	.iw_in(iw_id),
	.rs1_data_in(rs1_data_id), 
	.rs2_data_in(rs2_data_id), 
	.wb_reg_in(wb_reg_out_id),
	.wb_enable_in(wb_enable_out_id),
	
	// to mem
	.pc_out(pc_ex),
	.iw_out(iw_ex),
	.alu_out(alu_out_ex),
	.wb_reg_out(wb_reg_out_ex),
	.wb_enable_out(wb_enable_out_ex),
	
	// data hazard: to id
	.df_ex_enable(ex_enable),
	.df_ex_reg(ex_reg),
	.df_ex_data(ex_data),
	
	.wb_from_mem_id(wb_lab8_id_ex),
	.wb_from_mem_ex(wb_lab8_ex_mem),
	
	//rs2 Data to mem
	.rs2_data_from_id(rs2_data_going_ex),
	.rs2_data_to_mem(rs2_data_going_mem),
	
	.df_wb_from_mem_wb(wb_lab8_wb_ex),
	.df_wb_reg(wb_reg),
	.df_wb_data(wb_data)
	
	);



	rv32_mem_top memory(
	
	// system clock and synchronous reset
	.clk(clk),	
	.reset(reset),		
	
	// from ex
	.pc_in(pc_ex),
	.iw_in(iw_ex),
	.wb_reg_in(wb_reg_out_ex),
	.wb_enable_in(wb_enable_out_ex),
	.alu_in(alu_out_ex),
	
	// to wb
	.pc_out(pc_mem),
	.iw_out(iw_mem),
	.alu_out(alu_out_mem),
	.wb_reg_out(wb_reg_out_mem),
	.wb_enable_out(wb_enable_out_mem),
	
	// data hazard: to id
	.df_mem_enable(mem_enable),
	.df_mem_reg(mem_reg),
	.df_mem_data(mem_data),
	
	// memory interface
	.memif_addr(memif_addr_RAM),
	.memif_rdata(memif_rdata_RAM),
	.memif_we(memif_we_RAM),
	.memif_be(memif_be_RAM),
	.memif_wdata(memif_wdata_RAM),

	// io interface
	.io_addr(io_addr_io),
	.io_rdata(io_rdata_io),
	.io_we(io_we_io),
	.io_be(io_be_io),
	.io_wdata(io_wdata_io),
	
	.wb_from_ex_mem(wb_lab8_ex_mem),	
	.wb_from_mem_wb(wb_lab8_mem_wb),	
	
	//rs2 Data from id
	.rs2_data_from_ex(rs2_data_going_mem),
	
	//to wb
	.memif_rdata_to_wb(memif_rdata_top),
	.io_rdata_to_wb(io_rdata_top),
	
	.control_wb(ctrl_mem_to_wb)
	
	);



	rv32_wb_top writeback(
	
	// system clock and synchronous reset
	.clk(clk),
	.reset(reset),
	
	// from mem
	.pc_in(pc_mem),
	.iw_in(iw_mem),
	.alu_in(alu_out_mem),
	.wb_reg_in(wb_reg_out_mem),
	.wb_enable_in(wb_enable_out_mem),
	
	// register interface
	.regif_wb_enable(wb_enable_out_wb),
	.regif_wb_reg(wb_reg_out_wb),
	.regif_wb_data(alu_out_wb),
	
	// data hazard: to id
	.df_wb_enable(wb_enable),
	.df_wb_reg(wb_reg),
	.df_wb_data(wb_data),
	
	.wb_from_mem_wb(wb_lab8_mem_wb),	
	.wb_from_wb_ex(wb_lab8_wb_ex),
	
	.memif_rdata_from_mem(memif_rdata_top),
	.io_rdata_from_mem(io_rdata_top),
	
	.control_wb(ctrl_mem_to_wb)

	);


   
endmodule







