`timescale 1ns / 1ps

module snake_draw (
    input  wire is_body,
    input  wire is_food,
    input  wire is_head,
    input  wire is_score,
    output reg red,
    output reg green,
    output reg blue
);

always @(*) begin
    // Default background color: black
    red   = 1'b0;
    green = 1'b0;
    blue  = 1'b0;

    if (is_head) begin
        // Head: Purple (red=1, green=0, blue=1)
        red   = 1'b1;
        green = 1'b0;
        blue  = 1'b1;
    end else if (is_body) begin
        // Body: Green (red=0, green=1, blue=0)
        red   = 1'b0;
        green = 1'b1;
        blue  = 1'b0;
    end else if (is_food) begin
        // Food: Red (red=1, green=0, blue=0)
        red   = 1'b1;
        green = 1'b0;
        blue  = 1'b0;
    end else if (is_score) begin
        // Score: White (red=1, green=1, blue=1)
        red   = 1'b1;
        green = 1'b1;
        blue  = 1'b1;
    end
end

endmodule
