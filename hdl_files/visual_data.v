////////////////////////////////////////////////////////////////////////////////
// Module Name : Visual Data
// Dependencies:
// Description : Generates visual data to be displayed on the VGA    
////////////////////////////////////////////////////////////////////////////////
module visual_data(
    input clock,
    input vga_clk,
    input [1:0] switch,
    input [9:0] hcount,
    input [9:0] vcount,
    output reg [2:0] data
);

reg [2:0] h_dat;		// 3-bit reg for horizontal data
reg [2:0] v_dat;		// 3-bit reg for vertical data

// Data Selection
always @(posedge vga_clk)
begin
	case(switch[1:0])
		2'd0: data <= h_dat;      // Select horizontal data
		2'd1: data <= v_dat;      // Select vertical data
		2'd2: data <= (v_dat ^ h_dat); // XOR of vertical and horizontal data
		2'd3: data <= (v_dat ~^ h_dat); // XNOR of vertical and horizontal data
	endcase
end

// Vertical Data generation (depends on hcount)
always @(posedge vga_clk)
begin
	if(hcount < 223)
		v_dat <= 3'h7;      // Color 7
	else if(hcount < 303)
		v_dat <= 3'h6;   // Color 6
	else if(hcount < 383)
		v_dat <= 3'h5;   // Color 5
	else if(hcount < 463)
		v_dat <= 3'h4;    // Color 4
	else if(hcount < 543)
		v_dat <= 3'h3;   // Color 3
	else if(hcount < 623)
		v_dat <= 3'h2;   // Color 2
	else if(hcount < 703)
		v_dat <= 3'h1;   // Color 1
	else 
		v_dat <= 3'h0;   // Color 0
end

// Horizontal Data generation (depends on vcount)
always @(posedge vga_clk)
begin
	if(vcount < 94)
		h_dat <= 3'h7;        // Color 7
	else if(vcount < 154)
		h_dat <= 3'h6;   // Color 6
	else if(vcount < 214)
		h_dat <= 3'h5;   // Color 5
	else if(vcount < 274)
		h_dat <= 3'h4;    // Color 4
	else if(vcount < 334)
		h_dat <= 3'h3;   // Color 3
	else if(vcount < 394)
		h_dat <= 3'h2;   // Color 2
	else if(vcount < 454)
		h_dat <= 3'h1;   // Color 1
	else 
		h_dat <= 3'h0;   // Color 0
end

endmodule
////////////////////////////////////////////////////////////////////////////////