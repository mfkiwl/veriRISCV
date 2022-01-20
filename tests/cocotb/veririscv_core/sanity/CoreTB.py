###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: CoreTB.py
##
## Author: Heqing Huang
## Date Created: 01/18/2022
##
## ================== Description ==================
##
## Testbench for core
##
###################################################################################################


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge

async def reset(dut, time=20):
    """ Reset the design """
    dut.rst = 1
    await Timer(time, units="ns")
    await FallingEdge(dut.clk)
    dut.rst = 0

@cocotb.test()
async def sanity(dut):
    """
        Sanity test
        Check if the test env can run
    """
    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    await reset(dut)
    await Timer(1, "us")