###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: GenTests.py
##
## Author: Heqing Huang
## Date Created: 01/26/2022
##
## ================== Description ==================
##
## Generate test function for riscv-tests
##
###################################################################################################

from datetime import date

HEADER = f"""###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RVTests.py
##
## Author: Heqing Huang
## Date Created: {date.today}
##
## ================== Description ==================
##
## Testbench using riscv-tests
##
###################################################################################################

from RVTestsUtils import *

"""

def genTest(isa, mode, name):
    func = f"""@cocotb.test()
async def add(dut):
    await testVerilog(dut, '{isa}-{mode}-{name}')"""
    return func


def gen():
    OUTPUT = 'RVTests.py'
    FH = open(OUTPUT, "w")
    FH.write(HEADER)
    FH.write(genTest('rv32ui', 'p', 'add'))
    FH.close()

gen()