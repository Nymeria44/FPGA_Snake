////////////////////////////////////////////////////////////////////////////////
// Module Name : PS2 Scan
// Dependencies:
// Description : Scans for PS2 keyboard input and converts it to ASCII
//               Still needs to be tweaked for special keystrokes and use of
//			     keypress state
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Module internal and external signals
// -----------------------------------------------------------------------------
module ps2scan(
    input clk,			    	// clock
    input rst_n,			    // reset signal
    input ps2k_clk,			    // ps2 clock signal	
  	 input ps2k_data,		    // PS2 data signal	
	 output[7:0] ps2_byte, 	    // scancode value
	 output ps2_state            // keypress state
);

// -----------------------------------------------------------------------------
// Clock Synchronisation
// -----------------------------------------------------------------------------
    wire neg_ps2k_clk; // falling edge detection
    edge_synch edge_synch(.fast_clk(clk), 
                            .slow_clk(ps2k_clk), 
                            .rst_n(rst_n), 
                            .pos_synch(), 
                            .neg_synch(neg_ps2k_clk));

// -----------------------------------------------------------------------------
// Read PS2 Byte stream
// -----------------------------------------------------------------------------
    reg[7:0] ps2_byte_r;				// 1 byte scancode
    reg[7:0] temp_data;					// Current receiving data register
    reg[3:0] num;						// Counter

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
                num <= 4'd0;
                temp_data <= 8'd0;
            end
        else if(neg_ps2k_clk) begin	
                case (num)
                    4'd0:	num <= num+1'b1;
                    4'd1:	begin
                                num <= num+1'b1;
                                temp_data[0] <= ps2k_data;	//bit0
                            end
                    4'd2:	begin
                                num <= num+1'b1;
                                temp_data[1] <= ps2k_data;	//bit1
                            end
                    4'd3:	begin
                                num <= num+1'b1;
                                temp_data[2] <= ps2k_data;	//bit2
                            end
                    4'd4:	begin
                                num <= num+1'b1;
                                temp_data[3] <= ps2k_data;	//bit3
                            end
                    4'd5:	begin
                                num <= num+1'b1;
                                temp_data[4] <= ps2k_data;	//bit4
                            end
                    4'd6:	begin
                                num <= num+1'b1;
                                temp_data[5] <= ps2k_data;	//bit5
                            end
                    4'd7:	begin
                                num <= num+1'b1;
                                temp_data[6] <= ps2k_data;	//bit6
                            end
                    4'd8:	begin
                                num <= num+1'b1;
                                temp_data[7] <= ps2k_data;	//bit7
                            end
                    4'd9:	begin
                                num <= num+1'b1;	//Parity bit, no processing
                            end
                    4'd10: begin
                                num <= 4'd0;	// clear num
                            end
                    default: ;
                    endcase
            end	
    end

