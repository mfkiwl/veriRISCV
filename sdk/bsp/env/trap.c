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
#include <assert.h>

#include "platform.h"
#include "interrupt.h"

// -------------------------------------------------
// Defines
// -------------------------------------------------

#define MCAUSE_EXP_MASK         0x7FFFFFFF
#define MCAUSE_INT_MASK         0x80000000
#define MCAUSE_LD_ADDR_MISALIGN 0x4

#define M_SOFTWARE  3
#define M_TIMER     7
#define M_EXTERNAL  11

// ISR information
typedef struct _isr_info_s {
    uint8_t irq;        // interrupt number
    isr_t isr;          // isr function
    void* isr_context;  // isr function parameter
} isr_info_s;

// -------------------------------------------------
// Exceptions
// -------------------------------------------------

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

// -------------------------------------------------
// Interrupt
// -------------------------------------------------

static isr_info_s mtimer_isr_info;
static isr_info_s msoftware_isr_info;
static isr_info_s external_isr_info[INT_COUNT];

/**
 * @brief register an interrupt service routine interrupt is enabled by default
 *
 * @param irq interrupt ID
 * @param isr pointer to interrupt service routine
 * @param isr_context pointer to any passed context, not supported yet TBD
 * @return int
 */
void _isr_register (isr_info_s* isr_info, uint8_t irq, isr_t isr, void* isr_context) {
    isr_info->irq = irq;
    isr_info->isr = isr;
    isr_info->isr_context = isr_context;
}

void mtimer_isr_register(isr_t isr, void* isr_context) {
    _isr_register(&mtimer_isr_info, 0, isr, isr_context);
}

void msoftware_isr_register(isr_t isr, void* isr_context) {
    _isr_register(&msoftware_isr_info, 0, isr, isr_context);
}

void external_isr_register(uint8_t irq, isr_t isr, void* isr_context) {
    _isr_register(&external_isr_info[irq], 0, isr, isr_context);
}

void external_isr_enable(uint8_t irq) {
    plic_enable_mint(PLIC_BASE, irq);
}

void external_isr_disable(uint8_t irq) {
    plic_disable_mint(PLIC_BASE, irq);
}

void __attribute__((weak)) mtimer_isr(void* isr_context) {
    static int count = 0;
    int* max_count = (int *) isr_context;
    // clear mtime
    clic_mtime_low_clear(CLIC_BASE, 0);
    clic_mtime_high_clear(CLIC_BASE, 0);
    printf("Timer interrupt triggered\n");
    count++;
    if (count >= *max_count) {
        clic_mtimecmp_low_clear(CLIC_BASE, 0);
        clic_mtimecmp_high_clear(CLIC_BASE, 0);
    }
}

void __attribute__((weak)) msoftware_isr(void* isr_context) {
    // clear msip
    clic_msip_clear(CLIC_BASE);
    printf("Software interrupt triggered\n");
}

void interrupt_handler(uint32_t int_type) {

    uint32_t irq;

    switch(int_type) {
        case M_SOFTWARE: {
            msoftware_isr_info.isr(msoftware_isr_info.isr_context);
            break;
        }
        case M_TIMER: {
            mtimer_isr_info.isr(mtimer_isr_info.isr_context);
            break;
        }
        case M_EXTERNAL: {
            irq = plic_get_mint(PLIC_BASE);
            for (int i = 0; i < 31; i++) {
                if ((irq >> i) & 0x1) {
                    external_isr_info[i].isr(external_isr_info[i].isr_context);
                }
            }
        }
    }
}

// -------------------------------------------------
// trap_handler
// -------------------------------------------------


uint32_t trap_handler(uint32_t mcause, uint32_t mepc) {

    uint32_t int_type = mcause & MCAUSE_EXP_MASK;

    if ((mcause & MCAUSE_INT_MASK) != 0) {
        interrupt_handler(int_type);
    } else {
        exception_handler(mepc, mcause);
    }
    return mepc;
}
