`timescale 1ns / 1ps

module score(
    input wire [11:0] score,
    input wire [15:0] row,
    input wire [15:0] col,
    output reg is_score
);
    always @(*) begin
        // Display score region in a small box at top-left corner
        if (col < 16'd100 && row < 16'd50)
            is_score = 1'b1;
        else
            is_score = 1'b0;
    end
endmodule
