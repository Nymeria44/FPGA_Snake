////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake Game Testbench
// Dependencies:
// Description : Testbench for top level module snake_game
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module intennal and external signals
// -----------------------------------------------------------------------------
module snake_game_TB;
    reg clk;
    reg rst_n;
    wire [7:0] line_data;
    wire [7:0] row;
    wire slow_clk;
    wire very_slow_clk;

// -----------------------------------------------------------------------------
// Instantiate the design under test (DUT)
// -----------------------------------------------------------------------------
    snake_game dut (
        .clk(clk),
        .rst_n(rst_n),
        .line_data(line_data),
        .row(row),
        .slow_clk(slow_clk),
        .very_slow_clk(very_slow_clk)
    );

// -----------------------------------------------------------------------------
// Testbench behavior
// -----------------------------------------------------------------------------
    always #10 clk = ~clk;  //50Mhz clock

    initial begin
        clk = 0;            // Initialise signals
        rst_n = 0;
        #100 rst_n = 1;     // Release reset after 100ns
        #50000000;          // Run the simulation for 50ms
        $stop;
    end

// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------
    initial begin
        $monitor("line data = %b", line_data);
    end
    
endmodule
