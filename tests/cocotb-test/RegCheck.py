# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 01/20/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Check Register Content against golden file
# ------------------------------------------------------------------------------------------------

import logging
import sys
import re

class RegCheck:
    """
    Check Register Content against golden file
    """

    def __init__(self, reg, golden = None):
        self._log = logging.getLogger(f"cocotb.RegCheck")
        self.reg = reg
        if golden:
            self._loadRegFile(golden)
        else:
            raise AttributeError("Need to give golden register file")


    def _loadRegFile(self, file):
        """
            Read the register content from a file.
            Example format:
            ra (x1)
            0xffffffff
            sp (x2)
            0x000000ff
        """
        FH = open(file, "r")
        self.recoded_reg = []
        self.register = {}
        while True:
            reg = FH.readline().rstrip()
            value = FH.readline().rstrip()
            if (reg == ""):
                self._log.info("Loaded register golden file")
                break
            if (value == ""):
                raise ValueError("missing register value in golden file")
            reg = reg.rstrip()
            pattern = re.findall(r"(\w+) \((\w+)\)", reg)
            if not pattern:
                raise ValueError(f"Wrong register format: {reg}")
            reg_num = int(pattern[0][1][1:])
            value = int(value.rstrip()[2:], 16) # get rid of 0x and read in as decimal
            self.recoded_reg.append(reg_num)
            self.register[reg_num] = value

        FH.close()
        self._log.info(f"Read golden register file from: {file}.")
        self._log.info(f"Register read: {self.recoded_reg}")

    def checkRegister(self):
        for reg in self.recoded_reg:
            value = self.reg[reg].value
            if value != self.register[reg]:
                raise ValueError(f"Wrong register data on register {reg}. Expected: {hex(self.register[reg])}, Actual: {hex(value)}")
        self._log.info("*** Register Check PASS ***")
