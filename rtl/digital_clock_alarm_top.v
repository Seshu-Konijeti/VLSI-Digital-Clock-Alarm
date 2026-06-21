// =====================================================================
// Module      : digital_clock_alarm_top
// Description : Top-level module for the VLSI-Based Digital Clock
//               with Alarm Functionality. Connects all submodules:
//
//                 clk (100 MHz)
//                   |
//                   v
//               clock_divider --tick_1hz--> seconds_counter
//                                                |
//                                          rollover (every 60s)
//                                                v
//                                          minutes_counter
//                                                |
//                                          rollover (every 60m)
//                                                v
//                                          hours_counter
//                                                |
//                          hours, minutes, seconds ---+
//                                                       v
//                                              alarm_comparator --> alarm_out
//                                                       |
//                                          bin_to_bcd (x2) --> seven_seg
//                                                       |
//                                              display_mux --> seg, anode
//
// Board       : Xilinx Artix-7 (Basys3)
// Display     : Shows MM:SS by default (minutes:seconds) on the 4
//               available seven-segment digits. Hours are exposed as
//               a top-level output (hours_out) for simulation /
//               waveform verification and can be wired to extra LEDs.
// =====================================================================

module digital_clock_alarm_top #(
    // Pass-through parameter: override for fast simulation, e.g.
    // digital_clock_alarm_top #(.CLK_DIVISOR(10)) u_dut (...)
    // Default = 100,000,000 for real 100 MHz Basys3 hardware.
    parameter integer CLK_DIVISOR = 100_000_000
) (
    input  wire        clk,            // 100 MHz Basys3 system clock
    input  wire        rst,            // active-high reset (BTN center)
    input  wire        alarm_enable,   // switch SW0: arm/disarm alarm
    input  wire [4:0]  alarm_hour_in,  // switches: alarm hour setting   (0-23)
    input  wire [5:0]  alarm_min_in,   // switches: alarm minute setting (0-59)

    output wire [6:0]  seg,            // seven-seg segment lines (active-low)
    output wire [3:0]  anode,          // seven-seg digit select (active-low)
    output wire        alarm_led,      // LED that lights when alarm rings
    output wire [4:0]  hours_out,      // current hour   (for sim/debug/LEDs)
    output wire [5:0]  minutes_out,    // current minute (for sim/debug)
    output wire [5:0]  seconds_out     // current second (for sim/debug)
);

    // -----------------------------------------------------------------
    // Internal wires connecting the time-keeping chain
    // -----------------------------------------------------------------
    wire        tick_1hz;
    wire        sec_rollover;
    wire        min_rollover;
    wire [5:0]  seconds;
    wire [5:0]  minutes;
    wire [4:0]  hours;
    wire        alarm_out;

    assign hours_out   = hours;
    assign minutes_out = minutes;
    assign seconds_out = seconds;
    assign alarm_led   = alarm_out;

    // -----------------------------------------------------------------
    // 1. Clock divider: 100 MHz -> 1 Hz tick
    // -----------------------------------------------------------------
    clock_divider #(
        .DIVISOR (CLK_DIVISOR)
    ) u_clock_divider (
        .clk      (clk),
        .rst      (rst),
        .tick_1hz (tick_1hz)
    );

    // -----------------------------------------------------------------
    // 2. Seconds counter (0-59)
    // -----------------------------------------------------------------
    seconds_counter u_seconds_counter (
        .clk      (clk),
        .rst      (rst),
        .tick_1hz (tick_1hz),
        .seconds  (seconds),
        .rollover (sec_rollover)
    );

    // -----------------------------------------------------------------
    // 3. Minutes counter (0-59), driven by seconds rollover
    // -----------------------------------------------------------------
    minutes_counter u_minutes_counter (
        .clk      (clk),
        .rst      (rst),
        .tick_in  (sec_rollover),
        .minutes  (minutes),
        .rollover (min_rollover)
    );

    // -----------------------------------------------------------------
    // 4. Hours counter (0-23), driven by minutes rollover
    // -----------------------------------------------------------------
    hours_counter u_hours_counter (
        .clk     (clk),
        .rst     (rst),
        .tick_in (min_rollover),
        .hours   (hours)
    );

    // -----------------------------------------------------------------
    // 5. Alarm comparator
    // -----------------------------------------------------------------
    alarm_comparator u_alarm_comparator (
        .clk          (clk),
        .rst          (rst),
        .hours        (hours),
        .minutes      (minutes),
        .seconds      (seconds),
        .alarm_hour   (alarm_hour_in),
        .alarm_minute (alarm_min_in),
        .alarm_enable (alarm_enable),
        .alarm_out    (alarm_out)
    );

    // -----------------------------------------------------------------
    // 6. BCD conversion for display (showing MM:SS on 4 digits)
    // -----------------------------------------------------------------
    wire [3:0] sec_tens, sec_units, min_tens, min_units;

    bin_to_bcd u_bcd_seconds (
        .bin_value (seconds),
        .tens      (sec_tens),
        .units     (sec_units)
    );

    bin_to_bcd u_bcd_minutes (
        .bin_value (minutes),
        .tens      (min_tens),
        .units     (min_units)
    );

    // -----------------------------------------------------------------
    // 7. Display multiplexer + seven-segment decoder
    // -----------------------------------------------------------------
    wire [3:0] bcd_selected;

    display_mux u_display_mux (
        .clk     (clk),
        .rst     (rst),
        .digit0  (sec_units),   // rightmost  = seconds units
        .digit1  (sec_tens),    // seconds tens
        .digit2  (min_units),   // minutes units
        .digit3  (min_tens),    // leftmost   = minutes tens
        .anode   (anode),
        .bcd_out (bcd_selected)
    );

    seven_seg_decoder u_seven_seg_decoder (
        .digit (bcd_selected),
        .seg   (seg)
    );

endmodule
