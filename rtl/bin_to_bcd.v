// =====================================================================
// Module      : bin_to_bcd
// Description : Converts a binary value (0-59 max) into two BCD
//               digits: tens and units. Needed because the seven-
//               segment display shows decimal digits, not binary.
//
// Example     : minutes = 45 (binary 101101)
//               -> tens = 4, units = 5
//
// Note        : Since our max input is 59, a simple combinational
//               divide/modulo by 10 is small enough to synthesize
//               efficiently (no need for a full shift-add-3 BCD
//               algorithm here).
// =====================================================================

module bin_to_bcd (
    input  wire [5:0] bin_value,   // 0-59
    output wire [3:0] tens,        // 0-5
    output wire [3:0] units        // 0-9
);

    assign tens  = bin_value / 10;
    assign units = bin_value % 10;

endmodule
