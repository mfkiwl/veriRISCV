# -----------------------------------------
# Makefile
# -----------------------------------------

# -----------------------------------------
# Defaults
# -----------------------------------------
SIM ?= verilator
TOPLEVEL_LANG = verilog

# -----------------------------------------
# Path Variable
# -----------------------------------------
REPO_ROOT = $(shell git rev-parse --show-toplevel)
CORE_PATH = $(REPO_ROOT)/src/rtl/core
SOC_PATH = $(REPO_ROOT)/src/rtl/soc
TB_PATH = $(REPO_ROOT)/tests/cocotb-test/tb

# -----------------------------------------
# Source files
# -----------------------------------------

include $(SOC_PATH)/veriRISCV_soc.mk
VERILOG_SOURCES += $(TB_PATH)/SRAM.sv
VERILOG_SOURCES += $(TB_PATH)/tb_top.sv

# -----------------------------------------
# Simulator config
# -----------------------------------------

TOPLEVEL = tb_top

# -----------------------------------------
# Cocotb config
# -----------------------------------------
export COCOTB_REDUCED_LOG_FMT = 1

# -----------------------------------------
# Test config
# -----------------------------------------

DUMP ?= 0
COVR ?= 0
SRAM ?= 0

ifeq ($(SIM),verilator)
EXTRA_ARGS += -I$(CORE_PATH)/include
EXTRA_ARGS += -I$(SOC_PATH)
ifeq ($(COVR), 1)
	EXTRA_ARGS += --coverage
endif
ifeq ($(SRAM), 1)
	EXTRA_ARGS += -DSRAM
endif
ifeq ($(DUMP), 1)
	EXTRA_ARGS += --trace-fst --trace-structs
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

# -----------------------------------------
# Other
# -----------------------------------------

clean_all: clean
	rm -rf __pycache__
	rm -rf results.xml *.vcd