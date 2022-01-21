###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: RAM.py
##
## Author: Heqing Huang
## Date Created: 01/19/2022
##
## ================== Description ==================
##
## Base class for RAM
##
###################################################################################################

import logging

class RAM:
    """
    Base class for RAM
    """

    def __init__(self, ram_file = None):
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