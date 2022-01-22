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
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge

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
        self._log = logging.getLogger(f"cocotb.AHBLitePort")

        self.p_trans = False    # p stands for pending
        self.p_write = 0
        self.p_addr = 0
        self.p_wdata = 0

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
                self.p_wdata = self.hwdata.value.integer


    def _data_phase(self):
        """ Data phase """
        if self.p_trans:
            if self.p_write: # write
                self.ram.write(self.p_addr, self.p_wdata)
            else: # read
                self.hrdata <= self.ram.read(self.p_addr)

    async def _steps(self):
        """ Things to be done for single clock """
        while True:
            self._data_phase()
            await RisingEdge(self.clk)
            self._addr_phase()


    def run(self):
        cocotb.fork(self._steps())
