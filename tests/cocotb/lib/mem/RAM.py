###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RAM.py
##
## Author: Heqing Huang
## Date Created: 01/21/2022
##
## ================== Description ==================
##
## Base class for A RAM Model
##
###################################################################################################

import logging

class RAM:
    """
    Base class for A RAM Model
    """

    def __init__(self, data_width, addr_width , ram_file = None):
        self.data_width = data_width
        self.addr_width = addr_width
        self.max_data = 1 << data_width
        self.ram_depth = 1 << addr_width
        self._log = logging.getLogger(f"cocotb.RAM")
        if ram_file:
            self._loadFromFile(ram_file)
        else:
            self.mem = {}

    def _loadFromFile(self, file):
        """
            Read the memory content from a file.
            !!! Assume that the file has memory value for each "WORD" line by line
            !!! Address is continuous and is starting from 0
        """
        FH = open(file, "r")
        size = 0
        data = {}
        lines  = FH.readlines()
        for value in lines:
            data[size*4] = int(value.rstrip(), 16)
            size += 1
        FH.close()
        self.mem = data
        self._log.info(f"Read memory content from file: {file}. Memory size is {str(size * 4)} bytes, {str(size)} words")

    def _get_integer(self, signal):
        try:
            return signal.value.integer
        except AttributeError:
            return signal
        except ValueError:
            return 0

    def _addr_check(self, addr):
        if addr > self.ram_depth - 1:
            assert ValueError(f"Address out of memory range. Range: {hex(self.ram_depth)}, Actual: {hex(addr)}")

    def _data_check(self, data):
        if data > self.max_data - 1:
            assert ValueError(f"Data out of memory size. Size: {hex(self.max_data)}, Actual: {hex(data)}")

    def read(self, addr):
        """ Read the ram """
        self._addr_check(addr)
        if addr in self.mem:
            return self.mem[addr]
        else:
            return 0

    def write(self, addr, data, bit_en):
        """ Write the ram """
        self._addr_check(addr)
        self._data_check(addr)
        if addr in self.mem:
            original_data = self.mem[addr]
        else:
            original_data = 0
        wdata = data & bit_en | original_data & ~bit_en
        self.mem[addr] = wdata