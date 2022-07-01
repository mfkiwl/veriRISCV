
tests = basic riscv-tests

.PHONY: $(tests)

all: summary

$(tests):
	cd $@ && $(MAKE) | tee ../$@.log

summary: $(tests)
	@echo ""
	@echo ""
	@echo "******** SUMMARY ********"
	@grep -o "TESTS=.* PASS=.* FAIL=.* SKIP=.?*" *.log


clean:
	rm -rf *.log
	rm -rf */*.vcd */*.xml */sim_build */__pycache__
