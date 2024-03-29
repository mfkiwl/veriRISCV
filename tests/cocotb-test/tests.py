
# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 2022-08-06
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------

from env import riscv_tests, riscv_arch_test, sanity_test, dedicated_tests
import cocotb

# sanity Test

@cocotb.test()
async def sanity_tests_logic_simple(dut):
    await sanity_test(dut, 'logic_simple')

@cocotb.test()
async def sanity_tests_logic_forward(dut):
    await sanity_test(dut, 'logic_forward')

@cocotb.test()
async def sanity_tests_load_store(dut):
    await sanity_test(dut, 'load_store')

@cocotb.test()
async def sanity_tests_branch(dut):
    await sanity_test(dut, 'branch')

@cocotb.test()
async def sanity_tests_lui_auipc(dut):
    await sanity_test(dut, 'lui_auipc')

@cocotb.test()
async def sanity_tests_load_stall(dut):
    await sanity_test(dut, 'load_stall')

@cocotb.test()
async def sanity_tests_jal_jalr(dut):
    await sanity_test(dut, 'jal_jalr')

# riscv-tests Test

@cocotb.test()
async def riscv_tests_jal(dut):
    await riscv_tests(dut, 'rv32ui-p-jal')

@cocotb.test()
async def riscv_tests_jalr(dut):
    await riscv_tests(dut, 'rv32ui-p-jalr')

@cocotb.test()
async def riscv_tests_beq(dut):
    await riscv_tests(dut, 'rv32ui-p-beq')

@cocotb.test()
async def riscv_tests_bne(dut):
    await riscv_tests(dut, 'rv32ui-p-bne')

@cocotb.test()
async def riscv_tests_blt(dut):
    await riscv_tests(dut, 'rv32ui-p-blt')

@cocotb.test()
async def riscv_tests_bge(dut):
    await riscv_tests(dut, 'rv32ui-p-bge')

@cocotb.test()
async def riscv_tests_bltu(dut):
    await riscv_tests(dut, 'rv32ui-p-bltu')

@cocotb.test()
async def riscv_tests_bgeu(dut):
    await riscv_tests(dut, 'rv32ui-p-bgeu')

@cocotb.test()
async def riscv_tests_lui(dut):
    await riscv_tests(dut, 'rv32ui-p-lui')

@cocotb.test()
async def riscv_tests_auipc(dut):
    await riscv_tests(dut, 'rv32ui-p-auipc')

@cocotb.test()
async def riscv_tests_addi(dut):
    await riscv_tests(dut, 'rv32ui-p-addi')

@cocotb.test()
async def riscv_tests_slti(dut):
    await riscv_tests(dut, 'rv32ui-p-slti')

@cocotb.test()
async def riscv_tests_sltiu(dut):
    await riscv_tests(dut, 'rv32ui-p-sltiu')

@cocotb.test()
async def riscv_tests_xori(dut):
    await riscv_tests(dut, 'rv32ui-p-xori')

@cocotb.test()
async def riscv_tests_ori(dut):
    await riscv_tests(dut, 'rv32ui-p-ori')

@cocotb.test()
async def riscv_tests_andi(dut):
    await riscv_tests(dut, 'rv32ui-p-andi')

@cocotb.test()
async def riscv_tests_slli(dut):
    await riscv_tests(dut, 'rv32ui-p-slli')

@cocotb.test()
async def riscv_tests_srli(dut):
    await riscv_tests(dut, 'rv32ui-p-srli')

@cocotb.test()
async def riscv_tests_srai(dut):
    await riscv_tests(dut, 'rv32ui-p-srai')

@cocotb.test()
async def riscv_tests_add(dut):
    await riscv_tests(dut, 'rv32ui-p-add')

@cocotb.test()
async def riscv_tests_sub(dut):
    await riscv_tests(dut, 'rv32ui-p-sub')

@cocotb.test()
async def riscv_tests_sll(dut):
    await riscv_tests(dut, 'rv32ui-p-sll')

@cocotb.test()
async def riscv_tests_slt(dut):
    await riscv_tests(dut, 'rv32ui-p-slt')

@cocotb.test()
async def riscv_tests_sltu(dut):
    await riscv_tests(dut, 'rv32ui-p-sltu')

@cocotb.test()
async def riscv_tests_xor(dut):
    await riscv_tests(dut, 'rv32ui-p-xor')

@cocotb.test()
async def riscv_tests_srl(dut):
    await riscv_tests(dut, 'rv32ui-p-srl')

@cocotb.test()
async def riscv_tests_sra(dut):
    await riscv_tests(dut, 'rv32ui-p-sra')

