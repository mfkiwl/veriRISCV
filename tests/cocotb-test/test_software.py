# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 2022-07-30
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------

from env import software_tests
import cocotb

# sanity Test

@cocotb.test()
async def blink(dut):
    await software_tests(dut, 'blink')

@cocotb.test()
async def hello_riscv(dut):
    await software_tests(dut, 'hello_riscv', timeout=1000)

@cocotb.test()
async def interrupt(dut):
    await software_tests(dut, 'interrupt', timeout=10000)

@cocotb.test()
async def uart_rw(dut):
    await software_tests(dut, 'uart_rw', timeout=1000)

@cocotb.test()
async def coremark(dut):
    await software_tests(dut, 'coremark', timeout=20000)