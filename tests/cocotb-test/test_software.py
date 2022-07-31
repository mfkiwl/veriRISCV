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
    await software_tests(dut, 'hello_riscv')