////////////////////////////////////////////////////////////////////////////////
// Module Name : Game State
// Dependencies:
// Description : Determining the statee of the game
////////////////////////////////////////////////////////////////////////////////
`include "res_params.vh"
`timescale 1ns / 1ps

module game_logic (
    input wire clk,
    input wire [1:0] direction,  // 00-up, 01-right, 10-down, 11-left
    input wire stop,
    input wire reset,

    input wire en,                // enable signal for pixel queries
    input wire [15:0] row,        // current pixel row
    input wire [15:0] col,        // current pixel column

    output reg is_body,
    output reg is_food,
    output reg is_head,
    output reg [11:0] score
);

    // Parameters (using defines from res_params.vh)
    localparam SCREEN_WIDTH = `SCREEN_WIDTH;
    localparam SCREEN_HEIGHT = `SCREEN_HEIGHT;
    localparam FOOD_WIDTH = `FOOD_WIDTH;
    localparam HEAD_WIDTH = `HEAD_WIDTH;
    localparam SNAKE_BEGIN_X = `SNAKE_BEGIN_X;
    localparam SNAKE_BEGIN_Y = `SNAKE_BEGIN_Y;
    localparam SNAKE_LENGTH_BEGIN = `SNAKE_LENGTH_BEGIN;
    localparam SNAKE_LENGTH_MAX = `SNAKE_LENGTH_MAX;
    localparam FOOD_BEGIN_X = `FOOD_BEGIN_X;
    localparam FOOD_BEGIN_Y = `FOOD_BEGIN_Y;

    // Internal parameters and signals
    localparam DIR_UP    = 2'b00;
    localparam DIR_RIGHT = 2'b01;
    localparam DIR_DOWN  = 2'b10;
    localparam DIR_LEFT  = 2'b11;

    // Representation of snake as an array of segments (x,y)
    reg [15:0] snake_x[0:SNAKE_LENGTH_MAX-1];
    reg [15:0] snake_y[0:SNAKE_LENGTH_MAX-1];
    reg [5:0]  snake_len;

    reg [1:0] current_dir;
    reg collision;
    reg [15:0] food_x;
    reg [15:0] food_y;

    // Simple game tick divider for movement (adjust for game speed)
    reg [31:0] tick_count;
    localparam TICK_MAX = 2000000; // Adjust game speed as needed

    wire game_tick = (tick_count == TICK_MAX);

    // Initialize
    integer i;
    initial begin
        score = 12'd0;
        snake_len = SNAKE_LENGTH_BEGIN;
        for (i = 0; i < SNAKE_LENGTH_BEGIN; i = i + 1) begin
            snake_x[i] = SNAKE_BEGIN_X - i*HEAD_WIDTH;
            snake_y[i] = SNAKE_BEGIN_Y;
        end
        current_dir = DIR_RIGHT;
        collision = 1'b0;
        food_x = FOOD_BEGIN_X;
        food_y = FOOD_BEGIN_Y;
        tick_count = 32'd0;
    end

    // Game tick generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_count <= 32'd0;
        end else begin
            if (!stop) begin
                if (tick_count < TICK_MAX) begin
                    tick_count <= tick_count + 32'd1;
                end else begin
                    tick_count <= 32'd0;
                end
            end
        end
    end

    // Update direction if game tick occurs
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_dir <= DIR_RIGHT;
        end else if (game_tick && !stop) begin
            current_dir <= direction;
        end
    end

    // Snake movement and logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 12'd0;
            snake_len <= SNAKE_LENGTH_BEGIN;
            for (i = 0; i < SNAKE_LENGTH_BEGIN; i = i + 1) begin
                snake_x[i] <= SNAKE_BEGIN_X - i*HEAD_WIDTH;
                snake_y[i] <= SNAKE_BEGIN_Y;
            end
            food_x <= FOOD_BEGIN_X;
            food_y <= FOOD_BEGIN_Y;
            collision <= 1'b0;
        end else if (game_tick && !stop) begin
            // Move body
            for (i = snake_len-1; i > 0; i = i - 1) begin
                snake_x[i] <= snake_x[i-1];
                snake_y[i] <= snake_y[i-1];
            end
            // Move head
            case (current_dir)
                DIR_UP:    snake_y[0] <= snake_y[0] - HEAD_WIDTH;
                DIR_DOWN:  snake_y[0] <= snake_y[0] + HEAD_WIDTH;
                DIR_LEFT:  snake_x[0] <= snake_x[0] - HEAD_WIDTH;
                DIR_RIGHT: snake_x[0] <= snake_x[0] + HEAD_WIDTH;
            endcase

            // Check for wall collision
            if (snake_x[0] < 0 || snake_x[0] >= SCREEN_WIDTH || snake_y[0] < 0 || snake_y[0] >= SCREEN_HEIGHT) begin
                collision <= 1'b1;
            end

            // Check for self-collision
            for (i = 1; i < snake_len; i = i + 1) begin
                if (snake_x[0] == snake_x[i] && snake_y[0] == snake_y[i]) begin
                    collision <= 1'b1;
                end
            end

            // Check for food
            if (snake_x[0] == food_x && snake_y[0] == food_y) begin
                score <= score + 1;
                if (snake_len < SNAKE_LENGTH_MAX) begin
                    snake_len <= snake_len + 1;
                    snake_x[snake_len-1] <= snake_x[snake_len-2];
                    snake_y[snake_len-1] <= snake_y[snake_len-2];
                end
                // Place new food (simple pattern for now)
                food_x <= (food_x + 100) % (SCREEN_WIDTH - FOOD_WIDTH);
                food_y <= (food_y + 50) % (SCREEN_HEIGHT - FOOD_WIDTH);
            end

            // If collision, reset game
            if (collision) begin
                score <= 0;
                snake_len <= SNAKE_LENGTH_BEGIN;
                for (i = 0; i < SNAKE_LENGTH_BEGIN; i = i + 1) begin
                    snake_x[i] <= SNAKE_BEGIN_X - i*HEAD_WIDTH;
                    snake_y[i] <= SNAKE_BEGIN_Y;
                end
                food_x <= FOOD_BEGIN_X;
                food_y <= FOOD_BEGIN_Y;
                collision <= 1'b0;
            end
        end
    end

    // Pixel-level detection
    // Check if the current pixel corresponds to snake's body, head or food
    always @(*) begin
        is_body = 1'b0;
        is_head = 1'b0;
        is_food = 1'b0;
        if (en) begin
            // Check head
            if (col == snake_x[0] && row == snake_y[0]) begin
                is_head = 1'b1;
            end else begin
                // Check body
                for (i = 1; i < snake_len; i = i + 1) begin
                    if (col == snake_x[i] && row == snake_y[i]) begin
                        is_body = 1'b1;
                    end
                end
            end
            // Check food
            if (col == food_x && row == food_y) begin
                is_food = 1'b1;
            end
        end
    end

endmodule