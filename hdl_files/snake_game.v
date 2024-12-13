////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake Game
// Dependencies:
// Description : Top level module for snake game
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module snake_game(
    input clk,                     // 50MHz FPGA clock
    input rst_n,                   // reset button
    input S1,                      // Left button
    input S2,                      // Up button
    input S3,                      // Down button
    input S4,                      // Right button
    output wire [2:0] disp_RGB,    // 3-bit VGA display colors
    output wire hsync,             // VGA horizontal sync signal
    output wire vsync,              // VGA vertical sync signal
    output wire vga_clk            // Exposing VGA clock for testbenching
);

// -----------------------------------------------------------------------------
// Assigning internal wires/parameters
// -----------------------------------------------------------------------------
    // Clock/VGA internal signals
    wire game_clk;                 // game clock (5Mhz)
    wire pll_locked;
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire [2:0] data;
    wire [1:0] game_switch;        // Switch to control display mode

    assign game_switch = 2'b10;    // Always show horizontal data

    // Game State internal signals
    wire is_body;
    wire is_food;
    wire is_head;
    wire [11:0] score;

    // Direction constants (for movement)
    localparam DIR_UP    = 2'b00;
    localparam DIR_RIGHT = 2'b01;
    localparam DIR_DOWN  = 2'b10;
    localparam DIR_LEFT  = 2'b11;

    reg [1:0] current_direction;

// -----------------------------------------------------------------------------
// Clock signals
// -----------------------------------------------------------------------------
	 // 40MHz VGA clock using PLL
	 PLL_IP pll_inst (
		  .inclk0(clk),
		  .c0(vga_clk),
		  .locked(pll_locked)
	 );

	 // 5MHZ game clock
    clock_divider very_slow_clock_divider(
        .clk_in(clk),
        .reset(rst_n),
        .ratio(32'd10_000_000),            // dividing ratio
        .clk_out(game_clk)
    );
	 
// -----------------------------------------------------------------------------
// Player input
// -----------------------------------------------------------------------------
    // Setting current direction based off FPGA keys
    // Note: conditions for legal movement handled within game_state
    // Note: controls use vim style (h,j,l,k keybinds) for movement
	 always @(*) begin
        if (!S1) begin
            current_direction = DIR_LEFT;
        end else if (!S2) begin
            current_direction = DIR_UP;
        end else if (!S3) begin
            current_direction = DIR_DOWN;
        end else if (!S4) begin
            current_direction = DIR_RIGHT;
        end
    end

// -----------------------------------------------------------------------------
// Game logic and display processing
// -----------------------------------------------------------------------------
    game_state game_state_inst (
        .clk(game_clk),
        .direction(current_direction),
        .stop(1'b0),
        .reset(!rst_n),
        .row({6'b0, vcount}),
        .col({6'b0, hcount}),
        .is_body(is_body),
        .is_food(is_food),
        .is_head(is_head),
        .score(score)
    );
	 
// -----------------------------------------------------------------------------
// VGA display
// -----------------------------------------------------------------------------
// Note: Comment out snake_display to use checkerboard_pattern and vice versa
    // Init VGA
    VGA vga_inst (
        .clock(vga_clk),
        .data(data),
        .hcount(hcount),
        .vcount(vcount),
        .disp_RGB(disp_RGB),
        .hsync(hsync),
        .vsync(vsync)
    );
	 
	 // Converts snake/food coordinates into RBG data
	 snake_display visual_data_inst (
	     .clock(vga_clk),
		  .switch(game_switch),
	     .is_body(is_body),
	     .is_food(is_food),
	     .is_head(is_head),
	     .data(data)
    );

	 
	 // Generate checkerboard pattern
    checkerboard_pattern visual_data_inst (
        .clock(vga_clk),
        .switch(game_switch),
        .hcount(hcount),
        .vcount(vcount),
        .data(data)
    );
	 

endmodule
////////////////////////////////////////////////////////////////////////////////
