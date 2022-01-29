############################################################
# makefile for running vivado
############################################################

############################################################
# Variables
############################################################

REPO_ROOT     	= $(shell git rev-parse --show-toplevel)

# RTL SRC
CORE_PATH	= $(REPO_ROOT)/src/rtl/core
include filelists.mk
_RTL_SRC	+= $(RTL_FILES)

# XDC
#_XDC	+= constraints/constraints.xdc
#_XDC	+= constraints/io.xdc
_XDC	+= xdc/timing.xdc

export PRJ_NAME 	= arty
export TOP 			= veririscv_core
export DEVICE 	    = xc7a35ticsg324-1L
export RTL_SRC     	= $(_RTL_SRC)
export XDC         	= $(_XDC)

OUTPUT = $(PRJ_NAME)/output

############################################################
# Commands
############################################################

all: clean build pgm

build: $(OUTPUT)/$(TOP).bit

pgm:
	vivado -mode tcl -source scripts/program.tcl | tee program.log

$(OUTPUT)/$(TOP).bit:
	vivado -mode tcl -source scripts/build.tcl | tee build.log

clean:
	rm -rf arty vivado* .Xil *.jou *.log