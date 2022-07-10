REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
CPU_CORE_PATH = $(REPO_ROOT)/src/rtl/core
IP_PATH = $(REPO_ROOT)/src/rtl/ip
AVN_BUS_PATH = $(IP_PATH)/bus/avalon_standard
GPIO_PATH = $(IP_PATH)/gpio

include $(CPU_CORE_PATH)/veriRISCV_core.mk

VERILOG_SOURCES += $(AVN_BUS_PATH)/bus_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_arbiter.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_decoder.sv
VERILOG_SOURCES += $(AVN_BUS_PATH)/avalon_s_crossbar.sv

VERILOG_SOURCES += $(GPIO_PATH)/avalon_gpio.sv

VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_1rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/ip/memory/avalon_ram_2rw.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_avalon_bus.sv
VERILOG_SOURCES += $(REPO_ROOT)/src/rtl/soc/veriRISCV_soc.sv
