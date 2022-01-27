###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RVTestsUtils.py
##
## Author: Heqing Huang
## Date Created: 01/26/2022
##
## ================== Description ==================
##
## Testbench using riscv-tests
##
###################################################################################################


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.regression import TestFactory

import sys
sys.path.append('../../lib/mem')
sys.path.append('../../lib/common')

from AHBLiteRAM_1rw import AHBLiteRAM_1rw
from RegCheck import RegCheck

import subprocess

async def reset(dut, time=50):
    """ Reset the design """
    dut.rst.value = 1
    dut.rstn.value = 0
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.rst.value = 0
    dut.rstn.value = 1

def checkRegResult(dut):
    """
        Check register result
        PASSED: x1: 1, x2: 2, x3: 3
        FAILED: x1: f, x2: f, x3: f
    """
    regValue = dut.ID.regfile.register.value
    try:
        (reg1, reg2, reg3) = (regValue[1].integer, regValue[2].integer, regValue[3].integer)
    except ValueError:
        (reg1, reg2, reg3) = (0, 0, 0)
    passed = (reg1 == 1   and reg2 == 2   and reg3 == 3)
    failed = (reg1 == 0xf and reg2 == 0xf and reg3 == 0xf)
    completed = passed or failed
    if failed:
        raise TestFailure("Test failed. Register value does not match")
    return completed, passed

async def test(dut, ram_file, timeout=10):
    """
        Run a single test
    """

    DELTA = 0.1

    # Instruction RAM
    instrRAM = AHBLiteRAM_1rw(32,32,ram_file)
    instrRAM.ahbPort.connect(dut.clk, dut.rstn,
                             dut.ibus_hwrite, dut.ibus_hsize, dut.ibus_hburst, dut.ibus_hport,
                             dut.ibus_htrans, dut.ibus_hmastlock, dut.ibus_haddr, dut.ibus_hwdata,
                             dut.ibus_hready, dut.ibus_hresp, dut.ibus_hrdata)

    # Data RAM
    dataRAM = AHBLiteRAM_1rw(32,32, ram_file)
    dataRAM.ahbPort.connect(dut.clk, dut.rstn,
                             dut.dbus_hwrite, dut.dbus_hsize, dut.dbus_hburst, dut.dbus_hport,
                             dut.dbus_htrans, dut.dbus_hmastlock, dut.dbus_haddr, dut.dbus_hwdata,
                             dut.dbus_hready, dut.dbus_hresp, dut.dbus_hrdata)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    instrRAM.run()  # Start memory
    dataRAM.run() # Start memory
    await reset(dut)
    time = 0
    passed = False
    while time < timeout:
        await Timer(DELTA, "us")
        time += DELTA
        completed, passed = checkRegResult(dut)
        if completed:
            break
    if not passed:
        raise TestFailure("Test timeout")

async def testVerilog(dut, name, timeout=10):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    RV_TEST_PATH = '/tests/riscv-tests/generated/'
    VERILOG_EXTENSION = '.verilog_reversed_4byte'
    file = REPO_ROOT + RV_TEST_PATH + name + VERILOG_EXTENSION
    await test(dut, file, timeout)

###########################################################
