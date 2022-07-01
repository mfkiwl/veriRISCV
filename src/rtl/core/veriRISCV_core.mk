REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
CPU_CORE_PATH = $(REPO_ROOT)/src/rtl/core

VERILOG_SOURCES += $(CPU_CORE_PATH)/alu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/bu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/decoder.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/EX.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/hdu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/ID.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/IF.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/lsu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/MEM.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/pc.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/regfile.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/veriRISCV_core.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/WB.sv

VERILOG_INCLUDE += $(CPU_CORE_PATH)/include