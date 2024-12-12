////////////////////////////////////////////////////////////////////////////////
// Module Name : VGA
// Dependencies:
// Description : Responsible for drawing to monitor using VGA    
////////////////////////////////////////////////////////////////////////////////
module VGA(
    input clock,             // 40MHz pixel clock
    input [2:0] data,        // 3-bit data input (from visual_data module)
    output [2:0] disp_RGB,   // 3-bit VGA display colors
    output hsync,            // VGA horizontal sync signal
    output vsync,            // VGA vertical sync signal
    output [9:0] hcount,     // Horizontal counter output
    output [9:0] vcount      // Vertical counter output
);

    // VGA timing parameters for 800x600 @ 60Hz
    parameter h_active = 800;
    parameter h_fp = 40;
    parameter h_sync = 128;
    parameter h_bp = 88;
    parameter h_total = h_active + h_fp + h_sync + h_bp;  // 1056

    parameter v_active = 600;
    parameter v_fp = 1;
    parameter v_sync = 4;
    parameter v_bp = 23;
    parameter v_total = v_active + v_fp + v_sync + v_bp;  // 628

    // Timing positions
    parameter hsync_start = h_active + h_fp;
    parameter hsync_end = h_active + h_fp + h_sync;

    parameter vsync_start = v_active + v_fp;
    parameter vsync_end = v_active + v_fp + v_sync;

    reg [10:0] hcount_reg = 0;  // 11-bit counter for horizontal pixels
    reg [10:0] vcount_reg = 0;  // 11-bit counter for vertical lines

    // Horizontal counter
    always @(posedge clock) begin
        if (hcount_reg == h_total - 1)
            hcount_reg <= 0;
        else
            hcount_reg <= hcount_reg + 1;
    end

    // Vertical counter
    always @(posedge clock) begin
        if (hcount_reg == h_total - 1) begin
            if (vcount_reg == v_total - 1)
                vcount_reg <= 0;
            else
                vcount_reg <= vcount_reg + 1;
        end
    end

    // Synchronization signals
    assign hsync = ~((hcount_reg >= hsync_start) && (hcount_reg < hsync_end));
    assign vsync = ~((vcount_reg >= vsync_start) && (vcount_reg < vsync_end));

    // Active video signal
    wire video_on = (hcount_reg < h_active) && (vcount_reg < v_active);

    // Output the counts
    assign hcount = hcount_reg[9:0];  // Use lower 10 bits
    assign vcount = vcount_reg[9:0];

    // Display RGB data assignment
    assign disp_RGB = video_on ? data : 3'b000;

endmodule
////////////////////////////////////////////////////////////////////////////////