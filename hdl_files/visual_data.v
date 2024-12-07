////////////////////////////////////////////////////////////////////////////////
// Module Name : Visual Data
// Dependencies:
// Description : Generates visual data to be displayed on the VGA    
///////////////////////////////////////////////////////////////////////////////
module visual_data(
    input clock,
    input [1:0] switch,       // Switch to control display mode
    input [9:0] hcount,       // Horizontal pixel count from VGA module
    input [9:0] vcount,       // Vertical line count from VGA module
    output reg [2:0] data      // 3-bit RGB data output
);

    // Parameter of checkerboard square size
    parameter SQUARE_SIZE = 100;

    // To store if current block is odd or even
    reg hblock_odd;
    reg vblock_odd;

    // Calculating if odd or even for block_x_odd
    always @(posedge clock) begin
        case(SQUARE_SIZE)
            100: begin
                if      (hcount < 100) hblock_odd <= 0;
                else if (hcount < 200) hblock_odd <= 1;
                else if (hcount < 300) hblock_odd <= 0;
                else if (hcount < 400) hblock_odd <= 1;
                else if (hcount < 500) hblock_odd <= 0;
                else if (hcount < 600) hblock_odd <= 1;
                else if (hcount < 700) hblock_odd <= 0;
                else                   hblock_odd <= 1;
            end
            200: begin
                if      (hcount < 200) hblock_odd <= 0;
                else if (hcount < 400) hblock_odd <= 1;
                else if (hcount < 600) hblock_odd <= 0;
                else                   hblock_odd <= 1;
            end
            default: hblock_odd <= 0;
        endcase
    end

    // Calculating if odd or even for block_y_odd
    always @(posedge clock) begin
        case(SQUARE_SIZE)
            100: begin
                if      (vcount < 100) vblock_odd <= 0;
                else if (vcount < 200) vblock_odd <= 1;
                else if (vcount < 300) vblock_odd <= 0;
                else if (vcount < 400) vblock_odd <= 1;
                else if (vcount < 500) vblock_odd <= 0;
                else if (vcount < 600) vblock_odd <= 1;
                else                   vblock_odd <= 0;
            end
            200: begin
                if      (vcount < 200) vblock_odd <= 0;
                else if (vcount < 400) vblock_odd <= 1;
                else if (vcount < 600) vblock_odd <= 0;
                else                   vblock_odd <= 0;
            end
            default: vblock_odd <= 0;
        endcase
    end

    // Determine if the current block should be white or black
    wire is_white;
    assign is_white = hblock_odd ^ vblock_odd;

    // Select data based on switch input
    always @(posedge clock) begin
        case(switch[1:0])
            2'd0: data <= (hcount < 800 && vcount < 600) ? 3'b111 : 3'b000; // White active region
            2'd1: data <= 3'b000;                                             // Always black
            2'd2: data <= is_white ? 3'b111 : 3'b000;                        // Checkerboard pattern
            2'd3: data <= ~(is_white) ? 3'b111 : 3'b000;                      // Inverted Checkerboard
            default: data <= 3'b000;
        endcase
    end

endmodule
///////////////////////////////////////////////////////////////////////////////