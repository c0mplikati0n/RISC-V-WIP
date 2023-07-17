
module rv32_io_top(
	
	// system clock and synchronous reset
	input clk,
	input reset,
	
	// io interface
	input [31:2] io_addr,
	output [31:0] io_rdata,
	input io_we,
	input [3:0] io_be,
	input [31:0] io_wdata,
	
	// Button and LED signals
	input btn_free,
	output [7:0] led_out
);

	// Constants for I/O addresses
	localparam LED_addr = 32'h80000000; // Base address for LEDs
	localparam BTN_addr = 32'h80000004; // Base address for push button

	// WIP
	
endmodule



