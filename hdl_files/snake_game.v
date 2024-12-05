////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake Game
// Dependencies:
// Description : Top level module for snake game
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module snake_game(
    input ps2_clk,                 // PS2 clock pin 10-16.7Khz
    input ps2_data,                // PS2 data pin 
    input clk,                     // 50Mhz FPGA clock
    input rst_n,                   // reset button
    output wire [2:0] disp_RGB,    // 3-bit VGA display colors
    output wire hsync,             // VGA horizontal sync signal
    output wire vsync              // VGA vertical sync signal
);

    // internal signals
    wire [188:0] x_list;               // 3bit x coordinates, 63 snake segments
    wire [188:0] y_list;               // 3bit y coordinate, 63 snake segments
    wire [5:0] length;                 // length of the snake
    wire [7:0] ps2_byte;               // 1byte hex key value
    wire slow_clk;                     // general clock
    wire game_clk;                     // game clock

// -----------------------------------------------------------------------------
// Clock signals for the game
// -----------------------------------------------------------------------------
    clock_divider slow_clock_divider(
        .clk_in(clk),                       // INPUT 50Mhz FPGA clock
        .reset(rst_n),                      // INPUT reset button   
        .ratio(32'd10_000),                 // INPUT dividing ratio
          .clk_out(slow_clk)                  // OUTPUT Frequency
    ); // 5KHz processing clock

    clock_divider very_slow_clock_divider(
        .clk_in(clk),                       // INPUT 50Mhz FPGA clock
        .reset(rst_n),                      // INPUT reset button
        .ratio(32'd10_000_000),             // INPUT dividing ratio
          .clk_out(game_clk)                  // OUTPUT Frequency
    ); // 5Hz game clock
	 
//    clock_divider VGA_clk(
//        .clk_in(clk),                       // INPUT 50Mhz FPGA clock
//        .reset(rst_n),                      // INPUT reset button
//        .ratio(32'd5),                      // INPUT dividing ratio for 40MHz
//        .clk_out(clk_40MHz)                 // OUTPUT 40 MHz clock
//    ); // 40 MHz clock

// -----------------------------------------------------------------------------
// Player input
// -----------------------------------------------------------------------------
    //PS2 keyboard input
    ps2scan	ps2scan(.clk(clk),  		        // INPUT 50Mhz FPGA clock
                    .rst_n(rst_n),				// INPUT reset button
                    .ps2k_clk(ps2_clk),         // INPUT PS2 clk pin 10-16.7Khz
                    .ps2k_data(ps2_data),       // INPUT PS2 data pin     
                      .ps2_byte(ps2_byte),        // OUTPUT 1byte hex key value
                      .ps2_state(ps2_state)       // OUTPUT keypress #unused
    );

// -----------------------------------------------------------------------------
// Game logic and display processing
// -----------------------------------------------------------------------------
    // check position of snake and encode 3-bit x,y coordinates into 189bit data
    coordinate_update coord_update (
        .clk(game_clk),      // INPUT 5Hz game clock
        .rst_n(rst_n),            // INPUT reset button
        .ps2ascii(ps2_byte),      // INPUT raw keyboard input
          .x_list(x_list),          // OUTPUT 189bit x coordinates
          .y_list(y_list),          // OUTPUT 189bit y coordinates
          .length(length)           // OUTPUT length of snake
    );

    // Slice 189bit data to 3bit coordinates, output 64bits for led matrix
    snake snake (
        .clk(slow_clk),           // INPUT 5KHz 
        .slow_clk(game_clk),      // INPUT 5Hz game clock
        .rst_n(rst_n),            // INPUT reset button
        .x_list(x_list),          // INPUT 189bit x coordinates
        .y_list(y_list),          // INPUT 189bit y coordinates
        .length(length),          // INPUT length of snake
          .disp_data(disp_data)     // OUTPUT 8byte 8x8 LED matrix data
    );

// -----------------------------------------------------------------------------
// VGA display
// -----------------------------------------------------------------------------
    wire [1:0] game_switch;       // Switch to control display mode
    // reg [2:0] rgb_output;         // RGB output signal for VGA

    VGA vga_inst (
        .clock(clk),              // INPUT Clock
        .switch(game_switch),     // INPUT Keep this simple for now
          .disp_RGB(disp_RGB),      // OUTPUT RGB VGA pins
          .hsync(hsync),            // OUTPUT Horizontal sync pin
          .vsync(vsync)             // OUTPUT Vertical sync pin
    ); 

//    // Generate a black or white screen (Basic VGA output)
//    always @(posedge clk) begin
//            rgb_output <= 3'b111;         // Set to white
//    end
//
//    // Keep game_switch constant (e.g., 2'b00)
//    assign game_switch = 2'b00;         // Always show horizontal data    

endmodule
//////////////////////////////////////////////////////////////////////////////