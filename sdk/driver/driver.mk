#############################################################
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/10/2022
#############################################################
# veriRISCV
#############################################################

REPO_ROOT   = $(shell git rev-parse --show-toplevel)
DRIVER_PATH = $(REPO_ROOT)/sdk/driver
BOOT_PATH   = $(DRIVER_PATH)/boot

# C include directory
C_INCS += $(DRIVER_PATH)/system

# C source file
C_SRCS += $(BOOT_PATH)/_start.c
