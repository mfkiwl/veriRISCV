
# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 2022-07-22
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Testbench using riscv-arch-test
# ------------------------------------------------------------------------------------------------

from TestsUtils import *

@cocotb.test()
async def ADD(dut):
    await testVerilog(dut, 'I', 'add-01')

@cocotb.test()
async def ADDI(dut):
    await testVerilog(dut, 'I', 'addi-01')

@cocotb.test()
async def SUB(dut):
    await testVerilog(dut, 'I', 'sub-01')

@cocotb.test()
async def AND(dut):
    await testVerilog(dut, 'I', 'and-01')

@cocotb.test()
async def ANDI(dut):
    await testVerilog(dut, 'I', 'andi-01')

@cocotb.test()
async def OR(dut):
    await testVerilog(dut, 'I', 'or-01')

@cocotb.test()
async def ORI(dut):
    await testVerilog(dut, 'I', 'ori-01')

@cocotb.test()
async def XOR(dut):
    await testVerilog(dut, 'I', 'xor-01')

@cocotb.test()
async def XORI(dut):
    await testVerilog(dut, 'I', 'xori-01')

@cocotb.test()
async def AUIPC(dut):
    await testVerilog(dut, 'I', 'auipc-01')

@cocotb.test()
async def LUI(dut):
    await testVerilog(dut, 'I', 'lui-01')

@cocotb.test()
async def BEQ(dut):
    await testVerilog(dut, 'I', 'beq-01')

@cocotb.test()
async def BGE(dut):
    await testVerilog(dut, 'I', 'bge-01')

@cocotb.test()
async def BGEU(dut):
    await testVerilog(dut, 'I', 'bgeu-01')

@cocotb.test()
async def BNE(dut):
    await testVerilog(dut, 'I', 'bne-01')

@cocotb.test()
async def BLT(dut):
    await testVerilog(dut, 'I', 'blt-01')

@cocotb.test()
async def BLTU(dut):
    await testVerilog(dut, 'I', 'bltu-01')

@cocotb.test()
async def JAL(dut):
    await testVerilog(dut, 'I', 'jal-01')

@cocotb.test()
async def JALR(dut):
    await testVerilog(dut, 'I', 'jalr-01')

@cocotb.test()
async def LB_ALIGN(dut):
    await testVerilog(dut, 'I', 'lb-align-01')

@cocotb.test()
async def LBU_ALIGN(dut):
    await testVerilog(dut, 'I', 'lbu-align-01')

@cocotb.test()
async def LH_ALIGN(dut):
    await testVerilog(dut, 'I', 'lh-align-01')

@cocotb.test()
async def LHU_ALIGN(dut):
    await testVerilog(dut, 'I', 'lhu-align-01')

@cocotb.test()
async def LW_ALIGN(dut):
    await testVerilog(dut, 'I', 'lw-align-01')

@cocotb.test()
async def SB_ALIGN(dut):
    await testVerilog(dut, 'I', 'sb-align-01')

@cocotb.test()
async def SH_ALIGN(dut):
    await testVerilog(dut, 'I', 'sh-align-01')

@cocotb.test()
async def SW_ALIGN(dut):
    await testVerilog(dut, 'I', 'sw-align-01')

@cocotb.test()
async def SLL(dut):
    await testVerilog(dut, 'I', 'sll-01')

@cocotb.test()
async def SLLI(dut):
    await testVerilog(dut, 'I', 'slli-01')

@cocotb.test()
async def SLT(dut):
    await testVerilog(dut, 'I', 'slt-01')

@cocotb.test()
async def SLTI(dut):
    await testVerilog(dut, 'I', 'slti-01')

@cocotb.test()
async def SLTIU(dut):
    await testVerilog(dut, 'I', 'sltiu-01')

@cocotb.test()
async def SLTU(dut):
    await testVerilog(dut, 'I', 'sltu-01')

@cocotb.test()
async def SRA(dut):
    await testVerilog(dut, 'I', 'sra-01')

@cocotb.test()
async def SRAI(dut):
    await testVerilog(dut, 'I', 'srai-01')

@cocotb.test()
async def SRL(dut):
    await testVerilog(dut, 'I', 'srl-01')

@cocotb.test()
async def SRLI(dut):
    await testVerilog(dut, 'I', 'srli-01')

