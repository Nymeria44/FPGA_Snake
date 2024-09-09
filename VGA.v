module VGA(
   clock,
   switch,
   disp_RGB,
   hsync,
   vsync
);
input  clock;     // 50MHz
input  [1:0]switch;	// 2-bit input switch
output [2:0]disp_RGB;    // 3-bit VGA display colors
output  hsync;     // VGA horizontal sync signal
output  vsync;     // VGA vertical sync signal

// Assigning registers
reg [9:0] hcount;     // 10-bit reg for Horizontal counter
reg [9:0] vcount;     // 10-bit reg for Vertical counter
reg [2:0] data;		// 3-bit reg for data
reg [2:0] h_dat;		// 3-bit reg for horizontal data
reg [2:0] v_dat;		// 3-bit reg for vertical data

//reg [9:0] timer
reg flag;
wire hcount_ov; 	// Horizontal counter overflow
wire vcount_ov; 	// Vertical counter overflow
wire dat_act;		// Data active signal
wire hsync;
wire vsync;
reg vga_clk; 		// Register for VGA clock

// VGA timing parameters
parameter hsync_end   = 10'd95,	 // End of Horizontal sync
   hdat_begin  = 10'd143,		// Start of Horizontal data
   hdat_end  = 10'd783,			// End of Horizontal data
   hpixel_end  = 10'd799,		// End of Horizontal sync
   vsync_end  = 10'd1,			// End of Vertical sync
   vdat_begin  = 10'd34,		// Start of Vertical data
   vdat_end  = 10'd514,			// End of Vertical data
   vline_end  = 10'd524;		// End of Vertical lines


// VGA clock generation
always @(posedge clock) 	// On the rising edge of the VGA clock signal
begin
 vga_clk = ~vga_clk;		// Toggles VGA clock signal
end


// Horizontal counter   
always @(posedge vga_clk)		// On the rising edge of the VGA clock signal
begin
 if (hcount_ov)		// If horizontal counter overflows
  hcount <= 10'd0; 	// Reset horizontal counter
 else
  hcount <= hcount + 10'd1;	// Increment horizontal counter
end
assign hcount_ov = (hcount == hpixel_end);	// Horizontal counter overflow condition

//Vertical counter
always @(posedge vga_clk)
begin
 if (hcount_ov)	//  If horizontal counter overflows
 begin
  if (vcount_ov)	// If vertical counter overflows
   vcount <= 10'd0;	// Reset vertical counter
  else
   vcount <= vcount + 10'd1;	// Increment vertical counter
 end
end
assign  vcount_ov = (vcount == vline_end);	// Vertical counter overflow condition
//���ݡ�ͬ���ź���
assign dat_act =    ((hcount >= hdat_begin) && (hcount < hdat_end))	// Assign Data active condition
     && ((vcount >= vdat_begin) && (vcount < vdat_end));		
assign hsync = (hcount > hsync_end);		// Assign Horizontal sync signal
assign vsync = (vcount > vsync_end);		// Assign Vertical sync signal
assign disp_RGB = (dat_act) ?  data : 3'h00;      // Assign Display RGB data 

//************************��ʾ���ݴ�������******************************* 
//ͼƬ��ʾ��ʱ������
/*always @(posedge vga_clk)
begin
 flag <= vcount_ov;
 if(vcount_ov && ~flag)
  timer <= timer + 1'b1;
end
*/

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

// Vertical Data generation
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

// Horizontal Data generation
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