
###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RAM_1RW.py
##
## Author: Heqing Huang
## Date Created: 01/19/2022
##
## ================== Description ==================
##
## RAM 1RW port
##
###################################################################################################

import cocotb
from cocotb.triggers import Timer, RisingEdge

from RAM import RAM

class RAM_1RW(RAM):
    """
        cocotb model for 1RW port RAM
        Read and write will take 1 clock latency
    """

    def __init__(self, ram_file = None):
        super().__init__(ram_file)
        self.wen_reg = 0
        self.addr_reg = 0
        self.wdata_reg = 0


    def connect(self, clk, wen, addr, rdata, wdata):
        """ connect the memory to DUT """
        self.clk = clk
        self.wen = wen
        self.addr = addr
        self.rdata = rdata
        self.wdata = wdata

    def _read(self):
        """
            Memory Read
            !!! Assume the address is work address
        """
        try:
            self.rdata <= self.mem[self.addr_reg]
        except KeyError:
            self.rdata <= 0

    def _write(self):
        if (self._get_integer(self.wen_reg) == 1):
            self.mem[addr_reg] = wdata_reg.integer


    async def _step(self):
        while True:
            await RisingEdge(self.clk)
            self._read()
            self._write()
            # Capture the command, address, and data
            self.wen_reg = self._get_integer(self.wen)
            self.addr_reg = self._get_integer(self.addr)
            self.wdata_reg = self._get_integer(self.wdata)
            #print(self.wen_reg, self.addr_reg, self.wdata_reg)

    def run(self):
        cocotb.fork(self._step())
