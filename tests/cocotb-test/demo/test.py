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

async def test(dut, ram_file, timeout=10):
    DELTA = 0.1

    if 'SRAM' in os.environ and os.environ['SRAM']:
        RAM_PATH = dut.SRAM.sram_mem
        DUMP_SIZE = 2
    else:
        RAM_PATH = dut.u_veriRISCV_soc.u_memory.ram
        DUMP_SIZE = 4
    loadFromVerilogDump(ram_file, RAM_PATH, DUMP_SIZE)

    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    await reset(dut)
    time = 0
    while time < timeout:
        await Timer(DELTA, "us")
        time += DELTA

async def testVerilog(dut, name, timeout=10, file=None):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    if file:
        FILE = file
    else:
        FILE = f"/sdk/software/demo/{name}/{name}.verilog"
    file = REPO_ROOT + FILE
    await test(dut, file, timeout)


@cocotb.test()
async def blink(dut, timeout=100):
    await testVerilog(dut, 'blink', timeout)

@cocotb.test()
async def uart(dut, timeout=1000):
    await testVerilog(dut, 'uart', timeout)

@cocotb.test()
async def coremark(dut, timeout=1000):
    file = '/sdk/software/benchmark/coremark/coremark.verilog'
    await testVerilog(dut, 'coremark', timeout, file)
