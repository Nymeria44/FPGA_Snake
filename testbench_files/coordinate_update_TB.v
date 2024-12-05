////////////////////////////////////////////////////////////////////////////////
// Module Name : Coordinate Update Testbench
// Dependencies:
// Description : Tests the coordinate update module
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module intennal and external signals
// -----------------------------------------------------------------------------
module coordinate_update_TB;
    reg clk;
    reg rst_n;
    reg [7:0] ps2ascii;

// -----------------------------------------------------------------------------
// Instantiate the design under test (DUT)
// -----------------------------------------------------------------------------
    coordinate_update DUT (
        .clk(clk),
        .rst_n(rst_n),
        .ps2ascii(ps2ascii)
    );

// -----------------------------------------------------------------------------
// Testbench behavior
// -----------------------------------------------------------------------------
    always #125_000_000 clk = ~clk;     // 4Hz game clock

    initial begin
        clk = 0;                        // Initialize signals
        rst_n = 0;
        ps2ascii = 8'b0;

        #100 rst_n = 1;                 // Release reset after 100ns
        #500_000_000 ps2ascii = 8'h57;  // 2 clock cycles press 'W'
        #500_000_000 ps2ascii = 8'h41;  // 2 clock cycles press 'A'
        #500_000_000 ps2ascii = 8'h53;  // 2 clock cycles press 'S'
        #500_000_000 ps2ascii = 8'h44;  // 2 clock cycles press 'D'
       $stop; 
    end

// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------

endmodule
