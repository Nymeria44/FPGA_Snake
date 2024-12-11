////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake Game
// Dependencies:
// Description : Top level module for snake game
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module snake_game(
    input ps2_clk,                 // PS2 clock pin 10-16.7Khz
    input ps2_data,                // PS2 data pin 
    input clk,                     // 50MHz FPGA clock
    input rst_n,                   // reset button
    output wire [2:0] disp_RGB,    // 3-bit VGA display colors
    output wire hsync,             // VGA horizontal sync signal
    output wire vsync,              // VGA vertical sync signal
	 output wire vga_clk            // Exposing VGA clock for testbenching
);

    // Internal signals
    wire [188:0] x_list;           // 3bit x coordinates, 63 snake segments
    wire [188:0] y_list;           // 3bit y coordinate, 63 snake segments
    wire [5:0] length;             // length of the snake
    wire [7:0] ps2_byte;           // 1byte hex key value
    wire slow_clk;                 // general clock
    wire game_clk;                 // game clock
    wire [1:0] game_switch;        // Switch to control display mode
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire [2:0] data;
    // wire vga_clk;					  // Commented out while clock is exposed for TB

    assign game_switch = 2'b10;    // Always show horizontal data

	 // -----------------------------------------------------------------------------
	 // Clock signals for the game
	 // -----------------------------------------------------------------------------
	// Generate 40MHz VGA clock using PLL
	PLL_IP pll_inst (
		 .inclk0(clk),      // 50 MHz input clock
		 .c0(vga_clk),      // 40 MHz output clock
		 .locked(pll_locked) // PLL locked signal
	);

    // Clock dividers for game logic
    clock_divider slow_clock_divider(
        .clk_in(clk),                      // INPUT 50MHz FPGA clock
        .reset(rst_n),                     // INPUT reset button   
        .ratio(32'd10_000),                // INPUT dividing ratio
        .clk_out(slow_clk)                 // OUTPUT 5KHz clock
    );

    clock_divider very_slow_clock_divider(
        .clk_in(clk),                      // INPUT 50MHz FPGA clock
        .reset(rst_n),                     // INPUT reset button
        .ratio(32'd10_000_000),            // INPUT dividing ratio
        .clk_out(game_clk)                 // OUTPUT 5Hz clock
    );

// -----------------------------------------------------------------------------
// Player input
// -----------------------------------------------------------------------------
    // PS2 keyboard input
    ps2scan ps2scan(
        .clk(clk),                         // INPUT 50MHz FPGA clock
        .rst_n(rst_n),                     // INPUT reset button
        .ps2k_clk(ps2_clk),                // INPUT PS2 clk pin 10-16.7KHz
        .ps2k_data(ps2_data),              // INPUT PS2 data pin     
        .ps2_byte(ps2_byte),               // OUTPUT 1-byte hex key value
        .ps2_state(ps2_state)              // OUTPUT keypress #unused
    );
	 
// -----------------------------------------------------------------------------
// Game logic and display processing
// -----------------------------------------------------------------------------
    // game_state game_state_inst (
	 //
	 // );

// -----------------------------------------------------------------------------
// VGA display
// -----------------------------------------------------------------------------
    // Generate checkerboard pattern
    checkerboard_pattern visual_data_inst (
        .clock(vga_clk),
        .switch(game_switch),
        .hcount(hcount),
        .vcount(vcount),
        .data(data)
    );

    // Instantiate VGA
    VGA vga_inst (
        .clock(vga_clk),
        .data(data),
        .hcount(hcount),
        .vcount(vcount),
        .disp_RGB(disp_RGB),
        .hsync(hsync),
        .vsync(vsync)
    ); 

endmodule
////////////////////////////////////////////////////////////////////////////////