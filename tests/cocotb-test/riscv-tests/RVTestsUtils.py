# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 01/26/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Testbench using riscv-tests
# ------------------------------------------------------------------------------------------------


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.regression import TestFactory
import os

import sys
sys.path.append('../../cocotb-library/common')


from LoadMemory import loadFromVerilogDump

import subprocess

async def reset(dut, time=50):
    """ Reset the design """
    dut.rst.value = 1
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.rst.value = 0

def checkRegResult(dut):
    """
        Check register result
        PASSED: x1: 1, x2: 2, x3: 3
        FAILED: x1: f, x2: f, x3: f
    """
    register_file = dut.u_veriRISCV_soc.u_veriRISCV_core.u_ID.u_regfile.register_file
    try:
        (reg1, reg2, reg3) = (register_file[1].value.integer, register_file[2].value.integer, register_file[3].value.integer)
    except ValueError:
        (reg1, reg2, reg3) = (0, 0, 0)
    passed = (reg1 == 1   and reg2 == 2   and reg3 == 3)
    failed = (reg1 == 0xf and reg2 == 0xf and reg3 == 0xf)
    completed = passed or failed
    if failed:
        raise Exception("Test failed.")
    return completed, passed

async def test(dut, ram_file, timeout=10):
    """
        Run a single test
    """

    DELTA = 0.1

    if 'SRAM' in os.environ and os.environ['SRAM']:
        RAM_PATH = dut.SRAM.sram_mem
        DUMP_SIZE = 2
    else:
        RAM_PATH = dut.u_veriRISCV_soc.u_memory.ram
        DUMP_SIZE = 4

    # Instruction RAM
    loadFromVerilogDump(ram_file, RAM_PATH, DUMP_SIZE)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
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
        raise Exception("Test timeout")

async def testVerilog(dut, name, timeout=100):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    RV_TEST_PATH = '/tests/riscv-isa/riscv-tests/generated/'
    VERILOG_EXTENSION = '.verilog'
    file = REPO_ROOT + RV_TEST_PATH + name + VERILOG_EXTENSION
    await test(dut, file, timeout)


