////////////////////////////////////////////////////////////////////////////////
// Module Name : Edge Synchroniser
// Dependencies:
// Description : Synchronises two different clock domains.      
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module edge_synch(
    input fast_clk,          // Faster clock input
    input slow_clk,          // Slower clock input
    input rst_n,             // Reset input
    output wire pos_synch,    // positive edge synchronised output
    output wire neg_synch    // negative edge synchronised output
);
    reg [2:0] clk_register;  // clock register
    reg sync_clk_1;          // Synchronised clock 1
    reg sync_clk_2;          // Synchronised clock 2

    assign pos_synch = ~clk_register[2] & clk_register[1]; //output
    assign neg_synch = clk_register[2] & ~clk_register[1]; //output

// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
    always @ (posedge fast_clk or negedge rst_n) begin
	    if(!rst_n) begin
            clk_register <= 3'b0;               // Reset the register
        end else begin
            clk_register[0] <= slow_clk;
            clk_register[1] <= clk_register[0]; // new_value
            clk_register[2] <= clk_register[1]; // old value
        end
    end
    
endmodule