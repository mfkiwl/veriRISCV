
# -----------------------------------------
# Makefile
# -----------------------------------------

TARGET_DESIGN 	= veriRISCV
TARGET_PATH 	= riscv-arch-test/riscv-target

build: link_target
	cd riscv-arch-test && $(MAKE) RISCV_TARGET=$(TARGET_DESIGN) clean
	cd riscv-arch-test && $(MAKE) RISCV_TARGET=$(TARGET_DESIGN) RISCV_DEVICE=I build
	cd riscv-arch-test && $(MAKE) RISCV_TARGET=$(TARGET_DESIGN) RISCV_DEVICE=M build
#cd riscv-arch-test && $(MAKE) RISCV_TARGET=$(TARGET_DESIGN) RISCV_DEVICE=privilege build

link_target:
	@cd $(TARGET_PATH) && rm -rf $(TARGET_DESIGN)
	@cd $(TARGET_PATH) && ln -s ../../$(TARGET_DESIGN)