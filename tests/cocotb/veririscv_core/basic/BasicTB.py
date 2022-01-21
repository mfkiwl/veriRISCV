###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: BasicTB.py
##
## Author: Heqing Huang
## Date Created: 01/19/2022
##
## ================== Description ==================
##
## Basic Testbench.
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
sys.path.append('../../lib/common')
from RAM_1RW import RAM_1RW
from RegCheck import RegCheck

async def reset(dut, time=20):
    """ Reset the design """
    dut.rst = 1
    await Timer(time, units="ns")
    await FallingEdge(dut.clk)
    dut.rst = 0

async def RegCheckTest(dut, ram_file, golden_file, time=1):
    """
        Run test the checks register file as golden result
    """

    # Instruction RAM
    instrRAM = RAM_1RW(ram_file)
    instrRAM.connect(dut.clk, 0, dut.instr_ram_addr, dut.instr_ram_din, 0)
    # Register checker
    regCheck = RegCheck(dut.ID.regfile, golden_file)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    instrRAM.run()
    await reset(dut)
    await Timer(time, "us")
    regCheck.checkRegister()

@cocotb.test()
async def logic_simple(dut):
    """ Simple logic instruction test, no forwarding """
    await RegCheckTest(dut, "tests/logic_simple/mem", "tests/logic_simple/register_golden")

@cocotb.test()
async def logic_forward(dut):
    """ Immediate/Logic type instruction with data forward test """
    await RegCheckTest(dut, "tests/logic_forward/mem", "tests/logic_forward/register_golden")