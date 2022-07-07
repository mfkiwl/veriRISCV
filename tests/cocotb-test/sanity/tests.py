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

import sys
sys.path.append('../../cocotb-library/common')


from LoadMemory import loadFromFile, clearMemory
from RegCheck import RegCheck

async def reset(dut, time=50):
    """ Reset the design """
    dut.rst.value = 1
    await Timer(time, units="ns")
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.rst.value = 0


async def RegCheckTest(dut, ram_file, golden_file, time=1):
    """
        Run test the checks register file as golden result
    """

    dut.software_interrupt.value = 0
    dut.timer_interrupt.value = 0
    dut.external_interrupt.value = 0
    dut.debug_interrupt.value = 0

    # Instruction RAM
    clearMemory(dut.u_memory.ram, 1024)
    loadFromFile(ram_file, dut.u_memory.ram)

    # Register checker
    regCheck = RegCheck(dut.u_veriRISCV_core.u_ID.u_regfile.register_file, golden_file)

    # Test start
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
    cocotb.fork(clock.start())  # Start the clock
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
    """ load load type instruction """
    await RegCheckTest(dut, "tests/load_store/mem", "tests/load_store/register_golden")

@cocotb.test()
async def branch(dut):
    """ load store type instruction """
    await RegCheckTest(dut, "tests/branch/mem", "tests/branch/register_golden")

@cocotb.test()
async def lui_auipc(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/lui_auipc/mem", "tests/lui_auipc/register_golden")

@cocotb.test()
async def load_stall(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/load_stall/mem", "tests/load_stall/register_golden")

@cocotb.test()
async def jal_jalr(dut):
    """ LUI/AUIPC instruction """
    await RegCheckTest(dut, "tests/jal_jalr/mem", "tests/jal_jalr/register_golden")