# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 01/19/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Basic/Sanity checks
# ------------------------------------------------------------------------------------------------

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
import os

import sys
sys.path.append('../../cocotb-library/common')


from LoadMemory import clearMemory, loadFromVerilogDump
from RegCheck import RegCheck

async def reset(dut, time=50):
    """ Reset the design """
    dut.rst.value = 1
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.rst.value = 0


async def RegCheckTest(dut, ram_file, golden_file, time=2):
    """
        Run test the checks register file as golden result
    """
    if 'SRAM' in os.environ and os.environ['SRAM']:
        RAM_PATH = dut.SRAM.sram_mem
        DUMP_SIZE = 2
    else:
        RAM_PATH = dut.u_veriRISCV_soc.u_memory.ram
        DUMP_SIZE = 4

    # Instruction RAM
    clearMemory(RAM_PATH, 128)
    loadFromVerilogDump(ram_file, RAM_PATH, DUMP_SIZE)

    # Register checker
    regCheck = RegCheck(dut.u_veriRISCV_soc.u_veriRISCV_core.u_ID.u_regfile.register_file, golden_file)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
    await reset(dut)
    await Timer(time, "us")
    regCheck.checkRegister()

@cocotb.test()
async def logic_simple(dut):
    """ Simple logic instruction test, no forwarding """
    await RegCheckTest(dut, "tests/logic_simple.verilog", "tests/logic_simple.register_golden")

@cocotb.test()
async def logic_forward(dut):
    """ Immediate/Logic type instruction with data forward test """
    await RegCheckTest(dut, "tests/logic_forward.verilog", "tests/logic_forward.register_golden")

@cocotb.test()
async def load_store(dut):
    """ load load type instruction """
    await RegCheckTest(dut, "tests/load_store.verilog", "tests/load_store.register_golden")

@cocotb.test()
async def branch(dut):
    """ load store type instruction """
    await RegCheckTest(dut, "tests/branch.verilog", "tests/branch.register_golden")

@cocotb.test()
async def lui_auipc(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/lui_auipc.verilog", "tests/lui_auipc.register_golden")

@cocotb.test()
async def load_stall(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/load_stall.verilog", "tests/load_stall.register_golden")

@cocotb.test()
async def jal_jalr(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/jal_jalr.verilog", "tests/jal_jalr.register_golden")