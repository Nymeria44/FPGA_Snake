module simple_keypad (
    input        Clock,
    input        Reset,
    input        KeyRead,         // Pulse this high once the direction has been registered by main logic
    input  [3:0] RowDataIn,       // 4 input lines from the keypad rows
    output       KeyReady,        // Goes high when a direction key is detected
    output [3:0] DirectionOut,    // Direction code (Up/Left/Down/Right)
    output [3:0] ColDataOut       // 4 output lines to drive columns of the keypad
);

// State definitions for scanning and waiting
localparam SCAN       = 2'b00;
localparam CHECK_KEYS = 2'b01;
localparam WAIT_READ  = 2'b10;

// Direction codes
localparam UP    = 4'b0001;
localparam LEFT  = 4'b0010;
localparam DOWN  = 4'b0011;
localparam RIGHT = 4'b0100;

// Known Data patterns for keys
localparam DATA_UP    = 16'hFFEF; // R0,C1
localparam DATA_LEFT  = 16'hFFFD; // R1,C0
localparam DATA_DOWN  = 16'hFFDF; // R1,C1
localparam DATA_RIGHT = 16'hFDFF; // R1,C2

reg [1:0]  State;
reg [3:0]  Col;
reg [15:0] Data;
reg [1:0]  col_index;
reg        KeyRdy_reg;
reg [3:0]  Direction_reg;

assign KeyReady     = KeyRdy_reg;
assign DirectionOut = Direction_reg;

// Column drive pattern (one column low at a time)
// Original pattern used in provided code:
//   4'b0111 -> activates column 0
//   4'b1011 -> activates column 1
//   4'b1101 -> activates column 2
//   4'b1110 -> activates column 3
assign ColDataOut[0] = (Col[0] == 1'b0) ? 1'b0 : 1'bz;
assign ColDataOut[1] = (Col[1] == 1'b0) ? 1'b0 : 1'bz;
assign ColDataOut[2] = (Col[2] == 1'b0) ? 1'b0 : 1'bz;
assign ColDataOut[3] = (Col[3] == 1'b0) ? 1'b0 : 1'bz;

always @(posedge Clock or negedge Reset) begin
    if (!Reset) begin
        State         <= SCAN;
        Col           <= 4'b0111;  
        Data          <= 16'hFFFF;
        KeyRdy_reg    <= 0;
        Direction_reg <= 4'b0000;
        col_index     <= 0;
    end else begin
        case (State)
            SCAN: begin
                // Store RowDataIn into Data based on current column index
                case (col_index)
                    2'd0: Data[15:12] <= RowDataIn;
                    2'd1: Data[11:8]  <= RowDataIn;
                    2'd2: Data[7:4]   <= RowDataIn;
                    2'd3: begin
                        Data[3:0] <= RowDataIn;
                        // After reading all columns, check keys
                        State <= CHECK_KEYS;
                    end
                endcase

                // Move to next column pattern if not at the last column
                if (col_index < 3) begin
                    col_index <= col_index + 1;
                    case (col_index)
                        2'd0: Col <= 4'b1011; // Next column
                        2'd1: Col <= 4'b1101;
                        2'd2: Col <= 4'b1110;
                    endcase
                end
            end

            CHECK_KEYS: begin
                // Determine if Data matches one of the known direction keys
                if      (Data == DATA_UP)    Direction_reg <= UP;
                else if (Data == DATA_LEFT)  Direction_reg <= LEFT;
                else if (Data == DATA_DOWN)  Direction_reg <= DOWN;
                else if (Data == DATA_RIGHT) Direction_reg <= RIGHT;
                else                          Direction_reg <= 4'b0000; // No recognized key

                if (Direction_reg != 4'b0000) begin
                    KeyRdy_reg <= 1;     // We have a valid key
                    State      <= WAIT_READ;
                end else begin
                    // No recognized direction key pressed, go back to scanning
                    State     <= SCAN;
                    Col       <= 4'b0111;
                    col_index <= 0;
                    Data      <= 16'hFFFF;
                end
            end

            WAIT_READ: begin
                // Wait until the main controller acknowledges reading the key
                if (KeyRead) begin
                    KeyRdy_reg    <= 0;
                    Direction_reg <= 4'b0000;
                    // Return to scanning
                    State     <= SCAN;
                    Col       <= 4'b0111;
                    col_index <= 0;
                    Data      <= 16'hFFFF;
                end
            end

            default: begin
                State         <= SCAN;
                Col           <= 4'b0111;
                KeyRdy_reg    <= 0;
                Direction_reg <= 4'b0000;
                col_index     <= 0;
                Data          <= 16'hFFFF;
            end
        endcase
    end
end

endmodule