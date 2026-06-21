# Vivado FPGA Implementation Guide — Project Creation to Bitstream
### Digital Clock with Alarm | Vivado 2024.2 | Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)

This is the complete, sequential walkthrough: create the project, add sources, wire every signal to its physical pin, synthesize, implement, generate the bitstream, and program the board. Every pin below is verified against Digilent's official `Basys3_Master.xdc`.

---

## Step 1 — Create the Vivado Project

1. Open Vivado 2024.2 → **File → New Project**.
2. Project name: `VLSI_Digital_Clock_Alarm`. Choose any local directory.
3. Project type: **RTL Project**. Check **"Do not specify sources at this time"** — sources are added in Step 2.
4. Default Part: click the **Boards** tab and search **"Basys3"** if you have the board file installed (this auto-loads the correct part and I/O voltage settings). If the board file isn't installed, use the **Parts** tab instead and select part **xc7a35tcpg236-1**.
5. Click **Finish**.

> If "Basys3" doesn't appear under Boards, you can still proceed using the Parts tab — board files only add convenience presets, they aren't required to build a working design.

## Step 2 — Add RTL Design Sources

1. In the Flow Navigator, click **Add Sources → Add or Create Design Sources → Next**.
2. Click **Add Files** and select every file from `rtl/`:
   - `clock_divider.v`
   - `seconds_counter.v`
   - `minutes_counter.v`
   - `hours_counter.v`
   - `alarm_comparator.v`
   - `bin_to_bcd.v`
   - `seven_seg_decoder.v`
   - `display_mux.v`
   - `digital_clock_alarm_top.v`
3. Leave **"Copy sources into project"** checked, then click **Finish**.
4. In the **Sources** panel, right-click `digital_clock_alarm_top` → **Set as Top**.

## Step 3 — Add the Simulation Testbench

1. **Add Sources → Add or Create Simulation Sources → Next**.
2. Add `tb/tb_digital_clock_alarm_top.v`.
3. Click **Finish**. Vivado will ask which file is the simulation top — confirm `tb_digital_clock_alarm_top`.

