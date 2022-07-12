#############################################################
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/10/2022
#############################################################
# veriRISCV
#############################################################

REPO_ROOT = $(shell git rev-parse --show-toplevel)
LIB_PATH  = $(REPO_ROOT)/sdk/lib
BOOT_PATH = $(LIB_PATH)/boot
NELIB_PATH = $(LIB_PATH)/newlib

# C include directory
C_INCS += $(LIB_PATH)/system
C_INCS += $(LIB_PATH)/driver/uart

# C source file
C_SRCS += $(BOOT_PATH)/init.c
C_SRCS += $(NELIB_PATH)/syscalls.c
C_SRCS += $(LIB_PATH)/driver/uart/avalon_uart.c

# ASM source file
ASM_SRCS += $(BOOT_PATH)/start.S
