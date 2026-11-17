<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 5-state overlapping finite state machine (FSM) that detects the binary sequence 1101 on the serial input a (ui_in[0]):

States: s0 (000), s1 (001), s2 (010), s3 (011), and s4 (100).
Reset: Pulling rst_n low (0) resets the FSM to s0 and clears the output y (uo_out[0]) to 0.
Operation: On every rising edge of clk, the FSM advances based on ui_in[0]. When the next state evaluates to s4 (indicating 1101 has been received), the registered output uo_out[0] goes high (1) on that clock edge. Overlapping sequences are supported: receiving 1 in s4 transitions to s2.

## How to test
Apply a clock signal to clk (for example, 50 MHz / 20 ns period) and set ena high (1).
Hold rst_n low (0) to reset the FSM, then release rst_n high (1).
Apply the bit sequence 1, 1, 0, 1 to ui_in[0], changing one bit per clock cycle.
Observe uo_out[0]: it goes high (1) on the clock edge when the fourth bit (1) is sampled, and returns low (0) on following cycles unless another overlapping 1101 sequence is completed.

## External hardwar

No external hardware is required. The input ui_in[0] and output uo_out[0] can be driven and observed directly using the Tiny Tapeout demo board or test harness.
