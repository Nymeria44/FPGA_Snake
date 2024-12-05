////////////////////////////////////////////////////////////////////////////////
// Module Name : Food
// Dependencies:
// Description : Places food in a random location on the 8x8 LED matrix
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module food(
    input clk,         // Clock input
    input reset,       // Reset input
    input [15:0] temp_data,
    output [15:0] temp_data_out,
    output [5:0] food_location
)

    reg [5:0] zero_count = 6'b0;
    reg [5:0] count_max = 6'b5;
    reg [5:0] count = 6'b0;
    reg [63:0] temp_data_out;
    reg make_food = 1'b0;

    always @ (posedge clk or negedge reset) begin
        if (!reset) begin
            count <= 6'b0;
            zero_count <= 6'b0;
        end
        else if (!make_food) begin
            count <= count + 1
            if (temp_data[count] == 8'b0) begin
                zero_count <= zero_count + 6'b1;
                if (zero_count == count_max) begin
                    make_food <= 1'b1;
                end
            end
        end else begin
            temp_data_out <= temp_data | (64'b1 << zero count)

        end
    end
endmodule