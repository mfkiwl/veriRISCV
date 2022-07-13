#################################################
# makefile
#################################################

TESTS := branch jal_jalr load_stall load_store logic_forward logic_simple lui_auipc
ALL := $(addsuffix .verilog, $(TESTS))

all: $(ALL)

%.verilog: %.o
	riscv-none-embed-objcopy -O verilog $< $@

%.o: %.S
	riscv-none-embed-gcc -march=rv32im -mabi=ilp32 -c $<

clean:
	rm -rf *.o *.verilog
