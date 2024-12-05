////////////////////////////////////////////////////////////////////////////////
// Module Name : VGA
// Dependencies:
// Description : Responsible for drawing to monitor using VGA    
////////////////////////////////////////////////////////////////////////////////
module VGA(
    clock,
    vga_clk,
    data,
    hcount,
    vcount,
    disp_RGB,
    hsync,
    vsync
);

input  clock;     // 50MHz
input  vga_clk;   // VGA clock input
input  [2:0] data;       // 3-bit data input (from visual_data module)
output [2:0] disp_RGB;    // 3-bit VGA display colors
output  hsync;     // VGA horizontal sync signal
output  vsync;     // VGA vertical sync signal
output [9:0] hcount; // Horizontal counter output
output [9:0] vcount; // Vertical counter output

// Assigning registers
reg [9:0] hcount_reg;     // 10-bit reg for Horizontal counter
reg [9:0] vcount_reg;     // 10-bit reg for Vertical counter

// VGA timing parameters
parameter hsync_end   = 10'd95,	 // End of Horizontal sync
	hdat_begin  = 10'd143,		// Start of Horizontal data
	hdat_end  = 10'd783,			// End of Horizontal data
	hpixel_end  = 10'd799,		// End of Horizontal sync
	vsync_end  = 10'd1,			// End of Vertical sync
	vdat_begin  = 10'd34,		// Start of Vertical data
	vdat_end  = 10'd514,			// End of Vertical data
	vline_end  = 10'd524;		// End of Vertical lines

wire hcount_ov; 	// Horizontal counter overflow
wire vcount_ov; 	// Vertical counter overflow
wire dat_act;		// Data active signal

// Horizontal counter   
always @(posedge vga_clk)		// On the rising edge of the VGA clock signal
begin
	if (hcount_ov)		// If horizontal counter overflows
		hcount_reg <= 10'd0; 	// Reset horizontal counter
	else
		hcount_reg <= hcount_reg + 10'd1;	// Increment horizontal counter
end
assign hcount_ov = (hcount_reg == hpixel_end);	// Horizontal counter overflow condition
assign hcount = hcount_reg;  // Output hcount

//Vertical counter
always @(posedge vga_clk)
begin
	if (hcount_ov)	//  If horizontal counter overflows
	begin
		if (vcount_ov)	// If vertical counter overflows
			vcount_reg <= 10'd0;	// Reset vertical counter
		else
			vcount_reg <= vcount_reg + 10'd1;	// Increment vertical counter
	end
end
assign  vcount_ov = (vcount_reg == vline_end);	// Vertical counter overflow condition
assign vcount = vcount_reg;  // Output vcount

// Data active signal
assign dat_act = ((hcount_reg >= hdat_begin) && (hcount_reg < hdat_end))	
              && ((vcount_reg >= vdat_begin) && (vcount_reg < vdat_end));		

// Synchronization signals
assign hsync = (hcount_reg > hsync_end);		// Assign Horizontal sync signal
assign vsync = (vcount_reg > vsync_end);		// Assign Vertical sync signal

// Display RGB data assignment
assign disp_RGB = (dat_act) ? data : 3'h00;      // Assign Display RGB data 

endmodule
////////////////////////////////////////////////////////////////////////////////