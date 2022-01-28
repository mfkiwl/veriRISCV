###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RVTests.py
##
## Author: Heqing Huang
## Date Created: 2022-01-27
##
## ================== Description ==================
##
## Testbench using riscv-tests
##
###################################################################################################

from RVTestsUtils import *

@cocotb.test()
async def JAL(dut):
    await testVerilog(dut, 'rv32ui-p-jal')

@cocotb.test()
async def JALR(dut):
    await testVerilog(dut, 'rv32ui-p-jalr')

@cocotb.test()
async def BEQ(dut):
    await testVerilog(dut, 'rv32ui-p-beq')

@cocotb.test()
async def BNE(dut):
    await testVerilog(dut, 'rv32ui-p-bne')

@cocotb.test()
async def BLT(dut):
    await testVerilog(dut, 'rv32ui-p-blt')

@cocotb.test()
async def BGE(dut):
    await testVerilog(dut, 'rv32ui-p-bge')

@cocotb.test()
async def BLTU(dut):
    await testVerilog(dut, 'rv32ui-p-bltu')

@cocotb.test()
async def BGEU(dut):
    await testVerilog(dut, 'rv32ui-p-bgeu')

@cocotb.test()
async def LUI(dut):
    await testVerilog(dut, 'rv32ui-p-lui')

@cocotb.test()
async def AUIPC(dut):
    await testVerilog(dut, 'rv32ui-p-auipc')

@cocotb.test()
async def ADDI(dut):
    await testVerilog(dut, 'rv32ui-p-addi')

@cocotb.test()
async def SLTI(dut):
    await testVerilog(dut, 'rv32ui-p-slti')

@cocotb.test()
async def SLTIU(dut):
    await testVerilog(dut, 'rv32ui-p-sltiu')

@cocotb.test()
async def XORI(dut):
    await testVerilog(dut, 'rv32ui-p-xori')

@cocotb.test()
async def ORI(dut):
    await testVerilog(dut, 'rv32ui-p-ori')

@cocotb.test()
async def ANDI(dut):
    await testVerilog(dut, 'rv32ui-p-andi')

@cocotb.test()
async def SLLI(dut):
    await testVerilog(dut, 'rv32ui-p-slli')

@cocotb.test()
async def SRLI(dut):
    await testVerilog(dut, 'rv32ui-p-srli')

@cocotb.test()
async def SRAI(dut):
    await testVerilog(dut, 'rv32ui-p-srai')

@cocotb.test()
async def ADD(dut):
    await testVerilog(dut, 'rv32ui-p-add')

@cocotb.test()
async def SUB(dut):
    await testVerilog(dut, 'rv32ui-p-sub')

@cocotb.test()
async def SLL(dut):
    await testVerilog(dut, 'rv32ui-p-sll')

@cocotb.test()
async def SLT(dut):
    await testVerilog(dut, 'rv32ui-p-slt')

@cocotb.test()
async def SLTU(dut):
    await testVerilog(dut, 'rv32ui-p-sltu')

@cocotb.test()
async def XOR(dut):
    await testVerilog(dut, 'rv32ui-p-xor')

@cocotb.test()
async def SRL(dut):
    await testVerilog(dut, 'rv32ui-p-srl')

@cocotb.test()
async def SRA(dut):
    await testVerilog(dut, 'rv32ui-p-sra')

@cocotb.test()
async def OR(dut):
    await testVerilog(dut, 'rv32ui-p-or')

@cocotb.test()
async def AND(dut):
    await testVerilog(dut, 'rv32ui-p-and')

