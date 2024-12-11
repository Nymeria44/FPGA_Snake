////////////////////////////////////////////////////////////////////////////////
// Module Name : Coordinate Update
// Dependencies:
// Description : Module updates 189-bit x and y lists for coordinates of the 
//		         snake on the 8x8 LED matrix
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module coordinate_update (
	input clk,						// clock
	input rst_n,					// reset signal
	input [7:0] ps2ascii,			// raw keyboard input
	output reg [5:0] length,		// length of snake
	output reg [188:0] x_list,		// 3bit x coordinate for 63 snake segments
   	output reg [188:0] y_list		// 3bit y coordinate for 63 snake segments
);
	reg [2:0] old_direction = 3'd3; // previous snake direction
	reg [2:0] new_direction = 3'd3; // new snake direction

	reg [2:0] head_x;				// x coordinate of the snake head
	reg [2:0] head_y;				// y coordinate of the snake head

// -----------------------------------------------------------------------------
// Dummy data for testing
// -----------------------------------------------------------------------------
// I think this is also used in hardware don't remove
	initial begin
		x_list = 189'b0;
		y_list = 189'b0;
		length = 5'd4; 
		
		head_x = 3'd4;
		head_y = 3'd3;
		x_list[2:0]   = 3'd3; 			// initialise a 4 bit snake horizontally
		y_list[2:0]   = 3'd3; 
		y_list[5:3]   = 3'd3;
		x_list[5:3]   = 3'd2; 
		y_list[8:6]   = 3'd3;
		x_list[8:6]   = 3'd1; 
		y_list[11:9]  = 3'd3;
		x_list[11:9]  = 3'd0;
		
		$display ("x_list %b, y_list %b", x_list, y_list);
	end
	
// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
	always @ (posedge clk) begin
		case (ps2ascii)
			8'h57: new_direction <= 3'd0; 			 // W UP
			8'h41: new_direction <= 3'd1; 			 // A LEFT
			8'h53: new_direction <= 3'd2; 			 // S DOWN
			8'h44: new_direction <= 3'd3; 			 // D RIGHT
			default: new_direction <= old_direction; // keep same direction
		endcase
		
		case (new_direction)
			3'd0: begin
						$display("Moving Up");
//						if (head_y != 0) begin
							head_y <= head_y - 3'd1;
//						end
					end
			3'd1: begin
						$display("Moving Left");
//						if (head_x != 0) begin
							head_x <= head_x - 3'd1;
//						end
					end
			3'd2: begin
						$display("Moving Down");
//						if (head_y != 7) begin
							head_y <= head_y + 3'd1;
//						end
					end
			3'd3: begin
						$display("Moving Right");
//						if (head_x != 7) begin
							head_x <= head_x + 3'd1;
//						end
					end
		endcase

		x_list <= {x_list[185:0], head_x}; // head_x LSB shift
		y_list <= {y_list[185:0], head_y}; // head_y LSB shift
		$display("at time: %t, head_x: %d, %b, head_y: %d, %b", $time, 
				 head_x, head_x, head_y, head_y);
		$display("at time: %t, x_list: %b, y_list: %b",$time, x_list, y_list);
	end
	
endmodule