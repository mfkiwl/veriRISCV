# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/22/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Testbench using riscv-arch-test
# ------------------------------------------------------------------------------------------------


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.regression import TestFactory

import os
import math
import filecmp
import subprocess

import sys
sys.path.append('../../cocotb-library/common')

from LoadMemory import loadFromVerilogDump

BEGIN_SIGNATURE_PTR = 0x3FF0
END_SIGNATURE_PTR   = 0x3FF4

class ENV:

    def __init__(self, dut, name, ramFile, refFile, timeout=10):
        self.dut = dut
        self.name = name
        self.ramFile = ramFile
        self.refFile = refFile
        self.timeout = timeout
        self.signature = f'{self.name}.signature'

    def getMemoryConfig(self):
        """ Get the memory config """
        if 'SRAM' in os.environ and os.environ['SRAM']:
            self.ram_path = self.dut.SRAM.sram_mem
            self.ram_width = 2
        else:
            self.ram_path = self.dut.u_veriRISCV_soc.u_memory.ram
            self.ram_width = 4

    async def reset(self, time=50):
        """ Reset the design """
        self.dut.rst.value = 1
        await Timer(time, units="ns")
        await RisingEdge(self.dut.clk)
        await Timer(1, units="ns")
        self.dut.rst.value = 0

    def getMemoryData(self, addr):
        """ Get the memory data for a specific address"""
        word_addr = addr >> int(math.log2(self.ram_width)) # From byte address to word address
        data = 0
        if self.ram_width == 4: # data size is 4 bytes (word)
            data = self.ram_path[word_addr].value.integer
        if self.ram_width == 2: # data size is 2 bytes (half word)
            data = self.ram_path[word_addr].value.integer
            data = data | (self.ram_path[word_addr+1].value.integer << 16)
        return data

    def checkFinish(self):
        """ Check if the test has finished or not """
        beginSignature = self.getMemoryData(BEGIN_SIGNATURE_PTR)
        endSignature = self.getMemoryData(END_SIGNATURE_PTR)
        if beginSignature > 0xF and endSignature > beginSignature:
            return True
        return False

    def dumpSignature(self):
        """ Dump the signature to the output directory """
        beginSignature = self.getMemoryData(BEGIN_SIGNATURE_PTR)
        endSignature = self.getMemoryData(END_SIGNATURE_PTR)
        self.dut._log.info(f"Begin Signature: {hex(beginSignature)}, End Signature: {hex(endSignature)}")
        FP = open(self.signature, "w")
        for addr in range(beginSignature, endSignature, 4):
            data = hex(self.getMemoryData(addr))
            FP.write(data[2:].zfill(8) + '\n')
        FP.close()

    def check_signature(self):
        """ Check the signature file against reference """
        if filecmp.cmp(self.signature, self.refFile):
            self.dut._log.info('Signature matches with reference file')
        else:
            assert ValueError("Signature does not match with reference file")

    async def test(self):
        """ Run a single test """
        DELTA = 0.1
        self.getMemoryConfig()
        # Load the Instruction RAM
        loadFromVerilogDump(self.ramFile, self.ram_path, self.ram_width)

        # Test start
        clock = Clock(self.dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
        cocotb.fork(clock.start())  # Start the clock
        await self.reset()

        time = 0
        passed = False
        finished = False
        while not finished and (time < self.timeout):
            await Timer(DELTA, "us")
            time += DELTA
            if self.checkFinish():
                finished = True

        if not finished:
            raise Exception("Test timeout")
            return

        self.dumpSignature()
        self.check_signature()

async def testVerilog(dut, isa, name, timeout=300):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = 'tests/riscv-isa/riscv-arch-test/riscv-arch-test'
    ramFile = f"{REPO_ROOT}/{TEST_PATH}/work/rv32i_m/{isa}/{name}.elf.verilog"
    refFile = f"{REPO_ROOT}/{TEST_PATH}/riscv-test-suite/rv32i_m/{isa}/references/{name}.reference_output"
    env = ENV(dut, name, ramFile, refFile, timeout)
    await env.test()
