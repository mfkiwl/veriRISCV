# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 01/26/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Generate test function for riscv-tests
# ------------------------------------------------------------------------------------------------

from datetime import date

HEADER = \
f"""
# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: {date.today()}
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Testbench using riscv-tests
# ------------------------------------------------------------------------------------------------

from RVTestsUtils import *

"""

# Common instruction in RISCV
CONTROL = ['jal', 'jalr', 'beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']
INTEGER = ['lui', 'auipc', \
           'addi', 'slti', 'sltiu', 'xori', 'ori', 'andi', 'slli', 'srli', 'srai', \
           'add', 'sub', 'sll', 'slt', 'sltu', 'xor', 'srl', 'sra', 'or', 'and']

# Instruction for rv32ui, p architecture
rv32ui_p_instruction = CONTROL + INTEGER
rv32ui_p = ['rv32ui', 'p', rv32ui_p_instruction]

# Instruction for csr
rv32mi_p_csr_instruction = ['mcsr', 'csr']
rv32mi_p_csr = ['rv32mi', 'p', rv32mi_p_csr_instruction]

all_instructions = [rv32ui_p, rv32mi_p_csr]

def genTest(isa, mode, instruction):
    func = f"""@cocotb.test()
async def {instruction.upper()}(dut):
    await testVerilog(dut, '{isa}-{mode}-{instruction}')

"""
    return func

def genRVTests(all_instructions):
    OUTPUT = 'RVTests.py'
    FH = open(OUTPUT, "w")
    FH.write(HEADER)
    for a in all_instructions:
        (isa, mode, nameList) = a
        for name in nameList:
            FH.write(genTest(isa, mode, name))
    FH.close()

genRVTests(all_instructions)