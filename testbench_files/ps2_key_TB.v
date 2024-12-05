////////////////////////////////////////////////////////////////////////////////
// Module Name : PS2 Keyboard Testbench
// Dependencies:
// Description : Testbench for top level module PS2 Keyboard sending keystrokes
//               and displaying them on the 7-segment display
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module intennal and external signals
// -----------------------------------------------------------------------------
module ps2_key_TB;
    reg clk;
    reg rst_n;
    reg ps2k_clk;
    reg ps2k_data;
	wire [1:0] dig;  // 7-bit output for the first 7-segment display
	wire [7:0] seg;  // 7-bit output for the second 7-segment display

// -----------------------------------------------------------------------------
// Instantiate the design under test (DUT)
// -----------------------------------------------------------------------------
    ps2_key uut (
        .clk(clk),
        .rst_n(rst_n),
        .ps2k_clk(ps2k_clk),
        .ps2k_data(ps2k_data),
		  .dig(dig),
		  .seg(seg)
    );

// -----------------------------------------------------------------------------
// Testbench behavior
// -----------------------------------------------------------------------------
    always #10 clk = ~clk;  // 50 MHz clock

    // Send PS/2 byte along with the start, data, parity, and stop bits
    task send_ps2_byte(input [7:0] data_byte);
        integer i;
        begin
            ps2k_data = 0;   // pull data line low to start the transmission
            #100 ps2k_clk = 0; 
            #100 ps2k_clk = 1;

            // send byte (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                ps2k_data = data_byte[i];
                #100 ps2k_clk = 0; 
                #100 ps2k_clk = 1;
            end

            ps2k_data = 1;   // Parity bit (not used here)
            #100 ps2k_clk = 0; #
            100 ps2k_clk = 1;

            ps2k_data = 1;  // Pull data line high to end transmission
            #100 ps2k_clk = 0; 
            #100 ps2k_clk = 1;
        end
    endtask

    initial begin
        clk = 0;            // Initialize signals
        rst_n = 0;
        ps2k_clk = 1;
        ps2k_data = 1;
        #100;
        rst_n = 1;           // Reset the system

        send_ps2_byte(8'h1C); // A Key
        #4_000_000;
        send_ps2_byte(8'h1D); // W Key
        #4_000_000;
        send_ps2_byte(8'h3A); // M Key
        #4_000_000;
        send_ps2_byte(8'h2B); // F Key
        #4_000_000;
        $stop;
    end

// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------
    initial begin
        $monitor("Time: %d, ps2_byte: %h, ps2_state: %b, seg1: %b, seg2: %b", 
				 $time, uut.ps2scan.ps2_byte, uut.ps2scan.ps2_state, dig, seg);

    end

endmodule
