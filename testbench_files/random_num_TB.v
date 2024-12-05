////////////////////////////////////////////////////////////////////////////////
// Module Name : Random Number Generator Testbench
// Dependencies:
// Description : Testbench for the random number generator module
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Module intennal and external signals
// -----------------------------------------------------------------------------
module random_num_TB;
    reg clk;             // Clock signal
    reg reset;           // Reset signal
    wire [5:0] rand_num; // Random number output from the DUT (Device Under Test)

// -----------------------------------------------------------------------------
// Instantiate the design under test (DUT)
// -----------------------------------------------------------------------------
    // Instantiate the random number generator module
    random_num uut (
        .clk(clk),
        .reset(reset),
        .rand_num(rand_num)
    );

// -----------------------------------------------------------------------------
// Testbench behavior
// -----------------------------------------------------------------------------
    // Clock generation: 10ns period (50MHz frequency)
    always #5 clk = ~clk;  // 50MHz clock

    initial begin
        clk = 0;        // Initialise signals
        reset = 0; 
        #10 reset = 1;  // Release reset after 10ns
        #200 $stop;     // Stop the simulation after 200ns
    end

// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------
    initial begin
        $monitor("Time: %0dns, Random Number: %d", $time, rand_num);
    end

endmodule