/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 08/01/2022
 * ---------------------------------------------------------------
 * PLIC
 * ---------------------------------------------------------------
 * PLIC driver
 * ---------------------------------------------------------------
 */

#include "plic.h"
#include "platform.h"

static uint32_t mint_enable = 0;

/**
 * @brief Enable an interrupt in PLIC
 *
 * @param base
 * @param id
 */
void plic_enable_mint(uint32_t base, uint8_t id) {
    mint_enable |= (1 << id);
    PLIC_MINT_ENABLE_WRITE(base, mint_enable);
}

/**
 * @brief Disable an interrupt in PLIC
 *
 * @param base
 * @param id
 */
void plic_disable_mint(uint32_t base, uint8_t id) {
    mint_enable &= ~(1 << id);
    PLIC_MINT_ENABLE_WRITE(base, mint_enable);
}

/**
 * @brief Get the interrupt id in PLIC
 *
 * @param base
 * @param id
 */
uint32_t plic_get_mint(uint32_t base) {
    uint32_t mint;
    mint = PLIC_MINT_READ(base);
    return mint;
}
