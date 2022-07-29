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

from env import riscv_tests, riscv_arch_test, sanity_test, dedicated_tests
import cocotb
"""

# SANITY TEST
sanity_test = ['logic_simple', 'logic_forward', 'load_store', 'branch', 'lui_auipc', 'load_stall', 'jal_jalr']

# RISCV TEST
riscv_tests__rv32ui_p = [
'jal', 'jalr', 'beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu', 'lui', 'auipc',
'addi', 'slti', 'sltiu', 'xori', 'ori', 'andi', 'slli', 'srli', 'srai',
'add', 'sub', 'sll', 'slt', 'sltu', 'xor', 'srl', 'sra', 'or', 'and',
'lb', 'lbu', 'lh', 'lhu', 'lw', 'sb', 'sh', 'sw'
]
riscv_tests__rv32mi_p = ['mcsr', 'csr', 'illegal', 'ma_addr']

# RISCV ARCH TEST
riscv_arch_test__rv32i_m_i_instruction = [
    'add', 'addi', 'sub', 'and', 'andi', 'or', 'ori', 'xor', 'xori', 'auipc', 'lui',
    'beq', 'bge', 'bgeu', 'bne', 'blt', 'bltu', 'jal', 'jalr',
    'lb-align', 'lbu-align', 'lh-align', 'lhu-align',
    'lw-align', 'sb-align', 'sh-align', 'sw-align',
    'sll', 'slli', 'slt', 'slti', 'sltiu', 'sltu',
    'sra', 'srai', 'srl', 'srli',
]

# DEDICATED TEST
dedicated_test = ['software_interrupt']

# Generate tests cases

GEN_SANITY_TEST = False # Sanity test does not work after enabling exceptions
GEN_RISCV_TESTS = True
GEN_RISCV_ARCH_TEST = True
GEN_DEDICATED_TEST = True

def gen_sanity_tests(name):
    func = \
f"""
@cocotb.test()
async def sanity_tests_{name}(dut):
    await sanity_test(dut, '{name}')
"""
    return func

def gen_riscv_tests(name, test):
    func = \
f"""
@cocotb.test()
async def riscv_tests_{test}(dut):
    await riscv_tests(dut, '{name}')
"""
    return func

def gen_riscv_arch_tests(isa, instruction):
    funcName = instruction
    funcName = funcName.replace('-', '_')
    func = \
f"""
@cocotb.test()
async def riscv_arch_test_{funcName}(dut):
    await riscv_arch_test(dut, '{isa}', '{instruction}-01')
"""
    return func

def gen_dedicated_tests(name):
    func = \
f"""
@cocotb.test()
async def dedicated_tests_{name}(dut):
    await dedicated_tests(dut, '{name}')
"""
    return func


def gen_tests():
    OUTPUT = 'tests.py'
    FH = open(OUTPUT, "w")
    FH.write(HEADER)

    if GEN_SANITY_TEST:
        FH.write("\n# sanity Test\n")
        for test in sanity_test:
            FH.write(gen_sanity_tests(test))

    if GEN_RISCV_TESTS:
        FH.write("\n# riscv-tests Test\n")
        for test in riscv_tests__rv32ui_p:
            name = f"rv32ui-p-{test}"
            FH.write(gen_riscv_tests(name, test))
        for test in riscv_tests__rv32mi_p:
            name = f"rv32mi-p-{test}"
            FH.write(gen_riscv_tests(name, test))

    if GEN_RISCV_ARCH_TEST:
        FH.write("\n# riscv-arch-test Test\n")
        for test in riscv_arch_test__rv32i_m_i_instruction:
            FH.write(gen_riscv_arch_tests('I', test))

    if GEN_DEDICATED_TEST:
        FH.write("\n# dedicated-tests Test\n")
        for test in dedicated_test:
            FH.write(gen_dedicated_tests(test))

    FH.close()

if __name__ == '__main__':
    gen_tests()
