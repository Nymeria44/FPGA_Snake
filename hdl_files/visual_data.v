////////////////////////////////////////////////////////////////////////////////
// Module Name : Visual Data (Checkerboard)
// Description : Generates a black and white checkerboard pattern, plus allows 
//               other display modes based on the 'switch' input.
////////////////////////////////////////////////////////////////////////////////
module visual_data(
    input clock,
    input [1:0] switch,       // Switch to control display mode
    input [9:0] hcount,       // Horizontal pixel count from VGA module
    input [9:0] vcount,       // Vertical line count from VGA module
    output reg [2:0] data     // 3-bit RGB data output (1=white,0=black)
);

    // Parameter of checkerboard square size
    parameter SQUARE_SIZE = 200;

    // Compute block indices
    wire [9:0] hx_block = hcount / SQUARE_SIZE;  
    wire [9:0] vy_block = vcount / SQUARE_SIZE;  

    // XOR to determine color: if XOR is 1, white; else black
    wire is_white = (hx_block[0] ^ vy_block[0]);

    always @(posedge clock) begin
        case(switch)
            2'd0: data <= 3'b111; // Mode 0: All white screen
            2'd1: data <= 3'b000; // Mode 1: All black screen
            2'd2: data <= is_white ? 3'b111 : 3'b000; // Mode 2: Checkerboard
            2'd3: data <= is_white ? 3'b000 : 3'b111; // Mode 3: Inverted checkerboard
            default: data <= 3'b000;
        endcase
    end

endmodule