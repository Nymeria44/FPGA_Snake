////////////////////////////////////////////////////////////////////////////////
// Module Name : VGA_TB
// Description : Testbench to verify the functionality of the VGA output
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module VGA_TB;

    // Inputs to snake_game
    reg ps2_clk;
    reg ps2_data;
    reg clk;        // 50MHz clock input
    reg rst_n;

    // Outputs from snake_game
    wire [2:0] disp_RGB;
    wire hsync;
    wire vsync;
	 wire vga_clk;

    // Loading top-level module
    snake_game dut (
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .clk(clk),
        .rst_n(rst_n),
        .disp_RGB(disp_RGB),
        .hsync(hsync),
        .vsync(vsync),
		  .vga_clk(vga_clk)
    );

    // Generate a stable 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialise signals
        clk     = 0;
        rst_n   = 0;
        ps2_clk = 1;
        ps2_data= 1;

        // Allow some time for initial conditions
        #200;

        // Deassert reset
        rst_n = 1;

        // Setting simulation time
		  // As it takes 16.7 ms/frame, allow 35ms for two frame ticks
        #35_000_000;

        $stop; // End simulation
    end

endmodule
////////////////////////////////////////////////////////////////////////////////