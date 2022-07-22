#!/usr/bin/python3
# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/22/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Read data from some address
# ------------------------------------------------------------------------------------------------

import sys
import argparse
import serial
from serial.tools.list_ports import comports

PORT_NAME = {
    "arty": "Digilent USB Device",
    "de2" : "USB-Serial Controller"
}

class uartRead:
    def __init__(self, port, baudrate=115200, inLogFile='download.log', outLogFile='read.log'):
        """
            @param size: instruction rom size in KB
            @param baudrate: uart baudrate
        """
        self.baudrate = baudrate
        self.port = port
        self.inLogFile = inLogFile
        self.outLogFile = outLogFile

    def setupUart(self):
        """ Setup uart port """
        self.serPort = serial.Serial(self.port, self.baudrate)

    def uartWrite(self, data):
        return self.serPort.write(data)

    def startCmd(self):
        cmd = [0x22, 0x22, 0x22, 0x22, 0x50, 0x50, 0x50, 0x50] # send LSB first
        self.uartWrite(cmd)

    def endCmd(self):
        cmd = [0xEE, 0xEE, 0xEE, 0xEE, 0x50, 0x50, 0x50, 0x50]
        self.uartWrite(cmd)

    def read(self):
        """
        Read data base on the address specified
        """
        print("Start reading...")
        FH = open(self.inLogFile, "r")
        LOG = open(self.outLogFile, "w")
        lines  = FH.readlines()
        for value in lines:
            addr, data = value.split(':')
            addr = int(addr, 16)
            data = int(data.rstrip(), 16)
            # send the address
            self.uartWrite([(addr >> 0) & 0xFF])
            self.uartWrite([(addr >> 8) & 0xFF])
            self.uartWrite([(addr >> 16) & 0xFF])
            self.uartWrite([(addr >> 25) & 0xFF])
            # send 4 dummy data
            self.uartWrite([0x00])
            self.uartWrite([0x00])
            self.uartWrite([0x00])
            self.uartWrite([0x00])
            dataByte = self.serPort.read(4)
            recvData = int.from_bytes(dataByte, "little")
            LOG.write(f"{hex(addr)}: {hex(recvData)}\n")
            if data != recvData:
                print(f"Received different data at address {hex(addr)}. Expected data {hex(data)}. Actual data {hex(recvData)}")
        print("Read complete...")

    def run(self):
        self.setupUart()
        self.startCmd()
        self.read()
        self.endCmd()

def cmdParser():
    parser = argparse.ArgumentParser(description='Upload Instruction ROM through Uart')
    parser.add_argument('-file', '-f', type=str, required=True, nargs='?', help='The Instruction ROM file')
    parser.add_argument('-board', '-b',  type=str, required=True, nargs='?', help='The FPGA board')
    return parser.parse_args()

def getComport(board):
    all_port_info = comports()
    print("All com port info:")
    print("------------------------------------------")
    for p, des, _ in all_port_info:
        print(p, des)
    print("------------------------------------------")
    for p, des, _ in all_port_info:
        if PORT_NAME[board] in des:
            print(f"Found com ports {p} for {board} board")
            return p
    raise ValueError("Did not find com port")


if __name__ == "__main__":
    args = cmdParser()
    board = args.board
    port = getComport(board)
    uartRead = uartRead(port)
    uartRead.run()
