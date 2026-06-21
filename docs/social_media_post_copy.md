# Social Media Post Copy

## LinkedIn

🕒 Just wrapped up my latest VLSI course project: a Digital Clock with Alarm Functionality, built entirely in Verilog RTL and targeting the Xilinx Artix-7 (Basys3 FPGA).

What it does:
→ Tracks real time in 24-hour format using a cascaded chain of seconds/minutes/hours counters
→ Divides a 100 MHz system clock down to a precise 1 Hz reference
→ Lets you program and arm/disarm an alarm that fires the instant the live time matches
→ Drives a time-multiplexed seven-segment display using BCD conversion

The most interesting part wasn't writing the RTL, it was verifying it. While building a self-checking testbench, I kept seeing values off by exactly one clock tick at every stage. Tracing it down taught me something concrete about synchronous design: every counter stage (and the alarm comparator) is a registered output, so a rollover pulse takes a full extra clock edge to ripple into the next stage. Once I understood that, I fixed the testbench's timing and landed all 17 automated checks passing.

Full RTL, testbench, FPGA constraints, simulation logs, and documentation are up on GitHub.

#VLSI #FPGA #Verilog #DigitalDesign #Xilinx #HardwareDesign #StudentProject #RTL #EmbeddedSystems

## Instagram

🕒 New project drop: a Digital Clock + Alarm, built from scratch in Verilog for an FPGA (Basys3 / Artix-7)!

⏱️ Counts real time, hour/minute/second rollovers and all
⏰ Programmable alarm with enable/disable
🔢 Drives a multiplexed 7-segment display
✅ 17/17 simulation checks passing

Debugging this taught me a real lesson in synchronous logic — every register adds a clock cycle of delay, and that one insight fixed a string of confusing test failures. 🛠️

Link to the full repo in bio. Student building in public, one project at a time. 💻

#VLSI #FPGA #Verilog #DigitalDesign #StudentProjects #BuildingInPublic #HardwareEngineering #ECE #Electronics
