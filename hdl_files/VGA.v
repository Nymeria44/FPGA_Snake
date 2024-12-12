////////////////////////////////////////////////////////////////////////////////
// Module Name : VGA
// Dependencies:
// Description : Responsible for drawing to monitor using VGA    
////////////////////////////////////////////////////////////////////////////////
`include "res_params.vh"

module VGA(
    input clock,             // 40MHz pixel clock
    input [2:0] data,        
    output [2:0] disp_RGB,   // 3-bit RBG colours
    output hsync,            // VGA horizontal sync signal
    output vsync,            // VGA vertical sync signal
    output [9:0] hcount,     // Horizontal counter output
    output [9:0] vcount      // Vertical counter output
);

// -----------------------------------------------------------------------------
// Assigning VGA internal parameters
// -----------------------------------------------------------------------------
    // Screen dimensions
    localparam h_active = `H_ACTIVE;      // Active horizontal pixels
    localparam h_fp     = `H_FP;          // Horizontal front porch
    localparam h_sync   = `H_SYNC;        // Horizontal sync pulse width
    localparam h_bp     = `H_BP;          // Horizontal back porch
    localparam h_total  = `H_TOTAL;       // Total horizontal pixels

    localparam v_active = `V_ACTIVE;      // Active vertical lines
    localparam v_fp     = `V_FP;          // Vertical front porch
    localparam v_sync   = `V_SYNC;        // Vertical sync pulse width
    localparam v_bp     = `V_BP;          // Vertical back porch
    localparam v_total  = `V_TOTAL;       // Total vertical lines

    // Timing positions
    localparam hsync_start = h_active + h_fp;
    localparam hsync_end   = h_active + h_fp + h_sync;

    localparam vsync_start = v_active + v_fp;
    localparam vsync_end   = v_active + v_fp + v_sync;

    reg [10:0] hcount_reg = 0;  // 11-bit counter for horizontal pixels
    reg [10:0] vcount_reg = 0;  // 11-bit counter for vertical lines

// -----------------------------------------------------------------------------
// VGA internal logic
// -----------------------------------------------------------------------------
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