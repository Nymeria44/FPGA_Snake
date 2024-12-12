////////////////////////////////////////////////////////////////////////////////
// Header Name : Resolution Parameters
// Dependencies:
// Description : Parameters which define the resolution of the game
////////////////////////////////////////////////////////////////////////////////
// Screen dimensions
`define SCREEN_WIDTH 800
`define SCREEN_HEIGHT 600

// VGA timing parameters
`define H_ACTIVE `SCREEN_WIDTH
`define H_FP 40
`define H_SYNC 128
`define H_BP 88
`define H_TOTAL (`H_ACTIVE + `H_FP + `H_SYNC + `H_BP)

`define V_ACTIVE `SCREEN_HEIGHT
`define V_FP 1
`define V_SYNC 4
`define V_BP 23
`define V_TOTAL (`V_ACTIVE + `V_FP + `V_SYNC + `V_BP)

// Game-specific parameters
`define FOOD_WIDTH 16
`define HEAD_WIDTH 16
`define SNAKE_BEGIN_X (`SCREEN_WIDTH / 3)
`define SNAKE_BEGIN_Y (`SCREEN_HEIGHT / 2)
`define SNAKE_LENGTH_BEGIN 15
`define SNAKE_LENGTH_MAX 40
`define FOOD_BEGIN_X (`SCREEN_WIDTH * 3 / 4)
`define FOOD_BEGIN_Y (`SCREEN_HEIGHT * 2 / 3)
////////////////////////////////////////////////////////////////////////////////