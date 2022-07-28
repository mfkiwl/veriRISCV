#############################################################
# Makefile for coremark
#############################################################

#############################################################
# SRC files
#############################################################


C_SRCS += core_list_join.c
C_SRCS += core_main.c
C_SRCS += core_matrix.c
C_SRCS += core_portme.c
C_SRCS += core_state.c
C_SRCS += core_util.c
C_SRCS += cvt.c

C_INCS += $(PWD)

#############################################################
# Config
#############################################################

# optimizations
CFLAGS := -O2
CFLAGS += -fno-common
#CFLAGS += -funroll-loops
CFLAGS += -finline-functions
CFLAGS += --param max-inline-insns-auto=20
CFLAGS += -falign-functions=4
CFLAGS += -falign-jumps=4
CFLAGS += -falign-loops=4

CFLAGS += -DITERATIONS=500
CFLAGS += -DFLAGS_STR=\""$(CFLAGS)"\"

#############################################################
# Command
#############################################################

TARGET = coremark

include $(BSP_BASE)/env/common.mk
