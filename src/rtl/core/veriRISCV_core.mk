REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
CPU_CORE_PATH = $(REPO_ROOT)/src/rtl/core

VERILOG_SOURCES += $(CPU_CORE_PATH)/alu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/multiplier.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/divider.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/bu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/decoder.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/EX.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/hdu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/ID.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/IF.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/lsu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/MEM.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/ifu.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/regfile.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/mcsr.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/csr.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/trap_ctrl.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/WB.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/cache/cache_set.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/cache/dir_cache.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/cache/sa_cache.sv
VERILOG_SOURCES += $(CPU_CORE_PATH)/cache/cache.sv

VERILOG_SOURCES += $(CPU_CORE_PATH)/veriRISCV_core.sv

VERILOG_INCLUDE += $(CPU_CORE_PATH)/include
