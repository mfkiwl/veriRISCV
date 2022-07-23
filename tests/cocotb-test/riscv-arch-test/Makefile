# -----------------------------------------
# Makefile
# -----------------------------------------

MODULE = Tests

include ../common/makefile.mk

ifeq ($(SIM),verilator)
EXTRA_ARGS += "-DMAIN_MEMORY_AW=24"
endif

gen_test:
	python3 GenTests.py