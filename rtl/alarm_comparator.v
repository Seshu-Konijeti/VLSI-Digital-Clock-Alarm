// =====================================================================
// Module      : alarm_comparator
// Description : Compares the LIVE current time (hours:minutes) against
//               a user-programmed alarm time (alarm_hour:alarm_minute).
//               When they match AND alarm_enable is asserted AND
//               seconds == 0 (so the alarm fires once per matching
//               minute, not 60 times), alarm_out goes high.
//
// Concept     : This is a pure combinational/registered comparator -
//               the same building block used in RTC ICs, microwave
//               timers, and industrial timer relays.
//
// Design note : We gate on seconds == 0 so the alarm pulses for one
//               full second at the start of the matching minute,
//               instead of staying high for the entire 60-second
//               window (which would be a less realistic alarm clock
//               behavior).
// =====================================================================

module alarm_comparator (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  hours,         // current hour   (0-23)
    input  wire [5:0]  minutes,       // current minute (0-59)
    input  wire [5:0]  seconds,       // current second (0-59)
    input  wire [4:0]  alarm_hour,    // alarm hour set by user   (0-23)
    input  wire [5:0]  alarm_minute,  // alarm minute set by user (0-59)
    input  wire         alarm_enable,  // 1 = alarm armed, 0 = alarm disabled
    output reg          alarm_out      // 1 = alarm is currently ringing
);

    wire time_match;

    // Combinational match check: does current HH:MM equal alarm HH:MM?
    assign time_match = (hours   == alarm_hour)   &&
                         (minutes == alarm_minute) &&
                         (seconds  == 6'd0);

    always @(posedge clk) begin
        if (rst) begin
            alarm_out <= 1'b0;
        end else if (alarm_enable && time_match) begin
            alarm_out <= 1'b1;
        end else begin
            alarm_out <= 1'b0;
        end
    end

endmodule
