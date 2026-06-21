// =====================================================================
// Module      : seconds_counter
// Description : Counts seconds from 0 to 59. On reaching 59 and
//               receiving the next tick, it rolls over to 0 and
//               asserts 'rollover' for exactly one cycle, which the
//               minutes counter uses as its own "tick" input.
//
// Concept     : This is a modulo-60 (mod-60) BCD-friendly counter.
//               It demonstrates the classic VLSI counter design
//               pattern used in every real-time clock IC.
// =====================================================================

module seconds_counter (
    input  wire       clk,
    input  wire        rst,
    input  wire        tick_1hz,   // 1 Hz enable pulse from clock_divider
    output reg  [5:0] seconds,    // 0 - 59 (6 bits enough: max 59)
    output reg         rollover    // pulses high for 1 cycle when 59 -> 0
);

    always @(posedge clk) begin
        if (rst) begin
            seconds  <= 6'd0;
            rollover <= 1'b0;
        end else if (tick_1hz) begin
            if (seconds == 6'd59) begin
                seconds  <= 6'd0;
                rollover <= 1'b1;   // tell minutes_counter to increment
            end else begin
                seconds  <= seconds + 1'b1;
                rollover <= 1'b0;
            end
        end else begin
            rollover <= 1'b0;       // rollover is a single-cycle pulse
        end
    end

endmodule
