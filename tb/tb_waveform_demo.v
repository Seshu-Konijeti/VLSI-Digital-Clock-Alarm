// =====================================================================
// Module      : tb_waveform_demo
// Description : A SHORT, focused testbench used only to generate a
//               small, clean .vcd waveform file for documentation /
//               GitHub screenshots. The full correctness testbench is
//               tb_digital_clock_alarm_top.v (run that one for
//               pass/fail verification). This file exists purely so
//               the waveform image isn't a 25+ MB file nobody can
//               open quickly in GTKWave.
//
// What it shows:
//   1. Reset
//   2. Seconds counting 0 -> a few ticks
//   3. Seconds rollover (59 -> 0) causing minutes to increment
//   4. An alarm match event (alarm_led pulsing high)
//
// Run with:
//   iverilog -o demo_out tb/tb_waveform_demo.v rtl/*.v
//   vvp demo_out
//   gtkwave waveforms/demo_waveform.vcd
// =====================================================================

`timescale 1ns/1ps

module tb_waveform_demo;

    reg        clk;
    reg        rst;
    reg        alarm_enable;
    reg [4:0]  alarm_hour_in;
    reg [5:0]  alarm_min_in;

    wire [6:0] seg;
    wire [3:0] anode;
    wire       alarm_led;
    wire [4:0] hours_out;
    wire [5:0] minutes_out;
    wire [5:0] seconds_out;

    // Small divisor so seconds tick by quickly in simulated time
    localparam SIM_DIVISOR = 10;

    digital_clock_alarm_top #(
        .CLK_DIVISOR (SIM_DIVISOR)
    ) dut (
        .clk           (clk),
        .rst           (rst),
        .alarm_enable  (alarm_enable),
        .alarm_hour_in (alarm_hour_in),
        .alarm_min_in  (alarm_min_in),
        .seg           (seg),
        .anode         (anode),
        .alarm_led     (alarm_led),
        .hours_out     (hours_out),
        .minutes_out   (minutes_out),
        .seconds_out   (seconds_out)
    );

    always #5 clk = ~clk;

    task wait_ticks(input integer n);
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(posedge dut.u_clock_divider.tick_1hz);
                @(posedge clk);
                @(posedge clk);
            end
        end
    endtask

    initial begin
        clk           = 0;
        rst           = 1;
        alarm_enable  = 1;
        alarm_hour_in = 5'd0;
        alarm_min_in  = 6'd1;   // alarm set for 00:01:00

        repeat (5) @(posedge clk);
        rst = 0;

        wait_ticks(65); // show seconds counting, the 59->0 rollover into
                         // minute 1, and the alarm firing at 00:01:00

        $display("Demo waveform complete: h=%0d m=%0d s=%0d alarm_led=%b",
                  hours_out, minutes_out, seconds_out, alarm_led);
        $finish;
    end

    // -----------------------------------------------------------------
    // NOTE FOR VIVADO USERS: $dumpfile/$dumpvars below produce a VCD
    // file, which is the Icarus Verilog / GTKWave waveform format.
    // Vivado's XSim does NOT need this — when running this testbench
    // inside Vivado, just open the Waveform window after "Run
    // Behavioral Simulation" and drag hours_out, minutes_out,
    // seconds_out, alarm_led, seg, and anode into it directly. Vivado
    // captures everything natively in its own .wdb database. This
    // dumpfile call is harmless to leave in (Vivado will just ignore
    // or skip it), but it's not how you'll view waveforms there.
    // -----------------------------------------------------------------
    initial begin
        $dumpfile("waveforms/demo_waveform.vcd");
        $dumpvars(1, dut);
    end

endmodule
