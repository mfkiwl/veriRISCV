# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/22/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Testbench Environment
# ------------------------------------------------------------------------------------------------


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, FallingEdge, RisingEdge
from cocotb.regression import TestFactory

import sys
sys.path.append('cocotb-library')

import re
import math
import os
import filecmp
import subprocess
from enum import Enum

from RegCheck import RegCheck


BEGIN_SIGNATURE_PTR = 0x3FF0
END_SIGNATURE_PTR   = 0x3FF4

class ENV:

    def __init__(self, dut, name, test_type, ramFile, refFile="", timeout=10, check_result=True):
        self.dut = dut
        self.name = name
        self.test_type = test_type
        self.ramFile = ramFile
        self.refFile = refFile
        self.timeout = timeout
        self.signature = f'{self.name}.signature'
        self.check_result = check_result
        self.use_sram = 'SRAM' in os.environ and os.environ['SRAM']

    def getMemoryConfig(self):
        """ Get the memory config """
        if self.use_sram:
            self.ram_path = self.dut.SRAM.sram_mem
            self.ram_width = 2
        else:
            self.ram_path = self.dut.u_veriRISCV_soc.u_memory.ram
            self.ram_width = 4

    async def waitMemoryIdle(self):
        """ Make sure that the memory is not being written when we want to get the data from memory """

        # 1. check if the avalon bus waitrequest is set or not
        waitrequest =  self.dut.u_veriRISCV_soc.ram_avn_waitrequest
        write = self.dut.u_veriRISCV_soc.ram_avn_write
        while waitrequest.value.integer == 1 and write.value.integer == 1:
            await RisingEdge(self.dut.clk)

        # 2. If we use sram, make sure that sram is not being written when we get the data from sram
        if self.use_sram:
            sram_we_n = self.dut.u_veriRISCV_soc.u_avalon_sram_controller.sram_we_n
            sram_ce_n = self.dut.u_veriRISCV_soc.u_avalon_sram_controller.sram_ce_n
            while sram_ce_n.value.integer == 0 and sram_we_n.value.integer == 0:
                await RisingEdge(self.dut.clk)

    async def getMemoryData(self, addr):
        """ Get the memory data for a specific address """

        await self.waitMemoryIdle()

        word_addr = addr >> int(math.log2(self.ram_width)) # From byte address to word address
        data = 0
        if self.ram_width == 4: # data size is 4 bytes (word)
            data = self.ram_path[word_addr].value.integer
        if self.ram_width == 2: # data size is 2 bytes (half word)
            data = self.ram_path[word_addr].value.integer
            data = data | (self.ram_path[word_addr+1].value.integer << 16)
        return data

    def clearMemory(self, mem, size):
        while size > 0:
            mem[size].value = 0
            size -= 1

    def loadFromVerilogDump(self, file, mem, size=1):
        """
            Load the instruction from verilog dump
            size: the number of data to format a word
        """
        FH = open(file, "r")
        addr = 0
        lines  = FH.readlines()
        for value in lines:
            if '@' in value:    # this is an address line
                addr = int(value.rstrip()[1:], 16)
            else:               # this is a data line
                line = value.split()
                data = [line[i:i+size] for i in range(0, len(line), size)]
                for d in data:
                    word_addr = addr >> int(math.log2(size))
                    byte = [int(i, 16) for i in d]
                    instr = 0
                    for i in range(size):
                        instr = instr | byte[i] << 8 * i
                    mem[word_addr].value = instr
                    addr = addr + size
        FH.close()
        self.dut._log.info(f"Read memory content from verilog file: {file}")

    def checkRegResult(self):
        """
            Check register result
            PASSED: x1: 1, x2: 2, x3: 3
            FAILED: x1: f, x2: f, x3: f
        """
        register_file = self.dut.u_veriRISCV_soc.u_veriRISCV_core.u_ID.u_regfile.register_file
        try:
            (reg1, reg2, reg3) = (register_file[1].value.integer, register_file[2].value.integer, register_file[3].value.integer)
        except ValueError:
            (reg1, reg2, reg3) = (0, 0, 0)
        passed = (reg1 == 1   and reg2 == 2   and reg3 == 3)
        failed = (reg1 == 0xf and reg2 == 0xf and reg3 == 0xf)
        completed = passed or failed
        return completed, passed

    async def checkFinish(self):
        """ Check if the test has finished or not """
        beginSignature = await self.getMemoryData(BEGIN_SIGNATURE_PTR)
        endSignature = await self.getMemoryData(END_SIGNATURE_PTR)
        if beginSignature > 0xF and endSignature > beginSignature:
            return True
        return False

    async def dumpSignature(self):
        """ Dump the signature to the output directory """
        beginSignature = await self.getMemoryData(BEGIN_SIGNATURE_PTR)
        endSignature = await self.getMemoryData(END_SIGNATURE_PTR)
        self.dut._log.info(f"Begin Signature: {hex(beginSignature)}, End Signature: {hex(endSignature)}")
        FP = open(self.signature, "w")
        for addr in range(beginSignature, endSignature, 4):
            data = await self.getMemoryData(addr)
            data = hex(data)
            FP.write(data[2:].zfill(8) + '\n')
        FP.close()

    def check_signature(self):
        """ Check the signature file against reference """
        if filecmp.cmp(self.signature, self.refFile):
            self.dut._log.info('Signature matches with reference file')
        else:
            assert ValueError("Signature does not match with reference file")

    async def reset(self, time=50):
        """ Reset the design """
        self.dut.rst.value = 1
        await Timer(time, units="ns")
        await RisingEdge(self.dut.clk)
        await Timer(1, units="ns")
        self.dut.rst.value = 0

    async def test(self):
        """ Run a single test """
        DELTA = 0.1
        self.getMemoryConfig()

        # clear memory
        self.clearMemory(self.ram_path, 2 ** 13)

        # Load the Instruction RAM
        self.loadFromVerilogDump(self.ramFile, self.ram_path, self.ram_width)

        # Test start
        clock = Clock(self.dut.clk, 10, units="ns")  # Create a 10 ns period clock on port clk
        cocotb.fork(clock.start())  # Start the clock
        await self.reset()

        # wait the test to complete
        time = 0
        passed = False
        finished = False

        while not finished and (time < self.timeout):
            await Timer(DELTA, "us")
            time += DELTA

            # depending on different test type, depending on what to do
            if self.test_type == 'RISCV_TEST':
                finished, passed = self.checkRegResult()
            if self.test_type == 'RISCV_ARCH_TEST':
                finished = await self.checkFinish()

        # Check test result
        if self.check_result:
            if self.test_type == 'SANITY_TEST':
                reg_path = self.dut.u_veriRISCV_soc.u_veriRISCV_core.u_ID.u_regfile.register_file
                regCheck = RegCheck(reg_path, self.refFile)
                regCheck.checkRegister()
                return

            if not finished:
                raise Exception("Test timeout")
                return

            if self.test_type == 'RISCV_TEST':
                if not passed:
                    raise Exception("Test failed.")

            if self.test_type == 'RISCV_ARCH_TEST':
                await self.dumpSignature()
                self.check_signature()

