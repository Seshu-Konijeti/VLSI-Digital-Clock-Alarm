// =====================================================================
// Module      : display_mux
// Description : The Basys3 board has 4 seven-segment digits that
//               SHARE the same 7 segment lines. Only one digit can be
//               lit at a time, so we rapidly scan through all 4
//               digits (fast enough that the human eye sees them as
//               simultaneously lit - this is called time-division
//               multiplexing / persistence of vision).
//
//               Digit layout on display: [MM tens][MM units][SS tens][SS units]
//               (Minutes:Seconds shown by default - see top module)
//
// Concept     : Multiplexing is a core VLSI/digital design technique
//               used to drive many outputs with few physical pins.
// =====================================================================

module display_mux (
    input  wire       clk,
    input  wire        rst,
    input  wire [3:0] digit0,   // rightmost digit  (seconds units)
    input  wire [3:0] digit1,   // seconds tens
    input  wire [3:0] digit2,   // minutes units
    input  wire [3:0] digit3,   // leftmost digit   (minutes tens)
    output reg  [3:0] anode,    // active-low: selects which digit is powered
    output wire [3:0] bcd_out   // currently selected digit's BCD value
);

    // Refresh counter: scans through digits fast enough to avoid flicker.
    // 100 MHz / 2^16 ~= 1.5 kHz per-digit refresh - well above flicker threshold.
    reg [15:0] refresh_counter;
    wire [1:0] digit_select;

    always @(posedge clk) begin
        if (rst)
            refresh_counter <= 16'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    assign digit_select = refresh_counter[15:14]; // top 2 bits cycle 0,1,2,3

    // Select which digit's BCD value is currently being displayed
    reg [3:0] bcd_sel;
    always @(*) begin
        case (digit_select)
            2'b00: bcd_sel = digit0;
            2'b01: bcd_sel = digit1;
            2'b10: bcd_sel = digit2;
            2'b11: bcd_sel = digit3;
        endcase
    end
    assign bcd_out = bcd_sel;

    // Active-low anode select: only one digit powered at a time
    always @(*) begin
        case (digit_select)
            2'b00: anode = 4'b1110; // enable digit0 (rightmost)
            2'b01: anode = 4'b1101; // enable digit1
            2'b10: anode = 4'b1011; // enable digit2
            2'b11: anode = 4'b0111; // enable digit3 (leftmost)
        endcase
    end

endmodule
