# Simulation Guide

This project can be simulated in several environments. Since you're using **Vivado 2024.2**, start with Option 1.

## Option 1: Xilinx Vivado 2024.2 (your setup)

### A) Using the Vivado GUI

1. Open Vivado → **Create Project** → RTL Project (do not specify sources yet).
2. Add all files in `rtl/` as **Design Sources**.
3. Add `tb/tb_digital_clock_alarm_top.v` as a **Simulation Source**.
4. Set `tb_digital_clock_alarm_top` as the simulation top module (Project Settings → Simulation).
5. Click **Run Simulation → Run Behavioral Simulation**.
6. **Important:** Vivado's default simulation run length is often very short (commonly 1000 ns), which will stop the simulation long before it reaches `$finish` — the testbench needs roughly 8.66 ms of simulated time to complete all 17 checks. After the simulation window opens, either:
   - Type `run -all` in the Tcl console, or
   - Click the **Run All** button (the icon with the infinity/arrow symbol) in the simulation toolbar, instead of the default "Run" button.

   If you don't do this, the simulation will appear to "finish" early with no PASS/FAIL output, which can look like a tool problem when it's actually just the run-length setting.
7. In the waveform viewer, add `hours_out`, `minutes_out`, `seconds_out`, `alarm_led`, `seg`, `anode` to the waveform window.
8. Watch the **Tcl Console** (not the waveform window) for the `[PASS]`/`[FAIL]` log lines and the final `TESTBENCH COMPLETE` / `ALL TESTS PASSED` summary.

> **Tip:** This testbench simulates over 24 hours of clock time using a fast-forwarded divisor (~1 million clock edges total), so the run may take a noticeable amount of wall-clock time to fully complete in the GUI. Use `tb_waveform_demo.v` instead for a quick visual check of waveform behavior in under a second.

### B) Using Vivado's command-line simulator (xvlog/xelab/xsim) — faster for quick checks

From a Vivado-enabled shell (Windows: "Vivado 2024.2 Tcl Shell"; Linux: after sourcing `settings64.sh`):

```bash
cd VLSI-Digital-Clock-Alarm
xvlog rtl/*.v tb/tb_digital_clock_alarm_top.v
xelab tb_digital_clock_alarm_top -s sim_snapshot
xsim sim_snapshot -runall
```

This prints the same `[PASS]`/`[FAIL]` log directly to the terminal without opening the GUI, which is much faster for iterating.

For the small waveform demo:
```bash
xvlog rtl/*.v tb/tb_waveform_demo.v
xelab tb_waveform_demo -s demo_snapshot
xsim demo_snapshot -runall
```
(Note: `tb_waveform_demo.v`'s `$dumpfile`/`$dumpvars` calls are Icarus/GTKWave-style VCD dumping, not Vivado's native waveform mechanism — see the note in that file. For Vivado waveform viewing, use the GUI's waveform window as described in Option A instead.)

## Option 2: Icarus Verilog (no Vivado license/install needed)

Icarus Verilog (`iverilog`) is a free, open-source Verilog simulator. It was used to verify every module in this repository during development, and is a fast way to sanity-check changes before opening Vivado.

```bash
# From the project root:
iverilog -g2005 -o sim_out tb/tb_digital_clock_alarm_top.v rtl/*.v
vvp sim_out
```

Expected final lines of output:
```
=====================================================
 TESTBENCH COMPLETE: 17 checks run, 0 failures
 RESULT: ALL TESTS PASSED
=====================================================
```

To produce a small waveform file you can open in GTKWave:
```bash
iverilog -o demo_out tb/tb_waveform_demo.v rtl/*.v
vvp demo_out
gtkwave waveforms/demo_waveform.vcd
```

## Option 3: EDA Playground (no install required)

1. Go to edaplayground.com.
2. Select **Icarus Verilog 0.9.7 (or later)** as the simulator and **Verilog** as the language.
3. Paste the contents of all files from `rtl/` into the "Design" pane (or upload them).
4. Paste `tb/tb_digital_clock_alarm_top.v` into the "Testbench" pane.
5. Enable "Open EPWave after run" to get a browser-based waveform viewer.
6. Click **Run**.

## How to Verify Each Behavior in the Waveform

| What to check | Where to look |
|---|---|
| Seconds incrementing | `seconds_out` counts 0,1,2,3... once per `tick_1hz` pulse |
| Seconds rollover, minutes increments | Watch `seconds_out` go 59 to 0 at the same moment `minutes_out` increments (one cycle later, see Verification Notes below) |
| Minutes rollover, hours increments | Same pattern, one level up: `minutes_out` 59 to 0 causes `hours_out` to increment |
| Hours rollover at midnight | `hours_out` goes 23 to 0 |
| Alarm trigger | `alarm_led` pulses high for exactly one clock cycle at the moment `hours_out`/`minutes_out` match `alarm_hour_in`/`alarm_min_in` (only while `alarm_enable` is high) |

## Verification Notes: Register Latency

While building the self-checking testbench, a useful timing detail surfaced: because every counter stage (`tick_1hz`, `seconds_counter`, `minutes_counter`, `hours_counter`, `alarm_comparator`) is a **synchronous, registered** output, each stage's rollover takes one additional clock edge to ripple into the next stage. For example, `minutes_out` doesn't show its incremented value in the exact same cycle that `seconds_out` rolls over to 0 — it shows it one tick later. This is normal, correct synchronous-design behavior (not a bug), and the testbench accounts for it explicitly with documented "settle ticks." This is a good talking point in interviews, since it shows an understanding of register-transfer-level timing, not just the high-level counting logic.

## Screenshots & Logs to Capture for GitHub

- Terminal/console output showing `ALL TESTS PASSED`
- Waveform view showing the seconds-to-minutes rollover
- Waveform view showing the alarm pulse
- (If using Vivado) the Tcl console simulation log
