
###################################################################################################
##
## Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
##
## ~~~ veriRISCV ~~~
##
## Module Name: AHBLiteRAM_1rw.py
##
## Author: Heqing Huang
## Date Created: 01/21/2022
##
## ================== Description ==================
##
## AHBLite RAM with 1 RW port
##
###################################################################################################

import cocotb

from RAM import RAM
from AHBLitePortRAM import AHBLitePortRAM

class AHBLiteRAM_1rw():
    """ AHBLite RAM with 1 RW port """

    def __init__(self, data_width, addr_width, ram_file = None):
        self.ram = RAM(data_width, addr_width, ram_file)
        self.ahbPort = AHBLitePortRAM(data_width, addr_width, self.ram)

    def run(self):
        self.ahbPort.run()
