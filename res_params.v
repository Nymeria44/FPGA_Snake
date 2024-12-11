////////////////////////////////////////////////////////////////////////////////
// Module Name : Resolution Parameters
// Dependencies:
// Description : Parameters which define the resolution of the game
////////////////////////////////////////////////////////////////////////////////
module res_params;
    // VGA timing parameters for resolution @ 800x600 @ 60Hz
    parameter SCREEN_WIDTH = 800;  // Horizontal active pixels (h_active)
    parameter SCREEN_HEIGHT = 600; // Vertical active pixels (v_active)

    // VGA timing parameters
    parameter h_active = SCREEN_WIDTH;  // Active horizontal pixels
    parameter h_fp = 40;                // Horizontal front porch
    parameter h_sync = 128;             // Horizontal sync width
    parameter h_bp = 88;                // Horizontal back porch
    parameter h_total = h_active + h_fp + h_sync + h_bp; // Total horizontal pixels

    parameter v_active = SCREEN_HEIGHT; // Active vertical pixels
    parameter v_fp = 1;                 // Vertical front porch
    parameter v_sync = 4;               // Vertical sync width
    parameter v_bp = 23;                // Vertical back porch
    parameter v_total = v_active + v_fp + v_sync + v_bp; // Total vertical lines

    // Game-specific parameters
    parameter FOOD_WIDTH = 16;
    parameter HEAD_WIDTH = 16;
    parameter SNAKE_BEGIN_X = SCREEN_WIDTH / 3; // Start snake at 1/3rd width
    parameter SNAKE_BEGIN_Y = SCREEN_HEIGHT / 2; // Start snake at half height
    parameter SNAKE_LENGTH_BEGIN = 4;
    parameter SNAKE_LENGTH_MAX = 50;
    parameter FOOD_BEGIN_X = SCREEN_WIDTH * 3 / 4; // Place food near 3/4th width
    parameter FOOD_BEGIN_Y = SCREEN_HEIGHT * 2 / 3; // Place food near 2/3rd height
endmodule
////////////////////////////////////////////////////////////////////////////////