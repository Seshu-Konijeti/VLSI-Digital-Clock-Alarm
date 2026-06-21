// =====================================================================
// Module      : clock_divider
// Description : Divides the 100 MHz Basys3 system clock down to a
//               precise 1 Hz "tick" pulse that drives the seconds
//               counter. One tick = exactly one real-world second.
//
// Concept     : FPGA boards only give you a fast system clock
//               (100 MHz on Basys3). A digital clock needs to count
//               in real seconds, so we need a clock divider that
//               counts 100,000,000 fast-clock edges and then pulses
//               once. That pulse is what the rest of the design uses
//               as its "1-second heartbeat".
//
// Author      : Seshuu (VLSI Course Project)
// =====================================================================

module clock_divider #(
    // DIVISOR = number of clk edges per output tick.
    // Default = 100,000,000 for real hardware (100 MHz -> 1 Hz).
    // For SIMULATION ONLY, instantiate with a small override, e.g.
    // clock_divider #(.DIVISOR(10)) so the testbench doesn't have to
    // wait 100 million real clock edges to see one "second" tick.
    // The RTL logic exercised is identical either way - only the
    // count value changes.
    parameter integer DIVISOR = 100_000_000
) (
    input  wire clk,        // 100 MHz board clock (Basys3 system clock)
    input  wire rst,        // synchronous active-high reset
    output reg  tick_1hz    // goes high for exactly 1 clk cycle every 1 second
);

    // 27 bits is enough to count up to 100,000,000 (2^27 = 134,217,728)
    reg [26:0] count_reg;

    always @(posedge clk) begin
        if (rst) begin
            count_reg <= 27'd0;
            tick_1hz  <= 1'b0;
        end else begin
            if (count_reg == DIVISOR - 1) begin
                count_reg <= 27'd0;
                tick_1hz  <= 1'b1;   // pulse high for one clk cycle
            end else begin
                count_reg <= count_reg + 1'b1;
                tick_1hz  <= 1'b0;
            end
        end
    end

endmodule