// -----------------------------------------------------------------------------
// Key Press Processing
// -----------------------------------------------------------------------------
    reg key_f0;			// F0 key flag
    reg ps2_state_r;	// read state flag

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
                key_f0 <= 1'b0;
                ps2_state_r <= 1'b0;
            end
        else if(num==4'd10) begin	// 1 byte received check
                if(temp_data == 8'hf0) key_f0 <= 1'b1; // break key flag
                else begin
                        if(!key_f0) begin 				 // if its not break code
                                ps2_state_r <= 1'b1; 	 // enable data read
                                ps2_byte_r <= temp_data; // put scan code to read
                            end
                        else begin
                                ps2_state_r <= 1'b0; 	 // disable ASCII output
                                key_f0 <= 1'b0;			 // clear break key flag
                            end
                    end
            end
    end

// -----------------------------------------------------------------------------
// ASCII Key Conversion
// -----------------------------------------------------------------------------
    reg[7:0] ps2_asci; 				// ascii temporary storage
    assign ps2_byte = ps2_asci;	 	// assign ASCII to output byte
    assign ps2_state = ps2_state_r;	// output state

    always @ (ps2_byte_r) begin
        case (ps2_byte_r)
            // Alphanumeric keys (uppercase)
            8'h15: ps2_asci <= 8'h51;  // Q
            8'h1d: ps2_asci <= 8'h57;  // W
            8'h24: ps2_asci <= 8'h45;  // E
            8'h2d: ps2_asci <= 8'h52;  // R
            8'h2c: ps2_asci <= 8'h54;  // T
            8'h35: ps2_asci <= 8'h59;  // Y
            8'h3c: ps2_asci <= 8'h55;  // U
            8'h43: ps2_asci <= 8'h49;  // I
            8'h44: ps2_asci <= 8'h4f;  // O
            8'h4d: ps2_asci <= 8'h50;  // P
            8'h1c: ps2_asci <= 8'h41;  // A
            8'h1b: ps2_asci <= 8'h53;  // S
            8'h23: ps2_asci <= 8'h44;  // D
            8'h2b: ps2_asci <= 8'h46;  // F
            8'h34: ps2_asci <= 8'h47;  // G
            8'h33: ps2_asci <= 8'h48;  // H
            8'h3b: ps2_asci <= 8'h4a;  // J
            8'h42: ps2_asci <= 8'h4b;  // K
            8'h4b: ps2_asci <= 8'h4c;  // L
            8'h1a: ps2_asci <= 8'h5a;  // Z
            8'h22: ps2_asci <= 8'h58;  // X
            8'h21: ps2_asci <= 8'h43;  // C
            8'h2a: ps2_asci <= 8'h56;  // V
            8'h32: ps2_asci <= 8'h42;  // B
            8'h31: ps2_asci <= 8'h4e;  // N
            8'h3a: ps2_asci <= 8'h4d;  // M
            
            // Number row (shift required for symbols)
            8'h16: ps2_asci <= 8'h31;  // 1
            8'h1e: ps2_asci <= 8'h32;  // 2
            8'h26: ps2_asci <= 8'h33;  // 3
            8'h25: ps2_asci <= 8'h34;  // 4
            8'h2e: ps2_asci <= 8'h35;  // 5
            8'h36: ps2_asci <= 8'h36;  // 6
            8'h3d: ps2_asci <= 8'h37;  // 7
            8'h3e: ps2_asci <= 8'h38;  // 8
            8'h46: ps2_asci <= 8'h39;  // 9
            8'h45: ps2_asci <= 8'h30;  // 0
            
            // Ctrl, Alt, and Windows
            8'h14: ps2_asci <= 8'hF3;  // Left Ctrl
    //        8'hE014: ps2_asci <= 8'hF4;  // Right Ctrl
            8'h11: ps2_asci <= 8'hF5;  // Left Alt
    //        8'hE011: ps2_asci <= 8'hF6;  // Right Alt
    //        8'hE01F: ps2_asci <= 8'hF7;  // Left Windows
    //        8'hE027: ps2_asci <= 8'hF8;  // Right Windows

            // Special characters on number row
            8'h0E: ps2_asci <= 8'h60;  // ` (tilde, backtick)
            8'h4E: ps2_asci <= 8'h2D;  // - (hyphen)
            8'h55: ps2_asci <= 8'h3D;  // = (equals)
            8'h54: ps2_asci <= 8'h5B;  // [ (left bracket)
            8'h5B: ps2_asci <= 8'h5D;  // ] (right bracket)
            8'h5D: ps2_asci <= 8'h5C;  // \ (backslash)
            8'h29: ps2_asci <= 8'h20;  // Space
            8'h0D: ps2_asci <= 8'h09;  // Tab (ASCII 0x09)
            8'h66: ps2_asci <= 8'h08;  // Backspace (ASCII 0x08)

            // CapsLock, Escape
            8'h58: ps2_asci <= 8'hF9;  // Caps Lock
            8'h76: ps2_asci <= 8'h1B;  // Escape (ASCII 0x1B)

            // Enter (Carriage Return)
            8'h5A: ps2_asci <= 8'h0D;  // Enter (ASCII 0x0D)

            // Function keys
            8'h05: ps2_asci <= 8'hF1;  // F1 (non-standard, but can assign a special code)
            8'h06: ps2_asci <= 8'hF2;  // F2
            8'h04: ps2_asci <= 8'hF3;  // F3
            8'h0C: ps2_asci <= 8'hF4;  // F4
            8'h03: ps2_asci <= 8'hF5;  // F5
            8'h0B: ps2_asci <= 8'hF6;  // F6
            8'h83: ps2_asci <= 8'hF7;  // F7
            8'h0A: ps2_asci <= 8'hF8;  // F8
            8'h01: ps2_asci <= 8'hF9;  // F9
            8'h09: ps2_asci <= 8'hFA;  // F10
            8'h78: ps2_asci <= 8'hFB;  // F11
            8'h07: ps2_asci <= 8'hFC;  // F12

    //        // Arrow keys
    //        8'hE075: ps2_asci <= 8'h26;  // Up Arrow (ASCII equivalent is ^, using 0x26)
    //        8'hE072: ps2_asci <= 8'h28;  // Down Arrow (ASCII equivalent is v, using 0x28)
    //        8'hE06B: ps2_asci <= 8'h25;  // Left Arrow (ASCII equivalent is <, using 0x25)
    //        8'hE074: ps2_asci <= 8'h27;  // Right Arrow (ASCII equivalent is >, using 0x27)

            // Numpad keys
            8'h70: ps2_asci <= 8'h30;  // Numpad 0 (ASCII "0")
            8'h69: ps2_asci <= 8'h31;  // Numpad 1 (ASCII "1")
            8'h72: ps2_asci <= 8'h32;  // Numpad 2 (ASCII "2")
            8'h7A: ps2_asci <= 8'h33;  // Numpad 3 (ASCII "3")
            8'h6B: ps2_asci <= 8'h34;  // Numpad 4 (ASCII "4")
            8'h73: ps2_asci <= 8'h35;  // Numpad 5 (ASCII "5")
            8'h74: ps2_asci <= 8'h36;  // Numpad 6 (ASCII "6")
            8'h6C: ps2_asci <= 8'h37;  // Numpad 7 (ASCII "7")
            8'h75: ps2_asci <= 8'h38;  // Numpad 8 (ASCII "8")
            8'h7D: ps2_asci <= 8'h39;  // Numpad 9 (ASCII "9")
            8'h79: ps2_asci <= 8'h2B;  // Numpad "+" (ASCII "+")
            8'h7B: ps2_asci <= 8'h2D;  // Numpad "-" (ASCII "-")
            8'h7C: ps2_asci <= 8'h2A;  // Numpad "*" (ASCII "*")
            8'h71: ps2_asci <= 8'h2F;  // Numpad "/" (ASCII "/")

    //        // Home, End, Insert, Delete, Page Up, Page Down
    //        8'hE06C: ps2_asci <= 8'h24;  // Home (ASCII "Home", custom code)
    //        8'hE069: ps2_asci <= 8'h23;  // End (ASCII "End", custom code)
    //        8'hE070: ps2_asci <= 8'h2E;  // Insert (ASCII "Ins", custom code)
    //        8'hE071: ps2_asci <= 8'h2E;  // Delete (ASCII "Del", custom code)
    //        8'hE07D: ps2_asci <= 8'h21;  // Page Up (ASCII "PgUp", custom code)
    //        8'hE07A: ps2_asci <= 8'h22;  // Page Down (ASCII "PgDn", custom code)

    //        // Print Screen, Scroll Lock, Pause/Break
    //        8'hE07C: ps2_asci <= 8'hF0;  // Print Screen (custom code)
    //        8'h46: ps2_asci <= 8'hF1;    // Scroll Lock (custom code)
    //        8'hE11477E1F014E077: ps2_asci <= 8'hF2;  // Pause/Break (custom code)
            
            // Symbols
            8'h4C: ps2_asci <= 8'h3B;  // ; (semicolon)
            8'h52: ps2_asci <= 8'h27;  // ' (single quote)
            8'h41: ps2_asci <= 8'h2C;  // , (comma)
            8'h49: ps2_asci <= 8'h2E;  // . (period)
            8'h4A: ps2_asci <= 8'h2F;  // / (forward slash)

            default: ps2_asci <= 8'h00;  // Undefined key or unsupported key
        endcase
    end

endmodule
////////////////////////////////////////////////////////////////////////////////