*(This step is for simulation only — see `docs/simulation_guide.md` for running it. It is not required for synthesis/implementation/bitstream, but it's good practice to keep it in the project.)*

## Step 4 — Add the Constraints File

1. **Add Sources → Add or Create Constraints → Next**.
2. Add `constraints/basys3_constraints.xdc`.
3. Click **Finish**.

This file already contains every pin mapping needed (table below) — you do **not** need to manually re-enter pins if you use it as-is.

---

## Complete Pin-to-Pin Mapping Table

This is the full mapping from every top-level port in `digital_clock_alarm_top` to its physical Basys3 pin, exactly as encoded in `constraints/basys3_constraints.xdc`. Verified against Digilent's official `Basys3_Master.xdc`.

### Clock and Reset

| Top-level port | Basys3 control | FPGA Pin | Function |
|---|---|---|---|
| `clk` | onboard oscillator | **W5** | 100 MHz system clock |
| `rst` | BTNC (center button) | **U18** | Active-high reset |

### Alarm Controls (switches)

| Top-level port | Basys3 switch | FPGA Pin |
|---|---|---|
| `alarm_enable` | SW0 | **V17** |
| `alarm_hour_in[0]` | SW1 | **V16** |
| `alarm_hour_in[1]` | SW2 | **W16** |
| `alarm_hour_in[2]` | SW3 | **W17** |
| `alarm_hour_in[3]` | SW4 | **W15** |
| `alarm_hour_in[4]` | SW5 | **V15** |
| `alarm_min_in[0]` | SW6 | **W14** |
| `alarm_min_in[1]` | SW7 | **W13** |
| `alarm_min_in[2]` | SW8 | **V2** |
| `alarm_min_in[3]` | SW9 | **T3** |
| `alarm_min_in[4]` | SW10 | **T2** |
| `alarm_min_in[5]` | SW11 | **R3** |

> Switches SW1–SW5 form a 5-bit binary value (0–23) for the alarm hour; SW6–SW11 form a 6-bit binary value (0–59) for the alarm minute. Set them in plain binary — e.g., for an alarm hour of 7, set SW5..SW1 = `00111`.

### Seven-Segment Display

| Top-level port | Display signal | FPGA Pin |
|---|---|---|
| `seg[0]` | segment a | **W7** |
| `seg[1]` | segment b | **W6** |
| `seg[2]` | segment c | **U8** |
| `seg[3]` | segment d | **V8** |
| `seg[4]` | segment e | **U5** |
| `seg[5]` | segment f | **V5** |
| `seg[6]` | segment g | **U7** |
| `anode[0]` | digit 0 (rightmost) | **U2** |
| `anode[1]` | digit 1 | **U4** |
| `anode[2]` | digit 2 | **V4** |
| `anode[3]` | digit 3 (leftmost) | **W4** |

### Alarm Output

| Top-level port | Basys3 LED | FPGA Pin |
|---|---|---|
| `alarm_led` | LED0 | **U16** |

### IOSTANDARD and Clock Constraint (already in the XDC)

Every pin above uses `IOSTANDARD LVCMOS33` (Basys3's bank voltage). The 100 MHz clock is additionally declared with:
```tcl
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```
This tells Vivado the clock period is 10 ns (100 MHz) so timing analysis can check setup/hold against the real clock speed.

---

## Step 5 — Run Synthesis

1. In the Flow Navigator, click **Run Synthesis**.
2. Vivado will run RTL synthesis (this design is small, so this should take well under a minute).
3. When the **Synthesis Completed** dialog appears, select **View Reports** (or open later via **Open Synthesized Design**).
4. Check these reports under **Reports**:
   - **Utilization Report** — confirms LUT/FF usage (expect well under 1% of the device — this is a small counter/comparator design).
   - **Timing Summary** — confirms no setup/hold violations against the 100 MHz `create_clock` constraint.

> **Important — these are pre-route estimates, not final numbers.** The reports here are generated from the synthesized netlist before place-and-route, so timing in particular doesn't yet include real wire/routing delay. They're a useful early sanity check, but don't treat them as proof the design meets timing on real hardware — that requires the *post-implementation* reports in Step 6.

## Step 6 — Run Implementation

1. Click **Run Implementation** in the Flow Navigator.
2. This performs place-and-route, mapping the synthesized netlist onto actual Artix-7 logic resources and routing it according to the pin constraints from Step 4.
3. When complete, select **Open Implemented Design** to pull the *authoritative* reports:
   - **Reports → Timing → Report Timing Summary** — this is the real, post-route timing result. This is the number that actually proves the design meets timing on hardware, not the synthesis-stage estimate from Step 5.
   - **Reports → Utilization → Report Utilization** — final, exact resource usage after placement (may differ slightly from the synthesis estimate).
   - **Reports → Power → Report Power** — power estimate based on real routing, more accurate than the synthesis-stage figure.
   - **I/O Ports** report — confirm every port landed on the pin you expect (cross-check against the pin table above).
   - **Device** layout — view the physical placement and routing on the chip.

> **Common mistake:** it's easy to run synthesis, grab utilization/timing/power screenshots there, then move straight to Generate Bitstream without ever opening the *Implemented Design's* own reports. Both sets of reports are legitimate and worth capturing, but only the post-implementation ones reflect the real, placed-and-routed hardware. This project captured both (see `images/`): synthesis-stage estimates showed WNS 5.285 ns, and the real post-route result came back at WNS 5.468 ns — slightly better, but only the post-route number is the one to cite as proof the design meets timing on hardware.

## Step 7 — Generate Bitstream

1. Click **Generate Bitstream** in the Flow Navigator.
2. Vivado will run a final DRC (design rule check) and produce a `.bit` file.
3. Output location: `<project_dir>/<project_name>.runs/impl_1/digital_clock_alarm_top.bit`.
4. When the **Bitstream Generation Completed** dialog appears, you can either close it or click **Open Hardware Manager** to proceed directly to programming (Step 8).

### Troubleshooting: "Bitstream Generation Failed" with DRC NSTD-1 / UCIO-1

If bitstream generation fails with errors like:
```
[DRC NSTD-1] Unspecified I/O Standard: ... ports use I/O standard 'DEFAULT' ...
[DRC UCIO-1] Unconstrained Logical Port: ... ports have no user assigned location constraint (LOC) ...
```
on `hours_out`, `minutes_out`, or `seconds_out` — this is expected and already handled in `constraints/basys3_constraints.xdc`. Those three signals are exposed on the top module purely for simulation/waveform debugging (see `digital_clock_alarm_top.v`) and are intentionally **not** wired to any physical pin, since the design displays time through the seven-segment digits instead. Vivado's DRC flags any top-level port with no pin/IOSTANDARD assignment by default, since an unconstrained port is normally a sign of a forgotten connection.

The fix already included in the constraints file is:
```tcl
set_property BITSTREAM.GENERAL.UNCONSTRAINEDPINS {Allow} [current_design]
```
This tells Vivado those ports are deliberately left unconstrained. If you're using an older copy of the XDC without this line, add it and re-run **Generate Bitstream**.

## Step 8 — Program the FPGA Board (if hardware is available)

1. Connect the Basys3 board to your computer via the USB programming cable and power it on.
2. In Vivado: **Open Hardware Manager → Open Target → Auto Connect**. Vivado should detect the board (`xc7a35t_0`).
3. Right-click the device → **Program Device**.
4. In the dialog, confirm the bitstream file path points to the `.bit` file from Step 7, then click **Program**.
5. Once programming completes, test the board:
   - Press **BTNC** (center button) → display resets to `00:00` and starts counting MM:SS.
   - Set **SW1–SW5** to a binary alarm hour and **SW6–SW11** to a binary alarm minute.
   - Flip **SW0** up to arm the alarm.
   - When the live time (visible on the seven-segment display) matches your alarm setting, **LED0** lights up for one second.

## Step 9 — If Physical Hardware Is Not Available

The completed flow above through Step 7 (bitstream generation with no synthesis/implementation errors) is itself strong, verifiable proof of a working, synthesizable design:

- A clean **synthesis report** with no errors proves the RTL is actually synthesizable hardware, not just simulate-able code.
- A clean **post-route timing report** with positive slack at 100 MHz proves the design would meet real hardware timing if programmed.
- The **utilization report** proves the design fits comfortably on real silicon.
- The **bitstream file** itself is the literal, physical-hardware-ready output of the entire RTL-to-FPGA flow.

Combined with the passing simulation testbench (`simulation/simulation_log.txt`), these artifacts are commonly accepted as complete proof-of-work for a student FPGA project. Screenshot each report per the checklist in `docs/screenshots_checklist.md` and upload them to GitHub under `images/`.
