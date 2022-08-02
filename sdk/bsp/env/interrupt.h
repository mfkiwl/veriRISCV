// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/31/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Header file for interrupt
// ------------------------------------------------------------------------------------------------

#include <stdint.h>


// support 4 interrupt for now
#define INT_COUNT               4

// define a type for isr function pointer
typedef void (*isr_t)(void *);

// Function headers
void interrupt_handler(uint32_t int_type);
void mtimer_isr_register(isr_t isr, void* isr_context);
void msoftware_isr_register(isr_t isr, void* isr_context);
void external_isr_register(uint8_t irq, isr_t isr, void* isr_context);
void external_isr_enable(uint8_t irq);
void external_isr_disable(uint8_t irq);

void __attribute__((weak)) mtimer_isr(void* isr_context);
void __attribute__((weak)) msoftware_isr(void* isr_context);
