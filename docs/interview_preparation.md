# Interview Preparation

## Q1. Explain your project.

I built a VLSI-based digital clock with alarm functionality in Verilog, targeting a Xilinx Artix-7 FPGA (Basys3 board). The system takes a 100 MHz board clock and divides it down to a 1 Hz tick using a clock divider. That tick drives a chain of modulo counters: a seconds counter (0–59), which rolls over into a minutes counter (0–59), which rolls over into an hours counter (0–23) for full 24-hour time. There's also an alarm comparator that continuously checks the live time against a user-programmed alarm time and fires an alarm signal the moment they match, gated by an enable switch. For display, I convert the binary minute/second values to BCD and drive a time-multiplexed seven-segment display, since the board only has a few shared segment lines for four digits. I verified the whole design with a self-checking testbench in simulation, and prepared it for real FPGA synthesis with a constraints file mapping every signal to a physical Basys3 pin.

## Q2. Why did you divide the clock instead of using the 100 MHz clock directly for your counters?

The 100 MHz clock is far too fast for a human-readable time display — it would increment "seconds" 100 million times per second. The clock divider counts 100,000,000 clock edges and then emits a single-cycle pulse, giving the rest of the design a clean 1 Hz reference to count real seconds against, the same technique RTC ICs and timer peripherals use internally.

## Q3. How does your alarm logic avoid triggering for the entire 60-second window once the time matches?

The comparator checks `seconds == 0` as part of the match condition, so it only fires once, at the very start of the matching minute, instead of staying high for all 60 seconds within that minute. This makes the alarm behave like a single, clean trigger event rather than a sustained signal.

## Q4. Walk me through what happens when the seconds counter rolls over from 59 to 0.

When the seconds counter is at 59 and receives the next tick, instead of incrementing to 60 it resets to 0 and asserts a single-cycle `rollover` pulse. That pulse is wired directly into the minutes counter's tick input, so the minutes counter only increments once every 60 seconds, driven by that rollover pulse rather than the raw clock or the 1 Hz tick.

## Q5. What was the trickiest bug you encountered, and how did you debug it?

While writing the self-checking testbench, my expected values kept failing by exactly one tick at every stage: seconds, minutes, hours, and the alarm. I traced it down to register latency: `tick_1hz` itself is a registered output of the clock divider, and each counter stage (seconds, minutes, hours, alarm comparator) is also a synchronous register. So a rollover pulse takes a full additional clock edge to propagate into the next stage's visible output. I confirmed this by writing a small isolated testbench that printed the clock, tick, and counter value cycle-by-cycle, which showed the exact delay. Once I understood the latency was a real, expected property of synchronous design and not a bug in the counters, I fixed the testbench's wait logic to account for the settle time at each stage, and all 17 checks passed.

## Q6. Why did you use a parameter for the clock divisor instead of hardcoding 100,000,000?

Simulating 100 million clock edges per second of real time would make the testbench impractically slow. By making `DIVISOR` a parameter with a default of 100,000,000 for real hardware, the testbench can override it to a small value (like 10) to exercise exactly the same RTL logic in a fraction of the simulation time, while the synthesized hardware still uses the correct real-world divisor.

## Q7. How does your seven-segment display show all four digits using only one set of segment outputs?

I used time-division multiplexing. The Basys3 board's four digits share the same seven segment lines, with only the active-low anode signal selecting which digit is currently powered. My `display_mux` module rapidly cycles through all four digits, much faster than the human eye can perceive, driving the correct BCD value and anode signal for whichever digit is currently selected. The persistence of vision makes it look like all four digits are lit simultaneously.

## Q8. What would you change if you had to support a 12-hour AM/PM display instead of 24-hour?

I'd add a conversion stage between the hours counter and the display logic: when hours is 0, display 12 (AM); when hours is greater than 12, subtract 12 for display; and derive an AM/PM flag as `hours >= 12`. The underlying hours_counter would stay as a 0-23 counter internally, since that keeps the alarm comparator logic simple and unambiguous; only the display layer would need to translate to 12-hour format.

## Q9. How would you verify your design actually meets timing on real hardware, not just in simulation?

After synthesis and implementation in Vivado, I'd check the Timing Summary report for setup and hold slack at the 100 MHz clock constraint defined in the XDC file. Since this design is a small counter-and-comparator system with no complex combinational paths, I'd expect comfortable positive slack, but I'd still check the report rather than assume it, since the seven-segment decoder's case statement and the alarm comparator's multi-input equality check are the most likely places for a longer combinational path.

## Q10. What's the difference between the `rollover` signal and the `tick_1hz` signal in your design?

`tick_1hz` is the global one-second heartbeat generated once by the clock divider, and it's the input to the seconds counter only. `rollover` is a per-stage carry-out signal: the seconds counter's rollover is its own "I just wrapped from 59 to 0" pulse, which becomes the input tick for the minutes counter, and similarly the minutes counter's rollover becomes the input tick for the hours counter. So `tick_1hz` is the root timing reference, while `rollover` signals are the cascaded carry pulses that propagate up the counter chain.
