# Screenshots / Proof Checklist

Captured screenshots live in [`images/`](.) with descriptive filenames.

- [x] **Behavioral simulation waveform** — `01_behavioral_simulation_waveform.png` — shows `hours_out`/`minutes_out`/`seconds_out` counting, `seg`/`anode` multiplexing, `alarm_enable`/`alarm_hour_in`/`alarm_min_in` settings, and `checks`/`errors` confirming 0 failures live during the run
- [x] **Synthesis run / console output** — confirmed `ALL TESTS PASSED` in Tcl Console (17/17 checks) and clean synthesis with no errors
- [x] **Synthesized device view** — `02_synthesized_device_view.png` (post-synthesis, pre-route)
- [x] **Synthesized utilization report** — `03_utilization_report.png` — 52 LUTs, 64 registers, <1% of device (post-synthesis estimate)
- [x] **Synthesized timing summary report** — `04_timing_summary_report.png` — 0 failing endpoints, WNS 5.285 ns, WHS 0.147 ns (post-synthesis estimate, pre-route)
- [x] **Synthesized schematic** — `05_synthesized_schematic.png` — full block-level wiring, 50 cells, 43 I/O ports, 108 nets
- [x] **Synthesized power report** — `06_power_report.png` — 0.084 W total on-chip power (post-synthesis estimate)
- [x] **Implemented device view (placed & routed)** — `07_implemented_device_view.png`
- [x] **Implemented (post-route) utilization report** — `09_implemented_utilization_report.png` — 52 LUTs, 64 registers, 31 slices, confirmed real final resource usage
- [x] **Implemented (post-route) timing summary report** — `08_implemented_timing_summary.png` — 0 failing endpoints, WNS 5.468 ns, WHS 0.165 ns — this is the authoritative number proving the design meets timing on real hardware
- [x] **Implemented (post-route) power report** — `10_implemented_power_report.png` — 0.084 W, matches synthesis estimate
- [x] **Implemented schematic** — `11_implemented_schematic.png`
- [ ] **RTL code screenshot** — e.g. `digital_clock_alarm_top.v` open in your editor
- [ ] **Testbench code screenshot** — `tb_digital_clock_alarm_top.v`
- [ ] **FPGA board photo/video** — if physical hardware is available, a photo or short video of the seven-segment display counting and the alarm LED lighting up
- [ ] **GitHub repository preview** — a screenshot of the repo's main page after upload, showing the README rendered

## Tips for Good Screenshots

- Use a clean, readable editor theme (avoid tiny font sizes).
- For waveform screenshots, zoom in tight enough that signal transitions are clearly visible. A full 24-hour waveform zoomed out will just look like a flat line.
- Crop out unrelated desktop clutter before saving.
- Save waveform screenshots in `.png` format for crisp text rendering.
