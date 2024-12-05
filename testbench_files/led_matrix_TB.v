////////////////////////////////////////////////////////////////////////////////
// Module Name : Led Matrix Testbench
// Dependencies:
// Description : Testbench for led matrix module
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module intennal and external signals
// -----------------------------------------------------------------------------
module led_matrix_TB();
    reg clk;
    reg rst_n;
    wire slow_clk;
    reg [63:0] disp_data; 
	wire [7:0] line_data;
	wire [7:0] row;

// -----------------------------------------------------------------------------
// Instantiate the design under test (DUT)
// -----------------------------------------------------------------------------
    led_matrix led_matrix_DUT(
        .clk(clk),
        .rst_n(rst_n),
        .slow_clk(slow_clk),
        .disp_data(disp_data),
		.line_data(line_data),
		.row(row)
    );
  
// -----------------------------------------------------------------------------
// Testbench behavior
// -----------------------------------------------------------------------------
    always #10 clk = ~clk; // 50Mhz clock

    initial begin
        clk = 0;  // Initialize signals
        rst_n = 0;
        // Set up disp_data for the LED matrix
        disp_data[7:0]   = 8'b10101010;  // column 0
        disp_data[15:8]  = 8'b11111111;  // column 1
        disp_data[23:16] = 8'b00000000;  // column 2
        disp_data[31:24] = 8'b01010101;  // column 3
        disp_data[39:32] = 8'b10101010;  // column 4
        disp_data[47:40] = 8'b11110000;  // column 5
        disp_data[55:48] = 8'b00001111;  // column 6
        disp_data[63:56] = 8'b00111100;  // column 7

        #50 rst_n = 1;  // After 50ns, release reset
        #200;           // for 8 clock cycles 160ns
        $stop;
    end

// -----------------------------------------------------------------------------
// Monitoring
// -----------------------------------------------------------------------------
    initial begin
        $monitor("At time %t, column = %b, line_data = %b",
                $time, row, line_data);
    end

endmodule
