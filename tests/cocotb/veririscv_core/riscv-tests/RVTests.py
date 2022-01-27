###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RVTests.py
##
## Author: Heqing Huang
## Date Created: <built-in method today of type object at 0x7f27092978c0>
##
## ================== Description ==================
##
## Testbench using riscv-tests
##
###################################################################################################

from RVTestsUtils import *

@cocotb.test()
async def add(dut):
    await testVerilog(dut, 'rv32ui-p-add')