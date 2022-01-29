# -----------------------------------------
# Makefile
# -----------------------------------------

# -----------------------------------------
# Top level Language
# -----------------------------------------
TOPLEVEL_LANG = verilog

# -----------------------------------------
# Path Variable
# -----------------------------------------
REPO_ROOT     	= $(shell git rev-parse --show-toplevel)
CORE_PATH  		= $(REPO_ROOT)/src/rtl/core


# -----------------------------------------
# Source files
# -----------------------------------------

include ../filelists.mk

VERILOG_SOURCES += $(RTL_FILES)

# -----------------------------------------
# Simulator config
# -----------------------------------------

TOPLEVEL = veririscv_core
MODULE 	 = BasicTB

# -----------------------------------------
# Cocotb config
# -----------------------------------------
export COCOTB_REDUCED_LOG_FMT = 1

# -----------------------------------------
# Test config
# -----------------------------------------

include $(shell cocotb-config --makefiles)/Makefile.sim

# -----------------------------------------
# Other
# -----------------------------------------

clean_all: clean
	rm -rf __pycache__
	rm -rf results.xml *.vcd