@cocotb.test()
async def riscv_tests_or(dut):
    await riscv_tests(dut, 'rv32ui-p-or')

@cocotb.test()
async def riscv_tests_and(dut):
    await riscv_tests(dut, 'rv32ui-p-and')

@cocotb.test()
async def riscv_tests_lb(dut):
    await riscv_tests(dut, 'rv32ui-p-lb')

@cocotb.test()
async def riscv_tests_lbu(dut):
    await riscv_tests(dut, 'rv32ui-p-lbu')

@cocotb.test()
async def riscv_tests_lh(dut):
    await riscv_tests(dut, 'rv32ui-p-lh')

@cocotb.test()
async def riscv_tests_lhu(dut):
    await riscv_tests(dut, 'rv32ui-p-lhu')

@cocotb.test()
async def riscv_tests_lw(dut):
    await riscv_tests(dut, 'rv32ui-p-lw')

@cocotb.test()
async def riscv_tests_sb(dut):
    await riscv_tests(dut, 'rv32ui-p-sb')

@cocotb.test()
async def riscv_tests_sh(dut):
    await riscv_tests(dut, 'rv32ui-p-sh')

@cocotb.test()
async def riscv_tests_sw(dut):
    await riscv_tests(dut, 'rv32ui-p-sw')

@cocotb.test()
async def riscv_tests_mcsr(dut):
    await riscv_tests(dut, 'rv32mi-p-mcsr')

@cocotb.test()
async def riscv_tests_csr(dut):
    await riscv_tests(dut, 'rv32mi-p-csr')

@cocotb.test()
async def riscv_tests_illegal(dut):
    await riscv_tests(dut, 'rv32mi-p-illegal')

@cocotb.test()
async def riscv_tests_ma_addr(dut):
    await riscv_tests(dut, 'rv32mi-p-ma_addr')

@cocotb.test()
async def riscv_tests_mul(dut):
    await riscv_tests(dut, 'rv32um-p-mul')

@cocotb.test()
async def riscv_tests_mulh(dut):
    await riscv_tests(dut, 'rv32um-p-mulh')

@cocotb.test()
async def riscv_tests_mulhsu(dut):
    await riscv_tests(dut, 'rv32um-p-mulhsu')

@cocotb.test()
async def riscv_tests_mulhu(dut):
    await riscv_tests(dut, 'rv32um-p-mulhu')

@cocotb.test()
async def riscv_tests_div(dut):
    await riscv_tests(dut, 'rv32um-p-div')

@cocotb.test()
async def riscv_tests_divu(dut):
    await riscv_tests(dut, 'rv32um-p-divu')

@cocotb.test()
async def riscv_tests_rem(dut):
    await riscv_tests(dut, 'rv32um-p-rem')

@cocotb.test()
async def riscv_tests_remu(dut):
    await riscv_tests(dut, 'rv32um-p-remu')

# riscv-arch-test Test

@cocotb.test()
async def riscv_arch_test_add(dut):
    await riscv_arch_test(dut, 'I', 'add-01')

@cocotb.test()
async def riscv_arch_test_addi(dut):
    await riscv_arch_test(dut, 'I', 'addi-01')

@cocotb.test()
async def riscv_arch_test_sub(dut):
    await riscv_arch_test(dut, 'I', 'sub-01')

@cocotb.test()
async def riscv_arch_test_and(dut):
    await riscv_arch_test(dut, 'I', 'and-01')

@cocotb.test()
async def riscv_arch_test_andi(dut):
    await riscv_arch_test(dut, 'I', 'andi-01')

@cocotb.test()
async def riscv_arch_test_or(dut):
    await riscv_arch_test(dut, 'I', 'or-01')

@cocotb.test()
async def riscv_arch_test_ori(dut):
    await riscv_arch_test(dut, 'I', 'ori-01')

@cocotb.test()
async def riscv_arch_test_xor(dut):
    await riscv_arch_test(dut, 'I', 'xor-01')

@cocotb.test()
async def riscv_arch_test_xori(dut):
    await riscv_arch_test(dut, 'I', 'xori-01')

@cocotb.test()
async def riscv_arch_test_auipc(dut):
    await riscv_arch_test(dut, 'I', 'auipc-01')

@cocotb.test()
async def riscv_arch_test_lui(dut):
    await riscv_arch_test(dut, 'I', 'lui-01')

@cocotb.test()
async def riscv_arch_test_beq(dut):
    await riscv_arch_test(dut, 'I', 'beq-01')

@cocotb.test()
async def riscv_arch_test_bge(dut):
    await riscv_arch_test(dut, 'I', 'bge-01')

