////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake Game
// Dependencies:
// Description : Top level module for snake game
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module snake_game(
    input clk,                     // 50MHz FPGA clock
    input rst_n,                   // reset button
	 input S1,                      // Up button
    input S2,                      // Right button
    input S3,                      // Down button
    input S4,                      // Left button
    output wire [2:0] disp_RGB,    // 3-bit VGA display colors
    output wire hsync,             // VGA horizontal sync signal
    output wire vsync,              // VGA vertical sync signal
	 output wire vga_clk            // Exposing VGA clock for testbenching
);

// -----------------------------------------------------------------------------
// Assigning internal wires
// -----------------------------------------------------------------------------
    // Clock / VGA internal signals
    wire slow_clk;                 // general clock
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

// -----------------------------------------------------------------------------
// Clock signals
// -----------------------------------------------------------------------------
	 // 40MHz VGA clock using PLL
	 PLL_IP pll_inst (
		  .inclk0(clk),
		  .c0(vga_clk),
		  .locked(pll_locked)
	 );

	 // 5MHZ clock
    clock_divider very_slow_clock_divider(
        .clk_in(clk),
        .reset(rst_n),
        .ratio(32'd10_000_000),            // dividing ratio
        .clk_out(game_clk)
    );

// -----------------------------------------------------------------------------
// Player input
// -----------------------------------------------------------------------------
    // Direction constants:
    localparam DIR_UP    = 2'b00;
    localparam DIR_RIGHT = 2'b01;
    localparam DIR_DOWN  = 2'b10;
    localparam DIR_LEFT  = 2'b11;
    
	 reg [1:0] current_direction, next_direction;

    always @(*) begin
        // Start by assuming no change in direction
        next_direction = current_direction;

        // Check each button. Priority can be set by order; first match wins.
        // Ensure we are not reversing direction.
        if (!S1 && current_direction != DIR_DOWN) begin
            next_direction = DIR_UP;
        end else if (!S2 && current_direction != DIR_LEFT) begin
            next_direction = DIR_RIGHT;
        end else if (!S3 && current_direction != DIR_UP) begin
            next_direction = DIR_DOWN;
        end else if (!S4 && current_direction != DIR_RIGHT) begin
            next_direction = DIR_LEFT;
        end
    end

    // Update direction on the rising edge of the game clock or on reset
    always @(posedge game_clk or negedge rst_n) begin
        if (!rst_n) begin
            // Set initial direction to RIGHT
            current_direction <= DIR_RIGHT;
        end else begin
            current_direction <= next_direction;
        end
    end


// -----------------------------------------------------------------------------
// Game logic and display processing
// -----------------------------------------------------------------------------
    // Hard-code direction to right as play input missing
	 // Commented out as it puts project over element limit
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
    // Initalise VGA
    VGA vga_inst (
        .clock(vga_clk),
        .data(data),
        .hcount(hcount),
        .vcount(vcount),
        .disp_RGB(disp_RGB),
        .hsync(hsync),
        .vsync(vsync)
    );
	 
	 // Generate checkerboard pattern
//    checkerboard_pattern visual_data_inst (
//        .clock(vga_clk),
//        .switch(game_switch),
//        .hcount(hcount),
//        .vcount(vcount),
//        .data(data)
//    );
	 
	 snake_display visual_data_inst (
	     .clock(vga_clk),
		  .switch(game_switch),
	     .is_body(is_body),
	     .is_food(is_food),
	     .is_head(is_head),
	     .data(data)
    );

endmodule
////////////////////////////////////////////////////////////////////////////////