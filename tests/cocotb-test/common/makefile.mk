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
REPO_ROOT     	= $(shell git rev-parse --show-toplevel)
CORE_PATH  		= $(REPO_ROOT)/src/rtl/core
SOC_PATH  		= $(REPO_ROOT)/src/rtl/soc

# -----------------------------------------
# Source files
# -----------------------------------------

include $(SOC_PATH)/veriRISCV_soc.mk

# -----------------------------------------
# Simulator config
# -----------------------------------------

TOPLEVEL = veriRISCV_soc

# -----------------------------------------
# Cocotb config
# -----------------------------------------
export COCOTB_REDUCED_LOG_FMT = 1

# -----------------------------------------
# Test config
# -----------------------------------------

DUMP ?= 0
COVR ?= 0

ifeq ($(SIM),verilator)
EXTRA_ARGS += -I$(CORE_PATH)/include
EXTRA_ARGS += -I$(SOC_PATH)
ifeq ($(COVR), 1)
	EXTRA_ARGS += --coverage
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