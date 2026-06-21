// =====================================================================
// Module      : minutes_counter
// Description : Counts minutes from 0 to 59. Increments once every
//               time the seconds_counter rolls over (i.e., every 60
//               seconds). On reaching 59 and getting another tick,
//               it rolls over to 0 and pulses 'rollover' which drives
//               the hours_counter.
// =====================================================================

module minutes_counter (
    input  wire       clk,
    input  wire        rst,
    input  wire        tick_in,    // = seconds_counter.rollover
    output reg  [5:0] minutes,    // 0 - 59
    output reg         rollover    // pulses high for 1 cycle when 59 -> 0
);

    always @(posedge clk) begin
        if (rst) begin
            minutes  <= 6'd0;
            rollover <= 1'b0;
        end else if (tick_in) begin
            if (minutes == 6'd59) begin
                minutes  <= 6'd0;
                rollover <= 1'b1;   // tell hours_counter to increment
            end else begin
                minutes  <= minutes + 1'b1;
                rollover <= 1'b0;
            end
        end else begin
            rollover <= 1'b0;
        end
    end

endmodule
