////////////////////////////////////////////////////////////////////////////////
// Module Name : PS2 Keyboard
// Dependencies:
// Description : This is a top level module which gets PS2 keyboard data and
//               displays it on the 7-segment display
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module ps2_key(
	input clk,						// clock pin
	input rst_n,					// reset pin
	input ps2_clk,					// PS2 clock pin 10-16.7Khz
	input ps2_data,				    // PS2 data pin
	output [1:0] dig, 				// Digit select (DIG1 to DIG4)
	output [7:0] seg  				// Segment control (SEG0 to SEG7)
);

// internal signals
wire[7:0] ps2_byte; 		    // 1byte hex key value	
wire ps2_state; 	            // Button status flag bit
wire slow_clk;
// -----------------------------------------------------------------------------
// Modules for keyboard scanning and 7-segment display
// -----------------------------------------------------------------------------
clock_divider slow_clock_divider(.clk_in(clk), 
								 .clk_out(slow_clk),
								 .reset(rst_n),
								 .ratio(32'd10_000)
); //5Khz signal


ps2scan	ps2scan(.clk(clk),  		  
				.rst_n(rst_n),				
				.ps2k_clk(ps2_clk),
				.ps2k_data(ps2_data),
				.ps2_byte(ps2_byte),
				.ps2_state(ps2_state)
);

seven_segment_dual	seven_segment_dual(.clk(slow_clk),
									   .ps2_byte(ps2_byte),
									   .dig(dig),
									   .seg(seg),
									   .rst_n(rst_n)
);
endmodule

