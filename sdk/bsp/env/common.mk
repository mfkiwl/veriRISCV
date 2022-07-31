#############################################################
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/10/2022
#############################################################
# veriRISCV
#############################################################

.PHONY: all
all: $(TARGET)

# different linker script
BRAM 	:= bram
SRAM 	:= sram

# different board target
DE2 	:= de2
ARTY 	:= arty

REPO_BASE = $(shell git rev-parse --show-toplevel)
BSP_BASE  = $(REPO_BASE)/sdk/bsp

DRIVER_DIR = $(BSP_BASE)/drivers
ENV_DIR = $(BSP_BASE)/env

# ASM source file
ASM_SRCS += $(ENV_DIR)/start.S
ASM_SRCS += $(ENV_DIR)/trap_entry.S

# C source file
C_SRCS += $(ENV_DIR)/init.c
C_SRCS += $(ENV_DIR)/trap.c
C_SRCS += $(ENV_DIR)/syscalls.c
C_SRCS += $(DRIVER_DIR)/gpio/gpio.c
C_SRCS += $(DRIVER_DIR)/uart/uart.c

# C include directory
C_INCS += $(ENV_DIR)
C_INCS += $(DRIVER_DIR)/gpio
C_INCS += $(DRIVER_DIR)/uart
C_INCS += $(DRIVER_DIR)/clic

INCLUDES += $(addprefix -I, $(C_INCS))

ifeq ($(DOWNLOAD),${BRAM})
LINKER_SCRIPT := $(ENV_DIR)/link_bram.ld
endif

ifeq ($(DOWNLOAD),${SRAM})
LINKER_SCRIPT := $(ENV_DIR)/link_sram.ld
endif

#############################################################
# Compilation Flag
#############################################################

LDFLAGS += -T $(LINKER_SCRIPT)

ifeq ($(USE_NANO),1)
LDFLAGS += --specs=nano.specs
endif

ifeq ($(NO_START_FILES),1)
LDFLAGS += -nostartfiles
endif

LDFLAGS += -Wl,-Map=$(TARGET).map
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--check-sections
LDFLAGS += -L$(ENV_DIR)

CFLAGS += -g
CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -ffunction-sections -fdata-sections -fno-common

ifeq ($(BOARD),${DE2})
CFLAGS += -DBOARD_DE2
endif

ifeq ($(BOARD),${ARTY})
CFLAGS += -DBOARD_ARTY
endif

#############################################################
# Command
#############################################################

ASM_OBJS := $(ASM_SRCS:.S=.o)
C_OBJS := $(C_SRCS:.c=.o)
DUMP_OBJS := $(C_SRCS:.c=.dump)
VERILOG_OBJS := $(C_SRCS:.c=.verilog)
MAP_OBJS := $(C_SRCS:.c=.map)

LINK_OBJS  += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS  += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(DUMP_OBJS) $(VERILOG_OBJS) $(MAP_OBJS)

$(TARGET): $(LINK_OBJS) $(LINK_DEPS)
	$(CC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	$(SIZE) $@

$(ASM_OBJS): %.o: %.S
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

clean:
	rm -f $(TARGET) $(CLEAN_OBJS) *.log
