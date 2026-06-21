// =====================================================================
// Module      : hours_counter
// Description : Counts hours from 0 to 23 (24-hour format). Increments
//               once every time minutes_counter rolls over (every 60
//               minutes). Rolls over from 23 back to 0 at midnight.
// =====================================================================

module hours_counter (
    input  wire       clk,
    input  wire        rst,
    input  wire        tick_in,   // = minutes_counter.rollover
    output reg  [4:0] hours       // 0 - 23 (5 bits enough: max 23)
);

    always @(posedge clk) begin
        if (rst) begin
            hours <= 5'd0;
        end else if (tick_in) begin
            if (hours == 5'd23) begin
                hours <= 5'd0;     // midnight rollover
            end else begin
                hours <= hours + 1'b1;
            end
        end
    end

endmodule
