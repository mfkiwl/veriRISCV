#############################################################
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/27/2022
#############################################################
# veriRISCV
#############################################################

#############################################################
# Configuration
#############################################################

USE_NANO        := 1
NO_START_FILES	:= 1

RISCV_ARCH := rv32i
RISCV_ABI  := ilp32

BOARD  	 ?= de2
PROGRAM  ?= blink
DOWNLOAD ?= bram

ifeq ($(RISCV_ARCH),)
$(error $(board_dir)/board.mk must set RISCV_ARCH, the RISC-V ISA string to target)
endif

ifeq ($(RISCV_ABI),)
$(error $(board_dir)/board.mk must set RISCV_ABI, the ABI to target)
endif

#############################################################
# Prints help message
#############################################################
.PHONY: help
help:
	@echo " veriRISCV Processor Software Development Kit "
	@echo ""
	@echo " software [PROGRAM=$(PROGRAM) BOARD=$(BOARD)]:"
	@echo "    Build a software program to load with the debugger."
	@echo ""
	@echo " uart_upload [PROGRAM=$(PROGRAM) BOARD=$(BOARD)]:"
	@echo "    Launch UartDownload script to flash your program to the on-board Memory/Flash."
	@echo ""
	@echo " dasm [PROGRAM=$(BOARD)]:"
	@echo "     Generates the dissassembly output of 'objdump -D' to stdout."
	@echo ""

.PHONY: clean
clean:


#############################################################
# This section defines the tool-chain
#############################################################

RISCV_GCC     := riscv-none-embed-gcc
RISCV_OBJDUMP := riscv-none-embed-objdump
RISCV_OBJCOPY := riscv-none-embed-objcopy
RISCV_GDB     := riscv-none-embed-gdb
RISCV_AR      := riscv-none-embed-ar
RISCV_SIZE    := riscv-none-embed-size

#############################################################
# This Section is for Software Compilation
#############################################################

PROGRAM_DIR = software/$(PROGRAM)
PROGRAM_ELF = software/$(PROGRAM)/$(PROGRAM)
TOOLS_DIR 	= bsp/tools

.PHONY: software_clean
software_clean:
	$(MAKE) -C $(PROGRAM_DIR) \
	BSP_BASE=$(abspath bsp) \
	BOARD=$(BOARD)  \
	clean

.PHONY: software
software: software_clean
	$(MAKE) -C $(PROGRAM_DIR) \
	SIZE=$(RISCV_SIZE) CC=$(RISCV_GCC) AR=$(RISCV_AR) \
	RISCV_ARCH=$(RISCV_ARCH) RISCV_ABI=$(RISCV_ABI) \
	USE_NANO=$(USE_NANO) \
	NO_START_FILES=$(NO_START_FILES)  \
	BSP_BASE=$(abspath bsp) \
	BOARD=$(BOARD) \
	DOWNLOAD=$(DOWNLOAD)

dasm: software
	$(RISCV_OBJDUMP) -S $(PROGRAM_ELF) > $(PROGRAM_ELF).dump
	$(RISCV_OBJCOPY) $(PROGRAM_ELF) -O verilog $(PROGRAM_ELF).verilog

uart_upload: $(PROGRAM_ELF).verilog
	$(TOOLS_DIR)/UartDownload.py -f $< -b $(BOARD)

uart_read: download.log
	$(TOOLS_DIR)/UartRead.py -f $< -b $(BOARD)

#############################################################
# pre defined command to compile software
#############################################################

programs = blink hello_riscv fibonacci coremark interrupt uart_rw
upload_programs = $(addprefix upload_, $(programs))

$(programs):
	$(MAKE) dasm PROGRAM=$@

$(upload_programs):
	$(MAKE) uart_upload PROGRAM=$(subst upload_,,$@)
