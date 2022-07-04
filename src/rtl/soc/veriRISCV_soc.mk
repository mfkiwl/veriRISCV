REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
CPU_CORE_PATH = $(REPO_ROOT)/src/rtl/core

include $(CPU_CORE_PATH)/veriRISCV_core.mk

VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_1rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_2rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_soc.sv