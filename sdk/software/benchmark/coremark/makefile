#############################################################
# Makefile for coremark
#############################################################

#############################################################
# SRC files
#############################################################

REPO_ROOT = $(shell git rev-parse --show-toplevel)

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

#CFLAGS := -O2 -fno-common -funroll-loops -finline-functions --param max-inline-insns-auto=20 -falign-functions=4 -falign-jumps=4 -falign-loops=4
#CFLAGS := -O2 -fno-common -finline-functions --param max-inline-insns-auto=20 -falign-functions=4 -falign-jumps=4 -falign-loops=4
CFLAGS :=
CFLAGS += -DFLAGS_STR=\""$(CFLAGS)"\"
CFLAGS += -DITERATIONS=1

#############################################################
# Command
#############################################################

TARGET = coremark

PROGRAM     = $(TARGET)
PROGRAM_ELF = $(PROGRAM)

COMMON_BASE = ../../common

include $(REPO_ROOT)/sdk/script/compile.mk