@cocotb.test()
async def riscv_arch_test_bgeu(dut):
    await riscv_arch_test(dut, 'I', 'bgeu-01')

@cocotb.test()
async def riscv_arch_test_bne(dut):
    await riscv_arch_test(dut, 'I', 'bne-01')

@cocotb.test()
async def riscv_arch_test_blt(dut):
    await riscv_arch_test(dut, 'I', 'blt-01')

@cocotb.test()
async def riscv_arch_test_bltu(dut):
    await riscv_arch_test(dut, 'I', 'bltu-01')

@cocotb.test()
async def riscv_arch_test_jal(dut):
    await riscv_arch_test(dut, 'I', 'jal-01')

@cocotb.test()
async def riscv_arch_test_jalr(dut):
    await riscv_arch_test(dut, 'I', 'jalr-01')

@cocotb.test()
async def riscv_arch_test_lb_align(dut):
    await riscv_arch_test(dut, 'I', 'lb-align-01')

@cocotb.test()
async def riscv_arch_test_lbu_align(dut):
    await riscv_arch_test(dut, 'I', 'lbu-align-01')

@cocotb.test()
async def riscv_arch_test_lh_align(dut):
    await riscv_arch_test(dut, 'I', 'lh-align-01')

@cocotb.test()
async def riscv_arch_test_lhu_align(dut):
    await riscv_arch_test(dut, 'I', 'lhu-align-01')

@cocotb.test()
async def riscv_arch_test_lw_align(dut):
    await riscv_arch_test(dut, 'I', 'lw-align-01')

@cocotb.test()
async def riscv_arch_test_sb_align(dut):
    await riscv_arch_test(dut, 'I', 'sb-align-01')

@cocotb.test()
async def riscv_arch_test_sh_align(dut):
    await riscv_arch_test(dut, 'I', 'sh-align-01')

@cocotb.test()
async def riscv_arch_test_sw_align(dut):
    await riscv_arch_test(dut, 'I', 'sw-align-01')

@cocotb.test()
async def riscv_arch_test_sll(dut):
    await riscv_arch_test(dut, 'I', 'sll-01')

@cocotb.test()
async def riscv_arch_test_slli(dut):
    await riscv_arch_test(dut, 'I', 'slli-01')

@cocotb.test()
async def riscv_arch_test_slt(dut):
    await riscv_arch_test(dut, 'I', 'slt-01')

@cocotb.test()
async def riscv_arch_test_slti(dut):
    await riscv_arch_test(dut, 'I', 'slti-01')

@cocotb.test()
async def riscv_arch_test_sltiu(dut):
    await riscv_arch_test(dut, 'I', 'sltiu-01')

@cocotb.test()
async def riscv_arch_test_sltu(dut):
    await riscv_arch_test(dut, 'I', 'sltu-01')

@cocotb.test()
async def riscv_arch_test_sra(dut):
    await riscv_arch_test(dut, 'I', 'sra-01')

@cocotb.test()
async def riscv_arch_test_srai(dut):
    await riscv_arch_test(dut, 'I', 'srai-01')

@cocotb.test()
async def riscv_arch_test_srl(dut):
    await riscv_arch_test(dut, 'I', 'srl-01')

@cocotb.test()
async def riscv_arch_test_srli(dut):
    await riscv_arch_test(dut, 'I', 'srli-01')

@cocotb.test()
async def riscv_arch_test_mul(dut):
    await riscv_arch_test(dut, 'M', 'mul-01')

@cocotb.test()
async def riscv_arch_test_mulh(dut):
    await riscv_arch_test(dut, 'M', 'mulh-01')

@cocotb.test()
async def riscv_arch_test_mulhsu(dut):
    await riscv_arch_test(dut, 'M', 'mulhsu-01')

@cocotb.test()
async def riscv_arch_test_mulhu(dut):
    await riscv_arch_test(dut, 'M', 'mulhu-01')

@cocotb.test()
async def riscv_arch_test_div(dut):
    await riscv_arch_test(dut, 'M', 'div-01')

@cocotb.test()
async def riscv_arch_test_divu(dut):
    await riscv_arch_test(dut, 'M', 'divu-01')

@cocotb.test()
async def riscv_arch_test_rem(dut):
    await riscv_arch_test(dut, 'M', 'rem-01')

@cocotb.test()
async def riscv_arch_test_remu(dut):
    await riscv_arch_test(dut, 'M', 'remu-01')

# dedicated-tests Test

@cocotb.test()
async def dedicated_tests_software_interrupt(dut):
    await dedicated_tests(dut, 'software_interrupt')

@cocotb.test()
async def dedicated_tests_timer_interrupt(dut):
    await dedicated_tests(dut, 'timer_interrupt')
