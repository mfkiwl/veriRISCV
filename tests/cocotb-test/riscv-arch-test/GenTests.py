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
# Testbench using riscv-arch-test
# ------------------------------------------------------------------------------------------------

from TestsUtils import *

"""

# Common instruction in RISCV

rv32i_m_i_instruction = [
    # arithmetic/logic
    'add', 'addi', 'sub',
    'and', 'andi', 'or', 'ori', 'xor', 'xori',
    'auipc', 'lui',
    # bench/jump
    'beq', 'bge', 'bgeu', 'bne', 'blt', 'bltu', 'jal', 'jalr',
    # memory
    'lb-align', 'lbu-align', 'lh-align', 'lhu-align',
    'lw-align', 'sb-align', 'sh-align', 'sw-align',
    # sll
    'sll', 'slli', 'slt', 'slti', 'sltiu', 'sltu',
    # shift
    'sra', 'srai', 'srl', 'srli',
    # NA
    # 'fence',
]

rv32i_m_i = ['I', rv32i_m_i_instruction]

all_instructions = [rv32i_m_i]

def genTest(isa, instruction):
    funcName = instruction.upper()
    funcName = funcName.replace('-', '_')
    func = f"""@cocotb.test()
async def {funcName}(dut):
    await testVerilog(dut, '{isa}', '{instruction}-01')

"""
    return func

def genRVTests(all_instructions):
    OUTPUT = 'Tests.py'
    FH = open(OUTPUT, "w")
    FH.write(HEADER)
    for a in all_instructions:
        (isa, nameList) = a
        for name in nameList:
            FH.write(genTest(isa, name))
    FH.close()

genRVTests(all_instructions)
