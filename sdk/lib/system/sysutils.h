// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/14/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// System Utility functions
// ------------------------------------------------------------------------------------------------

#ifndef __SYSUTILS_H__
#define __SYSUTILS_H__

#include <stdint.h>
#include <stddef.h>

/** Read IO device, return the value */
#define IORD(base, offset)          (*((volatile uint32_t *) (base + offset)))

/** Write IO device */
#define IOWR(base, offset, value)   (*((volatile uint32_t *) (base + offset)) = value)
#define IOWH(base, offset, value)   (*((volatile uint16_t *) (base + offset)) = value)
#define IOWB(base, offset, value)   (*((volatile uint8_t  *) (base + offset)) = value)

/**
 * Set Specific bits using the mask
 * When the corresponding bit in mask is set, it will set that bit
 */
#define IOSET(base, offset, mask)   IOWR(base, offset, (IORD(base, offset) | mask))


/**
 * Clear Specific bits using the mask
 * When the corresponding bit in mask is set, it will clear that bit
 */
#define IOCLEAR(base, offset, mask) IOWR(base, offset, (IORD(base, offset) ^ mask));

/** Read CSR register */
#define _read_csr(reg) ({ uint32_t __tmp; \
asm volatile ("csrr %0, " #reg:"=r"(__tmp)); \
__tmp;})

/** Write CSR register */
#define _write_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrw " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrw " #reg ", %0" :: "r"(val)); })

#endif

/** Light the LED to indicate the program is downloaded correctly */
void light_led(uint32_t base);
