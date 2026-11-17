# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 20 ns (50 MHz), matching mealy_tb
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    # Output must be 0 after reset
    assert dut.uo_out.value == 0

    dut._log.info("Test project behavior")

    # Sequence from mealy_tb + overlapping 1101101 check:
    # (input bit a on ui_in[0], expected y on uo_out[0])
    sequence = [
        # Secuencia original de mealy_tb: 1 1 0 1 1 0 0 0
        (1, 0),
        (1, 0),
        (0, 0),
        (1, 1),  # Detecta "1101" -> y = 1
        (1, 0),
        (0, 0),
        (0, 0),
        (0, 0),
        # Prueba adicional de secuencia traslapada: 1 1 0 1 1 0 1
        (1, 0),
        (1, 0),
        (0, 0),
        (1, 1),  # Primer "1101" -> y = 1
        (1, 0),
        (0, 0),
        (1, 1),  # Segundo "1101" traslapado -> y = 1
    ]

    for i, (bit, expected_y) in enumerate(sequence):
        dut.ui_in.value = bit
        await FallingEdge(dut.clk)
        assert dut.uo_out.value == expected_y, (
            f"Cycle {i}: input a={bit}, expected uo_out={expected_y}, got {dut.uo_out.value}"
        )

    # Extra idle cycles at the end
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 3)
    
