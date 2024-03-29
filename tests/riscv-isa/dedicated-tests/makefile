#=======================================================================
# Makefile for dedicated tests
#-----------------------------------------------------------------------

XLEN := 32

include test/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX 	?= riscv-none-embed-
RISCV_GCC 		?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS 	?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP 	?= $(RISCV_PREFIX)objdump --disassemble-all
RISCV_OBJCOPY 	?= $(RISCV_PREFIX)objcopy

vpath %.S

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -Ienv -Tenv/link.ld $$< -o generated/$$@
$(1)_tests += $$($(1)_p_tests)

$$($(1)_v_tests): $(1)-v-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -Ienv -Tenv/link.ld $$< -o generated/$$@
$(1)_tests += $$($(1)_v_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))

$(1): $$($(1)_tests_dump)

.PHONY: $(1)


tests += $$($(1)_tests)

endef

$(eval $(call compile_template,test,-march=rv32im -mabi=ilp32))

tests_dump = $(addsuffix .dump, $(tests))

all: $(tests_dump)

%.dump: %
	$(RISCV_OBJDUMP) generated/$< > generated/$@
	$(RISCV_OBJCOPY) -O verilog generated/$< generated/$<.verilog
	rm -r generated/$<

clean:
	rm -rf generated/*verilog generated/*dump
