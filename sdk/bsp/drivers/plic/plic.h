/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 08/01/2022
 * ---------------------------------------------------------------
 * PLIC
 * ---------------------------------------------------------------
 * C Header file for avalon plic driver
 * ---------------------------------------------------------------
 */

#ifndef __PLIC_H__
#define __PLIC_H__

#include <stdint.h>
#include "plic_reg.h"

#define PLIC_MINT_ENABLE_WRITE(base, data)  (*REG32_PTR((base), PLIC_MINT_ENABLE_REG) = (data))
#define PLIC_MINT_ENABLE_READ(base, data)   (*REG32_PTR((base), PLIC_MINT_ENABLE_REG))
#define PLIC_MINT_READ(base)                (*REG32_PTR((base), PLIC_MINT_REG))

#define plic_get_mint(base)                 (PLIC_MINT_READ((base)))

void plic_enable_mint(uint32_t base, uint8_t id);
void plic_disable_mint(uint32_t base, uint8_t id);

#endif /* __PLIC_H__ */
