////////////////////////////////////////////////////////////////////////////////
// Module Name : Led Matrix
// Dependencies:
// Description : 8byte demultiplexer to 1 byte for 8x8 LED matrix
//               # need to maybe make it 60hz
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module led_matrix(
	input clk,
	input rst_n,
	input [63:0] disp_data,
	output reg [7:0] line_data,
	output reg [7:0] row
);
	reg [2:0] count = 0;

// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
// output is inverted 0 is on 1 is off for line_data
	always @ (posedge clk) begin
		if (!rst_n) begin
			count <= 0;
			row = 8'b00000001;
			line_data = 8'b11111111;
		end
		else begin
			if (count == 7) begin
				count <= 0;
			end
			else begin
				count <= count + 3'd1;
			end
			case (count)
				0: begin
					line_data = ~disp_data[7:0];    	
					row = 8'b00000001;
				end
				1: begin
					line_data = ~disp_data[15:8];   
					row = 8'b00000010;
				end
				2: begin
					line_data = ~disp_data[23:16];  	
					row = 8'b00000100;
				end
				3: begin
					line_data = ~disp_data[31:24];  
					row = 8'b00001000;	
				end
				4: begin
					line_data = ~disp_data[39:32];  
					row = 8'b00010000;
				end
				5: begin
					line_data = ~disp_data[47:40]; 
					row = 8'b00100000;
				end
				6: begin
					line_data = ~disp_data[55:48];  
					row = 8'b01000000;
				end
				7: begin
					line_data = ~disp_data[63:56];  
					row = 8'b10000000;
				end
				default: begin
						  line_data = 8'b11111111;     
						  row = 8'b00000001;
				end
		 endcase
		end
	end
	
	
endmodule

