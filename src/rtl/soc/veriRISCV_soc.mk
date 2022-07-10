REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
CPU_CORE_PATH = $(REPO_ROOT)/src/rtl/core
AVN_BUS_PATH = $(REPO_ROOT)/src/rtl/ip/bus/avalon_standard

include $(CPU_CORE_PATH)/veriRISCV_core.mk

VERILOG_SOURCES += $(AVN_BUS_PATH)/bus_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_decoder.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_crossbar.sv

VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_1rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_2rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_avalon_bus.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_soc.sv
