
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
TOP = de2_top
SDC	= $(PWD)/src/de2.sdc
PIN = $(PWD)/src/de2_pin.tcl

include $(GIT_ROOT)/src/rtl/soc/veriRISCV_soc.mk

VERILOG += $(PWD)/src/pll.v
VERILOG += $(PWD)/src/de2_top.sv
VERILOG += $(VERILOG_SOURCES)

SEARCH += $(GIT_ROOT)/src/rtl/core/include
SEARCH += $(GIT_ROOT)/src/rtl/soc

ifeq ($(SRAM), 1)
	DEFINE += SRAM
endif

ifeq ($(BRAM2C), 1)
	DEFINE += BRAM2C
endif

include $(GIT_ROOT)/tools/quartus/makefile.nonqsys.mk
