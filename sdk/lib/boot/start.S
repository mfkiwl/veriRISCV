# ------------------------------------------------------------------------------------------------
# Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
# Author: Heqing Huang
#
# Date Created: 07/10/2022
# ------------------------------------------------------------------------------------------------
# veriRISCV
# ------------------------------------------------------------------------------------------------
# Start-up code
# ------------------------------------------------------------------------------------------------


.section .init
.global _start
.type _start @function

_start:
    // disable all the interrupts
    csrrci x0, mstatus, 0x8

    // .option push saves the current options so that they can be later restored
    // (there are other options such as .option rvc for compressed code)
    .option push
    // .option norelax tells the linker to not relax AUIPC+ADDI to a gp relative reference (constant pool).
    // Obviously the load of gp needs to be fully qualified and can’t be relaxed.
    .option norelax

    // assign address pointed by __global_pointer$ to gp register
    // __global_pointer is defined in linker script file
    la gp, __global_pointer$

    .option pop
    // assign address pointed by _sp to sp register
    // _sp is defined in the linker script file
    la sp, _sp

    // Load data section
    // TBD

    // initialize bss section
    la a0, _sbss
    la a1, _ebss
    bgeu a0, a1, 2f
1:
    sw zero, 0(a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
2:

    // call global constructors
    // Note:
    // __libc_fini_array, atexit and __libc_init_array function are special lib function in
    // Newlib C runtime library.
    la a0, __libc_fini_array
    //call atexit
    call __libc_init_array

    // call init function
    call _init

    // call main function
    // argc == argv = 0
    li a0, 0
    li a1, 0
    call main
    tail exit

1:
    j 1b