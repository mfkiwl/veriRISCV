
#########################################################
# Makefile for project
#########################################################

# Common variable
GIT_ROOT = $(shell git rev-parse --show-toplevel)
PWD		 = $(shell pwd)
OUT_DIR  = $(PWD)/output

#########################################################
# Project specific variable
#########################################################

# Different SoC Configuration
SRAM ?= 0
BRAM2C ?= 0

#########################################################
# Configure variable
#########################################################

PROJECT = veriRISCV

TOP = arty_top

XDC += $(PWD)/src/arty_pin.xdc
XDC += $(PWD)/src/arty_timing.xdc

include $(GIT_ROOT)/src/rtl/soc/veriRISCV_soc.mk

VERILOG += $(VERILOG_SOURCES)
VERILOG += $(PWD)/src/mmcm_clk_wiz.v
VERILOG += $(PWD)/src/mmcm.v
VERILOG += $(PWD)/src/arty_top.sv

SEARCH += $(GIT_ROOT)/src/rtl/core/include
SEARCH += $(GIT_ROOT)/src/rtl/soc

ifeq ($(BRAM2C), 1)
	DEFINE += BRAM2C
endif

include $(GIT_ROOT)/tools/vivado/makefile.mk
