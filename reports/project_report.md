# Project Report: VLSI-Based Digital Clock with Alarm Functionality

## 1. Project Objective

To design, implement, and verify a complete real-time digital clock with programmable alarm functionality entirely in synthesizable Verilog RTL, targeting the Xilinx Artix-7 (Basys3) FPGA, demonstrating core VLSI digital design principles: clock division, sequential counter design, comparator-based event logic, and time-division multiplexed display output.

## 2. Digital Clock Concept

A digital clock built in hardware tracks real time using a chain of cascaded counters driven by a divided system clock, rather than relying on software or a processor's RTC peripheral. This project implements 24-hour format time-keeping (00:00:00 - 23:59:59) using three modulo counters for seconds, minutes, and hours, each driven by the rollover (carry-out) pulse of the stage below it.

## 3. Counter Design

- **Seconds counter:** modulo-60, increments on each `tick_1hz` pulse from the clock divider, rolls over 59 to 0 with a one-cycle `rollover` pulse.
- **Minutes counter:** modulo-60, increments on the seconds counter's `rollover` pulse, rolls over 59 to 0 with its own `rollover` pulse.
- **Hours counter:** modulo-24, increments on the minutes counter's `rollover` pulse, rolls over 23 to 0 at midnight.

Each counter is a simple synchronous register with an equality check against its maximum value, reset behavior, and a registered rollover output — the same structural pattern used in cascaded BCD counter ICs.

## 4. Alarm Comparator Logic

The `alarm_comparator` module performs a continuous equality check between the live `hours`/`minutes` and the user-set `alarm_hour`/`alarm_minute`, additionally gated by `seconds == 0` (so the alarm fires for exactly one second at the start of the matching minute rather than the full 60-second window) and by `alarm_enable` (so the alarm can be armed/disarmed without altering the stored alarm time).

## 5. Seven-Segment Decoder Logic

Binary minute and second values are first converted to BCD tens/units digits via `bin_to_bcd`, then each BCD digit is converted to a 7-bit active-low segment pattern via `seven_seg_decoder`, matching the Basys3 board's common-cathode seven-segment hardware.

## 6. RTL Explanation

The design is fully modular: `clock_divider`, `seconds_counter`, `minutes_counter`, `hours_counter`, `alarm_comparator`, `bin_to_bcd`, `seven_seg_decoder`, and `display_mux` are each independent, reusable modules, integrated by `digital_clock_alarm_top`. The clock divider's divisor is parameterized (`DIVISOR`, default 100,000,000) so the same RTL can run at real hardware speed or be sped up for simulation without modifying the underlying logic.

## 7. Testbench Explanation

`tb_digital_clock_alarm_top.v` is a self-checking testbench with `check`/`check_vec` tasks that compare actual vs. expected values and log PASS/FAIL with simulation timestamps. It covers: reset behavior, seconds incrementing, seconds-to-minutes rollover, minutes-to-hours rollover, hours rollover at midnight, alarm firing on match while enabled, alarm staying silent while disabled, and alarm staying silent on time mismatch.

A separate `tb_waveform_demo.v` testbench produces a small, focused `.vcd` waveform suitable for documentation and screenshots, since the full correctness testbench simulates over 24 hours of clock time and would otherwise produce an excessively large waveform file.

## 8. Waveform Results

All 17 automated checks in the full testbench pass (see `simulation/simulation_log.txt`). The demo waveform (`waveforms/demo_waveform.vcd`) visually confirms: reset clearing all counters, seconds incrementing every tick, the seconds-to-minutes rollover at the 60-second mark, and a single-cycle alarm pulse at the programmed alarm time.

A noteworthy verification finding: every counter stage and the alarm comparator are registered outputs, so each stage's rollover/match condition takes one additional clock edge to become visible at the next stage. This is expected synchronous-design behavior and was confirmed via isolated debug testbenches before correcting the main testbench's timing expectations (see `docs/simulation_guide.md` for details).

## 9. Synthesis & Implementation Report Discussion

