//////////////////////////////////////////////////////////////////////////////
// Module Name : Game State
// Dependencies:
// Description : Determining the state of the game
//////////////////////////////////////////////////////////////////////////////
`include "res_params.vh"
`timescale 1ns / 1ps

module game_state (
    input wire clk,              // Game clock
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

// ----------------------------------------------------------------------------
// Defining game state parameters
// ----------------------------------------------------------------------------
    // Defining screen resolution parameters locally (from res_params.vh)
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

// ----------------------------------------------------------------------------
// Declare loop variables at module level
// ----------------------------------------------------------------------------
    integer i;
    integer i_move;
    integer i_collision;

// ----------------------------------------------------------------------------
// Initialise game
// ----------------------------------------------------------------------------
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
    end

// ----------------------------------------------------------------------------
// Update game state
// ----------------------------------------------------------------------------
    // Update direction on every clock cycle
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_dir <= DIR_RIGHT; // Default direction
        end else if (!stop) begin
            case (direction)
                DIR_UP:    if (current_dir != DIR_DOWN)  current_dir <= DIR_UP;
                DIR_DOWN:  if (current_dir != DIR_UP)    current_dir <= DIR_DOWN;
                DIR_LEFT:  if (current_dir != DIR_RIGHT) current_dir <= DIR_LEFT;
                DIR_RIGHT: if (current_dir != DIR_LEFT)  current_dir <= DIR_RIGHT;
            endcase
        end
    end

    // Snake movement and game logic on every clock cycle
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 12'd0;
            snake_len <= SNAKE_LENGTH_BEGIN;
            for (i_move = 0; i_move < SNAKE_LENGTH_BEGIN; i_move = i_move + 1) begin
                snake_x[i_move] <= SNAKE_BEGIN_X - i_move*HEAD_WIDTH;
                snake_y[i_move] <= SNAKE_BEGIN_Y;
            end
            food_x <= FOOD_BEGIN_X;
            food_y <= FOOD_BEGIN_Y;
            collision <= 1'b0;
        end else if (!stop) begin
            // Move body
            for (i_move = 1; i_move < SNAKE_LENGTH_MAX; i_move = i_move + 1) begin
                if (i_move < snake_len) begin
                    snake_x[i_move] <= snake_x[i_move-1];
                    snake_y[i_move] <= snake_y[i_move-1];
                end else begin
                    // Hold current position or set to default
                    snake_x[i_move] <= snake_x[i_move];
                    snake_y[i_move] <= snake_y[i_move];
                end
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
            // Reset collision status before checking
            collision <= collision;
            for (i_collision = 1; i_collision < SNAKE_LENGTH_MAX; i_collision = i_collision + 1) begin
                if (i_collision < snake_len && snake_x[0] == snake_x[i_collision] && snake_y[0] == snake_y[i_collision]) begin
                    collision <= 1'b1;
                end
            end

            // Check for food
            if (snake_x[0] == food_x && snake_y[0] == food_y) begin
                score <= score + 1;
                if (snake_len < SNAKE_LENGTH_MAX) begin
                    snake_x[snake_len] <= snake_x[snake_len-1];
                    snake_y[snake_len] <= snake_y[snake_len-1];
                    snake_len <= snake_len + 1;
                end

                // Place new food (simple pattern for now)
                food_x <= (food_x + 100) % (SCREEN_WIDTH - FOOD_WIDTH);
                food_y <= (food_y + 50) % (SCREEN_HEIGHT - FOOD_WIDTH);
            end

            // If collision, reset game
            if (collision) begin
                score <= 0;
                snake_len <= SNAKE_LENGTH_BEGIN;
                for (i_move = 0; i_move < SNAKE_LENGTH_BEGIN; i_move = i_move + 1) begin
                    snake_x[i_move] <= SNAKE_BEGIN_X - i_move*HEAD_WIDTH;
                    snake_y[i_move] <= SNAKE_BEGIN_Y;
                end
                food_x <= FOOD_BEGIN_X;
                food_y <= FOOD_BEGIN_Y;
                collision <= 1'b0;
            end
        end
    end

// ----------------------------------------------------------------------------
// Creating pixel maps from game state
// ----------------------------------------------------------------------------
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
                for (i_collision = 1; i_collision < SNAKE_LENGTH_MAX; i_collision = i_collision + 1) begin
                    if (i_collision < snake_len && col == snake_x[i_collision] && row == snake_y[i_collision]) begin
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
//////////////////////////////////////////////////////////////////////////////