
tests = sanity riscv-tests

SRAM ?=

.PHONY: $(tests)

all: summary

$(tests): clean
	cd $@ && $(MAKE) SRAM=$(SRAM) | tee ../$@.log

summary: $(tests)
	@echo ""
	@echo ""
	@echo "---------------------------------"
	@echo "------------ SUMMARY ------------"
	@echo "---------------------------------"
	@grep -o "TESTS=.* PASS=.* FAIL=.* SKIP=.?*" *.log --color
	@echo "---------------------------------"


clean:
	rm -rf *.log
	rm -rf */*.vcd */*.xml */sim_build */__pycache__
