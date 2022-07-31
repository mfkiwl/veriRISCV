// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/31/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Trap related program
// ------------------------------------------------------------------------------------------------

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "platform.h"

// -------------------------------------------------
// Defines
// -------------------------------------------------

#define MCAUSE_EXP_MASK         0x7FFFFFFF
#define MCAUSE_INT_MASK         0x80000000
#define MCAUSE_LD_ADDR_MISALIGN 0x4

#define M_SOFTWARE              3
#define M_TIMER                 7
#define M_EXTERNAL              11


// -------------------------------------------------
// Functions
// -------------------------------------------------


// Exceptions

void print_exception_info(uint32_t mcause, uint32_t mepc) {
    printf("Exception: mcause = %x\n", mcause);
    printf("PC = %x\n", mepc);
    printf("mtval = %x\n", read_csr(mtval));
}

void __attribute__((weak)) exit_trap(uint32_t mcause, uint32_t mepc) {
    print_exception_info(mepc, mcause);
    // For now, exit the program if we encountered exception
    exit(1);
}

void exception_handler(uint32_t mcause, uint32_t mepc) {
    // TBD
    exit_trap(mepc, mcause);
}

// Interrupt s

void __attribute__((weak)) m_timer_interrupt_handler() {
    // clear mtime
    clic_mtime_low_clear(CLIC_BASE, 0);
    clic_mtime_high_clear(CLIC_BASE, 0);
    printf("Timer interrupt triggered\n");
}

void __attribute__((weak)) m_software_interrupt_handler() {
    // clear msip
    clic_msip_clear(CLIC_BASE);
    printf("Software interrupt triggered\n");
}

void __attribute__((weak)) m_external_interrupt_handler() {}

void interrupt_handler(uint32_t mcause) {
    switch(mcause & MCAUSE_EXP_MASK) {
        case M_SOFTWARE: {
            m_software_interrupt_handler();
            break;
        }
        case M_TIMER: {
            m_timer_interrupt_handler();
            break;
        }
        case M_EXTERNAL: {
            m_external_interrupt_handler();
            break;
        }
    }
}

uint32_t trap_handler(uint32_t mcause, uint32_t mepc) {
    if ((mcause & MCAUSE_INT_MASK) != 0) {
        interrupt_handler(mcause);
    } else {
        exception_handler(mepc, mcause);
    }
    return mepc;
}
