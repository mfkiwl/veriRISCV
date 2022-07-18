#############################################################
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/10/2022
#############################################################
# veriRISCV
#############################################################
# Makefile to compile C program
#############################################################

#############################################################
# RISCV ISA Configuration
#############################################################

RISCV_ARCH := rv32i
RISCV_ABI  := ilp32

#############################################################
# Compilation Tools
#############################################################

RISCV_GCC     := riscv-none-embed-gcc
RISCV_OBJDUMP := riscv-none-embed-objdump
RISCV_OBJCOPY := riscv-none-embed-objcopy
RISCV_GDB     := riscv-none-embed-gdb
RISCV_AR      := riscv-none-embed-ar
RISCV_SIZE    := riscv-none-embed-size

SIZE = $(RISCV_SIZE)
CC   = $(RISCV_GCC)
AR   = $(RISCV_AR)

#############################################################
# Compilation Flag
#############################################################

LDFLAGS += -T $(LINKER_SCRIPT)  -nostartfiles --specs=nano.specs -Wl,-Map=$(TARGET).map -Wl,--gc-sections  -Wl,--check-sections
CFLAGS  += -g -march=$(RISCV_ARCH) -mabi=$(RISCV_ABI)

#############################################################
# Board and source files
#############################################################

REPO_ROOT   = $(shell git rev-parse --show-toplevel)
BSP_PATH    = $(REPO_ROOT)/sdk/bsp
LIB_PATH    = $(REPO_ROOT)/sdk/lib
TOOL_PATH   = $(REPO_ROOT)/sdk/tool
BOARD		?= de2

include $(BSP_PATH)/$(BOARD)/$(BOARD).mk
include $(LIB_PATH)/lib.mk


# additional C include files
C_INCS += $(BSP_PATH)/$(BOARD)


INCLUDES = $(addprefix -I, $(C_INCS))

#############################################################
# Command
#############################################################

C_OBJS 			:= $(C_SRCS:.c=.o)
ASM_OBJS 		:= $(ASM_SRCS:.S=.o)
DUMP_OBJS 		:= $(C_SRCS:.c=.dump)
VERILOG_OBJS 	:= $(C_SRCS:.c=.verilog)

LINK_OBJS  += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS  += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(DUMP_OBJS) $(VERILOG_OBJS)

dumpasm: software
	$(RISCV_OBJDUMP) -D $(PROGRAM_ELF) > $(PROGRAM_ELF).dump
	$(RISCV_OBJCOPY) $(PROGRAM_ELF) -O verilog $(PROGRAM_ELF).verilog

software: $(TARGET)

download: $(TARGET).verilog
	$(TOOL_PATH)/UartDownload.py -f $< -b $(BOARD)

$(TARGET): $(LINK_OBJS) $(LINK_DEPS)
	$(CC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	$(RISCV_SIZE) $@

$(ASM_OBJS): %.o: %.S
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

clean:
	rm -f $(TARGET) $(CLEAN_OBJS)
