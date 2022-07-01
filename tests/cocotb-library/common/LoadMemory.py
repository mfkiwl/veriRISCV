# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 06/30/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Load memory from memory file to the memory variable in verilog
# ------------------------------------------------------------------------------------------------

import logging
import sys
import re

def clearMemory(mem, size):
    while size > 0:
        mem[size].value = 0
        size -= 1

def loadFromFile(file, mem):
    """
        Read the memory content from a file.
        - Assume that the file has memory value for each "WORD" line by line
        - The word size of the data should be matching with the word size in verilog memory
        - Address should be continuous and is starting from 0
    """
    _log = logging.getLogger(f"cocotb.RAMLoader")
    FH = open(file, "r")
    size = 0
    lines  = FH.readlines()
    for value in lines:
        mem[size].value = int(value.rstrip(), 16)
        size += 1
    FH.close()
    _log.info(f"Read memory content from file: {file}. Memory size is {str(size * 4)} bytes, {str(size)} words")

#
#def loadFromVerilog(self, file, mem):
#    """
#        Read the memory content from the verilog file generated by objdump command.
#        Verilog file Format:
#        @00000000
#        93000000 13010000 93010000 13020000
#        93020000 13030000 93030000 13040000
#        ......
#        F3221034 93824200 73901234 73002030
#        731000C0
#        @00000310
#        01000000 00000000 00000000 00000000
#    """
#    FH = open(file, "r")
#    current_addr = 0
#    lines  = FH.readlines()
#    for value in lines:
#        if '@' in value:    # this is an address line
#            addr = int(value.rstrip()[1:], 16)
#        else:               # this is a data line
#            data = value.split()
#            for d in data:
#                mem[addr] = int(d, 16)
#                addr = addr + 4
#    FH.close()
#    self._log.info(f"Read memory content from verilog file: {file}")