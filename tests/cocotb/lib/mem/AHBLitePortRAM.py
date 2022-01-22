###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: AHBLitePortRAM.py
##
## Author: Heqing Huang
## Date Created: 01/21/2022
##
## ================== Description ==================
##
## AHBLite Port for the RAM Model
##
###################################################################################################

import logging
import math
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer

class AHBLitePortRAM:
    """
        AHBLite Port for the RAM Model

        !!! Assumption about the AHBLite transfer:
        1. HTRANS can only be IDLE or NONSEQ
        2. HBURST is always 0. Meaning single transfer
        3. HPORT, HMASTLOCK are ignored
        4. HSIZE should match with RAM data width
    """

    def __init__(self, data_width, addr_width, ram):
        self.ram = ram
        self.data_width = data_width
        self.addr_width = addr_width
        assert (data_width % 8) == 0 # data must be size of 8 bit
        self._log = logging.getLogger(f"cocotb.AHBLitePort")

        self.p_trans = False    # p stands for pending
        self.p_write = 0
        self.p_addr = 0
        self.p_size = 0
        self.byte_addr_mask = (1 << int(math.log(data_width/8, 2))) - 1  # mask for byte address
        self.non_byte_addr_mask = ((1 << addr_width) - 1) ^ self.byte_addr_mask # mask for non byte address

    def connect(self, clk, rstn, hwrite, hsize, hburst, hport, htrans, hmastlock, haddr, hwdata, hready, hresp, hrdata):
        """ connect the memory to DUT AHB port"""
        self.clk = clk
        self.rstn = rstn
        self.hwrite = hwrite
        self.hsize = hsize
        self.hburst = hburst
        self.hport = hport
        self.htrans = htrans
        self.hmastlock = hmastlock
        self.haddr = haddr
        self.hwdata = hwdata
        self.hreadyout = hready
        self.hresp = hresp
        self.hrdata = hrdata

    def _addr_phase(self):
        """ Address phase """
        self.p_trans = False
        self.hreadyout <= 1  # always ready
        self.hresp <= 0      # always OK, no error
        if self.rstn.value.integer != 0:
            if self.htrans.value.integer == 2: # Only NONSEQ and IDLE are support
                self.p_trans = True
                self.p_write = self.hwrite.value.integer
                self.p_addr = self.haddr.value.integer
                self.p_size = self.hsize.value.integer

    def _bit_mask(self):
        """
        Generate bit mask to enable byte write
        Instead of using byte enable we use bit enable here.
        The corresponding bit will be set if that byte is writtable.
        """
        if self.p_size == 0: # byte
            num_of_byte = int(self.data_width / 8)
            byte_sel_mask = (1 << int(math.log(num_of_byte, 2))) - 1
            byte_sel = self.p_addr & byte_sel_mask
            return 0xFF << (byte_sel * 8)
        if self.p_size == 1: # halfword
            num_of_halfword = int(self.data_width / 16)
            halfword_sel_mask = (1 << int(math.log(num_of_halfword, 2))) - 1
            halfword_sel = (self.p_addr >> 1) & halfword_sel_mask
            print(f"halfword_sel_mask: {halfword_sel_mask}, halfword_sel: {halfword_sel}")
            return 0xFFFF << (halfword_sel * 16)
        if self.p_size == 2: # word
            num_of_word = int(self.data_width / 32)
            word_sel_mask = (1 << int(math.log(num_of_word, 2))) - 1
            word_sel = (self.p_addr >> 2) & word_sel_mask
            return 0xFFFFFFFF << (word_sel * 32)
        else:
            raise ValueError(f"hsize not supported: {self.p_size}")

    def _data_phase(self):
        """ Data phase """
        if self.p_trans:
            word_addr = self.p_addr & self.non_byte_addr_mask
            if self.p_write: # write
                wdata = self.hwdata.value.integer
                bit_en = self._bit_mask()
                self.ram.write(word_addr, wdata, bit_en)
            else: # read
                self.hrdata <= self.ram.read(word_addr)

    async def _steps(self):
        """ Things to be done for single clock """
        while True:
            await FallingEdge(self.clk)
            self._data_phase()
            self._addr_phase()

    def run(self):
        cocotb.fork(self._steps())
