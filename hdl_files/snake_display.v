////////////////////////////////////////////////////////////////////////////////
// Module Name : snake_display
// Description : Converts the snake game state (head, body, food) into RGB output
//
// Color scheme:
//   - Head: Red     (100)
//   - Food: Green   (010)
//   - Body: Blue    (001)
//   - Background: Black   (000)
////////////////////////////////////////////////////////////////////////////////
module snake_display(
    input  wire        clock,
    input  wire [9:0]  hcount,
    input  wire [9:0]  vcount,
    input  wire [1:0]  switch,
    input  wire        is_body,  
    input  wire        is_food,  
    input  wire        is_head,  
    output reg  [2:0]  data
);

    always @(posedge clock) begin
        case (switch)
            2'd0: begin
                // Mode 0: All white screen
                data <= 3'b111;
            end

            2'd1: begin
                // Mode 1: All black screen
                data <= 3'b000;
            end

            2'd2: begin
                // Mode 2: Draw white rectangle on black background
                if (is_head)      data <= 3'b100; // head = red
                else if (is_food) data <= 3'b010; // food = green
                else if (is_body) data <= 3'b001; // body = blue
                else              data <= 3'b000; // background = black
            end

            default: begin
                // Default case: All black
                data <= 3'b000;
            end
        endcase
    end

endmodule
////////////////////////////////////////////////////////////////////////////////