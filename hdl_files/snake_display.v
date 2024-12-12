////////////////////////////////////////////////////////////////////////////////
// Module Name : snake_display
// Description : Converts the snake game state (head, body, food) into RGB output
//
// Color scheme:
//   - Head: Red     (100)
//   - Food: Green   (010)
//   - Body: Blue    (001)
//   - Else: Black   (000)
////////////////////////////////////////////////////////////////////////////////
module snake_display(
    input wire clock,
    input wire is_body,
    input wire is_food,
    input wire is_head,
    output reg [2:0] data
);

    always @(posedge clock) begin
        if (is_head) begin
            data <= 3'b100; // Red
        end else if (is_food) begin
            data <= 3'b010; // Green
        end else if (is_body) begin
            data <= 3'b001; // Blue
        end else begin
            data <= 3'b000; // Black
        end
    end

endmodule
////////////////////////////////////////////////////////////////////////////////
