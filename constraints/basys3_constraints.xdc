## =====================================================================
## File        : basys3_constraints.xdc
## Board       : Digilent Basys3 (Xilinx Artix-7 XC7A35T-1CPG236C)
## Project     : VLSI-Based Digital Clock with Alarm Functionality
##
## Pin mapping reference: Digilent Basys3 Master XDC file
## (https://digilent.com/reference/programmable-logic/basys-3/start)
##
## Usage: In Vivado, add this file under Constraints in your project,
## then run Synthesis -> Implementation -> Generate Bitstream.
## =====================================================================

## ---------------------------------------------------------------------
## System Clock (100 MHz) - clk
## ---------------------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---------------------------------------------------------------------
## Reset - rst  (Center push button, BTNC)
## ---------------------------------------------------------------------
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## ---------------------------------------------------------------------
## Alarm Enable - alarm_enable (Switch SW0)
## ---------------------------------------------------------------------
set_property PACKAGE_PIN V17 [get_ports alarm_enable]
set_property IOSTANDARD LVCMOS33 [get_ports alarm_enable]

## ---------------------------------------------------------------------
## Alarm Hour Setting - alarm_hour_in[4:0] (Switches SW1-SW5)
## ---------------------------------------------------------------------
set_property PACKAGE_PIN V16 [get_ports {alarm_hour_in[0]}]
set_property PACKAGE_PIN W16 [get_ports {alarm_hour_in[1]}]
set_property PACKAGE_PIN W17 [get_ports {alarm_hour_in[2]}]
set_property PACKAGE_PIN W15 [get_ports {alarm_hour_in[3]}]
set_property PACKAGE_PIN V15 [get_ports {alarm_hour_in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_hour_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_hour_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_hour_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_hour_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_hour_in[4]}]

## ---------------------------------------------------------------------
## Alarm Minute Setting - alarm_min_in[5:0] (Switches SW6-SW11)
## ---------------------------------------------------------------------
set_property PACKAGE_PIN W14 [get_ports {alarm_min_in[0]}]
set_property PACKAGE_PIN W13 [get_ports {alarm_min_in[1]}]
set_property PACKAGE_PIN V2  [get_ports {alarm_min_in[2]}]
set_property PACKAGE_PIN T3  [get_ports {alarm_min_in[3]}]
set_property PACKAGE_PIN T2  [get_ports {alarm_min_in[4]}]
set_property PACKAGE_PIN R3  [get_ports {alarm_min_in[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {alarm_min_in[5]}]

## ---------------------------------------------------------------------
## Seven-Segment Display Segments - seg[6:0] {g,f,e,d,c,b,a}
## ---------------------------------------------------------------------
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## ---------------------------------------------------------------------
## Seven-Segment Digit Select (Anodes) - anode[3:0]
## ---------------------------------------------------------------------
set_property PACKAGE_PIN U2 [get_ports {anode[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]

## ---------------------------------------------------------------------
## Alarm LED - alarm_led (Onboard LED0)
## ---------------------------------------------------------------------
set_property PACKAGE_PIN U16 [get_ports alarm_led]
set_property IOSTANDARD LVCMOS33 [get_ports alarm_led]

## ---------------------------------------------------------------------
## Config / Bitstream settings (recommended defaults for Basys3)
## ---------------------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## ---------------------------------------------------------------------
## Debug-only outputs (hours_out, minutes_out, seconds_out) are exposed
## on the top module purely for simulation/waveform inspection and are
## NOT wired to any physical pin on real hardware (the design only
## displays time through the seven-segment digits). Without this
## property, Vivado's DRC blocks bitstream generation with:
##   [DRC NSTD-1] Unspecified I/O Standard
##   [DRC UCIO-1] Unconstrained Logical Port
## on hours_out[4:0], minutes_out[5:0], seconds_out[5:0] (17 of 43
## ports). This line tells Vivado those ports are intentionally left
## unconstrained and to proceed anyway.
## ---------------------------------------------------------------------
set_property BITSTREAM.GENERAL.UNCONSTRAINEDPINS {Allow} [current_design]
