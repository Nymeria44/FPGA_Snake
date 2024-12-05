////////////////////////////////////////////////////////////////////////////////
// Module Name : Snake
// Dependencies:
// Description : Converts 189bit stream of 3-bit x,y coordinates to 64bit data
//               for the 8x8 LED matrix
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module snake(
    input clk,					    // clock
	input slow_clk,				    // slow game clock
    input rst_n,                    // reset signal
    input [188:0] x_list,		    // 3bit x coordinate for 63 snake segments
    input [188:0] y_list,		    // 3bit y coordinate for 63 snake segments
    input [5:0] length,			    // length of snake
    output wire [63:0] disp_data	// 8x8 LED matrix data
);
	reg [1:0] work = 2'd1;			// state of work being done
	integer i;						// counter for loop
	reg [5:0] slice = 6'd0;	 		// 3-bit slice counter
	
	reg [7:0] line0 = 8'b0;			// initialise line data with nothing
	reg [7:0] line1 = 8'b0;
	reg [7:0] line2 = 8'b0;
	reg [7:0] line3 = 8'b0;
	reg [7:0] line4 = 8'b0;
	reg [7:0] line5 = 8'b0;
	reg [7:0] line6 = 8'b0;
	reg [7:0] line7 = 8'b0;

	reg [63:0] temp_data = 64'b0;	// temporary data for display
	reg [63:0] final_data = 64'b0;	// final data for display
	assign disp_data = final_data;	// outputing final data


// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------
	initial begin
		$monitor("disp_data=%b", disp_data);
	end
// -----------------------------------------------------------------------------
// Clock Synchronisation
// -----------------------------------------------------------------------------
    wire pos_edge_synch; // falling edge detection
    edge_synch edge_synch(.fast_clk(clk), 
                            .slow_clk(slow_clk), 
                            .rst_n(rst_n), 
                            .pos_synch(pos_edge_synch), 
                            .neg_synch());

// -----------------------------------------------------------------------------
// Main logic
// -----------------------------------------------------------------------------
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			line0 = 8'b0;		
			line1 = 8'b0;
			line2 = 8'b0;
			line3 = 8'b0;
			line4 = 8'b0;
			line5 = 8'b0;
			line6 = 8'b0;
			line7 = 8'b0;
		end else begin
			if(pos_edge_synch) begin
				work <= 2'd1;
			end

			case (work)
				2'd1: begin
					for (i = 0; i < 63; i = i + 1) begin //wont work with length
						if (slice < length) begin 
							slice = slice + 6'd1;
							$display("x_list: %b, %d", 
									x_list[i*3 +: 3],x_list[i*3 +: 3]);
							// bit shift to right the x coordinates each line
							case (y_list[i*3+: 3]) 
								3'b000: line0 = line0 | 
								(8'b10000000 >> x_list[i*3 +: 3]); 
								3'b001: line1 = line1 | 
								(8'b10000000 >> x_list[i*3 +: 3]); 
								3'b010: line2 = line2 | 
								(8'b10000000 >> x_list[i*3 +: 3]); 
								3'b011: line3 = line3 | 
								(8'b10000000 >>x_list[i*3 +: 3]); 
								3'b100: line4 = line4 | 
								(8'b10000000 >> x_list[i*3 +: 3]);
								3'b101: line5 = line5 | 
								(8'b10000000 >> x_list[i*3 +: 3]); 
								3'b110: line6 = line6 | 
								(8'b10000000 >> x_list[i*3 +: 3]); 
								3'b111: line7 = line7| 
								(8'b10000000 >> x_list[i*3 +: 3]); 
							endcase
						end
						
					end
					// concatenate all line data
					temp_data <= {line7, line6, line5, line4, 
								  line3, line2, line1, line0};
					work <= work + 2'd1;
				end
				2'd2: begin
					slice <= 6'd0;
					$display("line0: %b", line0);
					$display("line1: %b", line1);
					$display("line2: %b", line2);
					$display("line3: %b", line3);
					$display("line4: %b", line4);
					$display("line5: %b", line5);
					$display("line6: %b", line6);
					$display("line7: %b", line7);
					final_data <= temp_data; // output final data
					work <= work + 2'd1;
				end
				2'd3: begin
					// reset all data
					line0 = 8'b0;		
					line1 = 8'b0;
					line2 = 8'b0;
					line3 = 8'b0;
					line4 = 8'b0;
					line5 = 8'b0;
					line6 = 8'b0;
					line7 = 8'b0;
					work <= work + 2'd1;
				end
			endcase
		end
	end

endmodule