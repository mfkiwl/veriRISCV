/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/17/2022
 * ---------------------------------------------------------------
 * GPIO
 * ---------------------------------------------------------------
 * avalon gpio driver
 * ---------------------------------------------------------------
 */

#include "gpio.h"
#include "platform.h"

void gpio_read_en(uint32_t base, uint32_t mask) {
    *REG32_PTR(base, GPIO_INPUT_EN_REG) = mask;
}

void gpio_write_en(uint32_t base, uint32_t mask) {
    *REG32_PTR(base, GPIO_OUTPUT_EN_REG) = mask;
}

uint32_t gpio_read(uint32_t base) {
    return *REG32_PTR(base, GPIO_VALUE_REG);
}

void gpio_write(uint32_t base, uint32_t data) {
    *REG32_PTR(base, GPIO_PORT_REG) = data;
}