The design is composed entirely of small counters, a multi-input equality comparator, and simple combinational decode logic — none of which are resource- or timing-intensive. Synthesis, Implementation, and Bitstream Generation all completed cleanly with no errors in Vivado 2024.2, targeting the Artix-7 (xc7a35tcpg236-1).

### Post-Implementation Results (authoritative, post-route)

These are the real, final numbers — pulled from the **Implemented Design's** own reports (opened via Open Implemented Design → Reports, after Run Implementation completed), not the earlier synthesis-stage estimates.

**Utilization:**

| Resource | Used | Available | Utilization |
|---|---|---|---|
| Slice LUTs | 52 | 20,800 | <1% |
| Slice Registers | 64 | 41,600 | <1% |
| Slice | 31 | 8,150 | <1% |
| Bonded IOB | 43 | 106 | 41% |
| BUFGCTRL | 1 | 32 | 3% |

**Timing (100 MHz / 10 ns clock constraint, post-route):**

| Metric | Result |
|---|---|
| Worst Negative Slack (Setup) | 5.468 ns |
| Worst Hold Slack | 0.165 ns |
| Failing Endpoints (Setup) | 0 of 108 |
| Failing Endpoints (Hold) | 0 of 108 |
| Worst Pulse Width Slack | 4.500 ns |

All user-specified timing constraints are met, with zero failing endpoints across setup, hold, and pulse-width checks. This is the real, post-route result that accounts for actual wire/routing delay, and it's the number that proves the design meets timing on physical hardware — not just in simulation.

**Power (post-route):** Total on-chip power was 0.084 W, with 88% attributed to device static power and 12% dynamic. This matches the synthesis-stage estimate almost exactly, which makes sense given the design's small size and low switching frequency (the counters tick at 1 Hz, not the full 100 MHz clock).

**Notable comparison:** the post-route timing slack came out slightly *better* than the synthesis-stage estimate (WNS 5.468 ns vs. 5.285 ns at synthesis), and utilization/power held exactly steady between stages. This is a reassuring result — it confirms the synthesis-stage estimates were trustworthy for a design this small and simple, though in general post-route numbers should always be treated as the authoritative source since they account for real routing delay that synthesis estimates cannot.

<details>
<summary>Post-synthesis estimates (pre-route, kept for reference)</summary>

| Resource | Used | Available |
|---|---|---|
| Slice LUTs | 52 | 20,800 |
| Slice Registers | 64 | 41,600 |
| Bonded IOB | 43 | 106 |

| Timing Metric | Result |
|---|---|
| WNS (Setup) | 5.285 ns |
| WHS (Hold) | 0.147 ns |
| Failing Endpoints | 0 of 108 |

Power estimate: 0.084 W.

</details>

Per-module resource breakdown (post-implementation): `clock_divider` (11 LUTs / 28 FFs), `seconds_counter` (19 LUTs / 7 FFs), `minutes_counter` (15 LUTs / 7 FFs), `hours_counter` (4 LUTs / 5 FFs), `alarm_comparator` (0 LUTs / 1 FF), `display_mux` (3 LUTs / 16 FFs).

**Bitstream generation note:** the first bitstream attempt failed DRC checks `NSTD-1` (Unspecified I/O Standard) and `UCIO-1` (Unconstrained Logical Port) on `hours_out[4:0]`, `minutes_out[5:0]`, and `seconds_out[5:0]` — 17 of 43 top-level ports. These three buses are exposed on the top module for simulation/waveform debugging only and are intentionally not wired to physical pins on real hardware (the design displays time via the seven-segment digits instead). The fix was adding `set_property BITSTREAM.GENERAL.UNCONSTRAINEDPINS {Allow} [current_design]` to the constraints file, after which bitstream generation completed successfully. This is now documented in `docs/fpga_implementation_guide.md` as a known troubleshooting step.

## 10. Conclusion

This project successfully implements a complete, verified, real-time digital clock with alarm functionality entirely in RTL, covering the full design flow from clock division through FPGA-ready synthesis and implementation. It demonstrates practical command of sequential counter design, comparator-based event logic, BCD conversion, and display multiplexing — core building blocks shared by real-time clock ICs, embedded timer peripherals, and FPGA-based control systems across consumer and industrial electronics.
