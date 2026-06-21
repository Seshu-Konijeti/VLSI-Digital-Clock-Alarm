// =====================================================================
// Module      : seven_seg_decoder
// Description : Converts a single 4-bit BCD digit (0-9) into the
//               7-bit pattern needed to light up segments a-g on a
//               common-cathode seven-segment display (Basys3 style).
//
// Segment map : seg = {g, f, e, d, c, b, a}   (bit 6 = g ... bit 0 = a)
// Polarity    : Basys3 seven-seg is ACTIVE-LOW, so a '0' turns a
//               segment ON. We define the patterns here in
//               active-low form to match the board directly.
// =====================================================================

module seven_seg_decoder (
    input  wire [3:0] digit,    // 0-9 BCD digit
    output reg  [6:0] seg       // active-low segment pattern {g,f,e,d,c,b,a}
);

    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default: seg = 7'b1111111; // blank / off
        endcase
    end

endmodule
