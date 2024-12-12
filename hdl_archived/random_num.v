////////////////////////////////////////////////////////////////////////////////
// Module Name : Random Number Generator
// Dependencies:
// Description : Generates random number for food location
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module random_num(
    input clk,         // Clock input
    input reset,       // Reset input
    output [5:0] rand_num // Random number output (values 0 to 63)
);
    reg [5:0] lfsr;
    wire feedback; 
// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
    assign feedback = lfsr[5] ^ lfsr[4];     // XORing the bits to get feedback
    assign rand_num = lfsr;                  // Output the random number

    // Sequential logic to update the LFSR on each clock cycle
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            lfsr <= 6'b1;                  // Initialize with non-zero value
        end else begin
            lfsr <= {lfsr[4:0], feedback}; // Shift left and insert feedback
        end
    end  

endmodule