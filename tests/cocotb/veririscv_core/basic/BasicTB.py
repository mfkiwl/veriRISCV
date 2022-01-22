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
from cocotb.triggers import Timer, FallingEdge, RisingEdge

import sys
sys.path.append('../../lib/mem')
sys.path.append('../../lib/common')

from AHBLiteRAM_1rw import AHBLiteRAM_1rw
from RegCheck import RegCheck

async def reset(dut, time=50):
    """ Reset the design """
    dut.rst = 1
    dut.rstn = 0
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.rst = 0
    dut.rstn = 1

async def RegCheckTest(dut, ram_file, golden_file, time=1):
    """
        Run test the checks register file as golden result
    """

    # Instruction RAM
    instrRAM = AHBLiteRAM_1rw(32,16,ram_file)
    instrRAM.ahbPort.connect(dut.clk, dut.rstn,
                             dut.ibus_hwrite, dut.ibus_hsize, dut.ibus_hburst, dut.ibus_hport,
                             dut.ibus_htrans, dut.ibus_hmastlock, dut.ibus_haddr, dut.ibus_hwdata,
                             dut.ibus_hready, dut.ibus_hresp, dut.ibus_hrdata)

    # Data RAM
    dataRAM = AHBLiteRAM_1rw(32,16,ram_file)
    dataRAM.ahbPort.connect(dut.clk, dut.rstn,
                             dut.dbus_hwrite, dut.dbus_hsize, dut.dbus_hburst, dut.dbus_hport,
                             dut.dbus_htrans, dut.dbus_hmastlock, dut.dbus_haddr, dut.dbus_hwdata,
                             dut.dbus_hready, dut.dbus_hresp, dut.dbus_hrdata)

    # Register checker
    regCheck = RegCheck(dut.ID.regfile, golden_file)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    instrRAM.run()  # Start memory
    dataRAM.run() # Start memory
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

@cocotb.test()
async def load_store(dut):
    """ load store type instruction """
    await RegCheckTest(dut, "tests/load_store/mem", "tests/load_store/register_golden")