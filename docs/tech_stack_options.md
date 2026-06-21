# Tech Stack Options

Three implementation tiers were considered for this project. This document explains the trade-offs and the final decision.

## Option A — Easy

- **Tools:** Verilog + ModelSim or EDA Playground (browser-based, no install)
- **Scope:** A simple HH:MM:SS counter chain, no alarm, no display multiplexing
- **Difficulty:** Beginner
- **Expected output:** Console/waveform-only proof of counting and rollover
- **Hardware required:** No

This is the fastest path to *something working*, but it skips the alarm comparator and display logic that make the project industry-relevant and visually demonstrable.

## Option B — Recommended ✅ (this project uses this option)

- **Tools:** Verilog, Xilinx Vivado 2024.2
- **Scope:** Full counter chain + alarm comparator + seven-segment display output, targeting a real FPGA part (Artix-7 / Basys3) even if you don't have the physical board
- **Difficulty:** Intermediate
- **Expected output:** Passing simulation waveforms, synthesis + implementation reports, and (if hardware is available) a working physical demo
- **Hardware required:** No — synthesis/implementation reports from Vivado serve as proof of a working, synthesizable design even without a physical board

**Why this was selected:** it's the best balance of being genuinely industry-relevant (real comparator logic, real display driving, real FPGA targeting) while staying achievable for a course project timeline. It produces strong portfolio artifacts (RTL, testbench, waveforms, synthesis reports) regardless of whether physical hardware is on hand.

## Option C — Advanced

- **Tools:** Same as Option B, plus physical FPGA board, debounced push-button time-setting, alarm-setting mode, snooze feature, 12/24-hour toggle
- **Difficulty:** Advanced
- **Expected output:** A fully interactive physical alarm clock device
- **Hardware required:** Yes (physical Basys3 board + buttons/switches wired and debounced)

This is the natural "next step" — see the **Future Improvements** section in the main README for exactly which Option C features to add next.

## Decision

**Option B was selected** as the best fit for a student VLSI course project: it demonstrates real comparator and multiplexing logic, targets real FPGA hardware constraints, and produces a complete, verifiable, GitHub-ready artifact set — without requiring physical hardware to prove the design works.
