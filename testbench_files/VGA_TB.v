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
    reg rst_n;      // active-low reset

    // Outputs from snake_game
    wire [2:0] disp_RGB;
    wire hsync;
    wire vsync;

    // Instantiating top level module
    snake_game dut (
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .clk(clk),
        .rst_n(rst_n),
        .disp_RGB(disp_RGB),
        .hsync(hsync),
        .vsync(vsync)
    );

    // Generate a stable 50 MHz clock (20 ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk     = 0;
        rst_n   = 0;
        ps2_clk = 1;
        ps2_data= 1;

        // Allow some time for initial conditions
        #200;

        // Deassert reset
        rst_n = 1;

        // Run simulation for some time to observe behavior
        // 20 ms should allow multiple frames at 60 Hz (16.7 ms/frame)
        #20_000_000;

        $stop; // End simulation
    end

endmodule
////////////////////////////////////////////////////////////////////////////////