###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: SanityTB.py
##
## Author: Heqing Huang
## Date Created: 01/19/2022
##
## ================== Description ==================
##
## Sanity Testbench.
##
## The sanity testbench read the instruction memory from a file and compares the final result
## (register file or memory content) with golden file.
##
###################################################################################################


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge

import sys
sys.path.append('../../lib/mem')
from RAM_1RW import RAM_1RW

async def reset(dut, time=20):
    """ Reset the design """
    dut.rst = 1
    await Timer(time, units="ns")
    await FallingEdge(dut.clk)
    dut.rst = 0

async def RegCheckTest(dut, ram_file, golden_file):
    """
        Run test the checks register file as golden result
    """

    # Instruction RAM
    instrRAM = RAM_1RW(ram_file)
    instrRAM.connect(dut.clk, 0, dut.instr_ram_addr, dut.instr_ram_din, 0)
    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    await reset(dut)
    instrRAM.run()
    await Timer(1, "us")


@cocotb.test()
async def SanityTB(dut):
    """
    """
    await RegCheckTest(dut, "tests/logic_arithematic.mem", None)