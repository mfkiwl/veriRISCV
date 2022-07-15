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
import math

def clearMemory(mem, size):
    while size > 0:
        mem[size].value = 0
        size -= 1

def loadFromVerilogDump(file, mem, size=1):
    """
        Load the instruction from verilog dump
        size: the number of data to format a word
    """
    _log = logging.getLogger(f"cocotb.RAMLoader")
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
    _log.info(f"Read memory content from verilog file: {file}")
