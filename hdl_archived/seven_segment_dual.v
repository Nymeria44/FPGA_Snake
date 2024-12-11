////////////////////////////////////////////////////////////////////////////////
// Module Name : Seven Segment Dual Display
// Dependencies:
// Description : Converts 1byte ASCII hex key value and multiplexes between two
//               7-segment displays. # need to edit to use clock divider module
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module seven_segment_dual(
    input clk,            // clock
    input rst_n,          // reset signal 
    input [7:0] ps2_byte, // 1byte ASCII hex key value
    output reg [1:0] dig, // Digit select (DIG1 and DIG2)
    output reg [7:0] seg  // Segment control (SEG0 to SEG7)
);
    reg current_digit;        // digit active 0 for DIG1, 1 for DIG2
    reg [3:0] current_value;  // 4-bit value to display on the active digit

// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
    // Multiplexing logic between DIG1 and DIG2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_digit <= 0;
        end else begin
            current_digit <= ~current_digit;  // Toggle between 0 and 1
        end
    end

    // Select which digit to display based on the current_digit value
    always @(*) begin
        case (current_digit)
            1'b0: begin
                dig = 2'b10;  // Activate DIG1 (other digit off)
                current_value = ps2_byte[7:4];  // Upper 4 bits of ps2_byte
            end
            1'b1: begin
                dig = 2'b01;  // Activate DIG2
                current_value = ps2_byte[3:0];  // Lower 4 bits of ps2_byte
            end
        endcase
    end

    // 7-segment decoder: convert the 4-bit value to segment control signals
    always @(*) begin
        case (current_value)
            4'h0: seg = 8'b11000000;  // Display "0"
            4'h1: seg = 8'b11111001;  // Display "1"
            4'h2: seg = 8'b10100100;  // Display "2"
            4'h3: seg = 8'b10110000;  // Display "3"
            4'h4: seg = 8'b10011001;  // Display "4"
            4'h5: seg = 8'b10010010;  // Display "5"
            4'h6: seg = 8'b10000010;  // Display "6"
            4'h7: seg = 8'b11111000;  // Display "7"
            4'h8: seg = 8'b10000000;  // Display "8"
            4'h9: seg = 8'b10010000;  // Display "9"
            4'hA: seg = 8'b10001000;  // Display "A"
            4'hB: seg = 8'b10000011;  // Display "b"
            4'hC: seg = 8'b11000110;  // Display "C"
            4'hD: seg = 8'b10100001;  // Display "d"
            4'hE: seg = 8'b10000110;  // Display "E"
            4'hF: seg = 8'b10001110;  // Display "F"
            default: seg = 8'b11111111;  // Blank
        endcase
    end

endmodule