# Test for SANITY TESTS
async def sanity_test(dut, name, timeout=2):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = '/tests/riscv-isa/sanity-tests/'
    ramFile = REPO_ROOT + TEST_PATH + name + '.verilog'
    refFile = REPO_ROOT + TEST_PATH + name + '.register_golden'
    env = ENV(dut, name, 'SANITY_TEST', ramFile, refFile, timeout=timeout)
    await env.test()

# Test for RISCV TESTS
async def riscv_tests(dut, name, timeout=100):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = '/tests/riscv-isa/riscv-tests/generated/'
    ramFile = REPO_ROOT + TEST_PATH + name + '.verilog'
    env = ENV(dut, name, 'RISCV_TEST', ramFile, timeout=timeout)
    await env.test()

# Test for RISCV ARCH TEST
async def riscv_arch_test(dut, isa, name, timeout=1000):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = 'tests/riscv-isa/riscv-arch-test/riscv-arch-test'
    ramFile = f"{REPO_ROOT}/{TEST_PATH}/work/rv32i_m/{isa}/{name}.elf.verilog"
    refFile = f"{REPO_ROOT}/{TEST_PATH}/riscv-test-suite/rv32i_m/{isa}/references/{name}.reference_output"
    env = ENV(dut, name, 'RISCV_ARCH_TEST', ramFile, refFile, timeout)
    await env.test()

# Test for DEDICATED TESTS
async def dedicated_tests(dut, name, timeout=100):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = '/tests/riscv-isa/dedicated-tests/generated/'
    ramFile = REPO_ROOT + TEST_PATH + 'test-p-' + name + '.verilog'
    # use the infrastructure of RISCV_TEST
    env = ENV(dut, name, 'RISCV_TEST', ramFile, timeout=timeout)
    await env.test()

# Test for Software program
async def software_tests(dut, name, timeout=200):
    REPO_ROOT = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    TEST_PATH = f'/sdk/software/{name}/{name}.verilog'
    ramFile = REPO_ROOT + TEST_PATH
    # use the infrastructure of RISCV_TEST
    env = ENV(dut, name, 'SOFTWARE_TEST', ramFile, timeout=timeout, check_result=False)
    await env.test()