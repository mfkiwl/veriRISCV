# veriRISCV

## Introduction

The purpose of this repository is to get some hands-on experience with RISC-V ISA, cpu design, soc design and bare-metal embedded system design.

The final goal is to create a self-contained, usable tiny MCU that can be used to create some interesting project. This is divided into 2 parts: hardware(HW) and software(SW).

The goal for HW is to create a RISC-V cpu core, some peripherals, and a complete SoC putting the core and peripherals together to create a MCU. The HDL will be written in verilog and will be implemented in FPGA. The target FPGA is mainly Xilinx Arty A7 FPGA and maybe one FPGA from Intel.

The goal for SW is to create a usable bare-metal SW environment for the MCU including boot code, drivers for peripherals and etc. (more TBD)

The SoC design will be based on [SiFive E300 platform](https://static.dev.sifive.com/SiFive-E300-platform-reference-manual-v1.0.1.pdf). The address map of the SoC and the peripherals (mainly functions and registers) will be compliant to the SiFive E300 design.

## Planned Hardware Feature and Architecture

### Feature

1. The RISC-V cpu core will be supporting RV32IM and Zicsr ISA set.
2. The RISC-V cpu core will be supporting exception and interrupt related CSR register.
3. The SoC will be supporting all the E300 peripherals that can be implemented in FPGA.

### Architecture

1. The RISC-V cpu core will be a classic 5-stage pipeline architecture with separated Instruction and Data bus.
2. The SoC will be connected using AHB bus for memory and APB bus for peripherals.

## Planned Software Feature and Architecture

TBD