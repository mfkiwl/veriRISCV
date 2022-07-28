#############################################################
# Makefile
#############################################################

LS ?= bram
LINKER_SCRIPT += $(BSP_PATH)/$(BOARD)/link_$(LS).ld
LINKER_SCRIPT += $(BSP_PATH)/$(BOARD)/common.ld
