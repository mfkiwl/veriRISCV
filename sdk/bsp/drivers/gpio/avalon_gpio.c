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

#include "avalon_gpio.h"

#define AVALON_GPIO_REG2POINTER(base, reg)   ((volatile uint32_t *) (base + reg))

void avalon_gpio_read_en(uint32_t base, uint32_t mask) {
    *AVALON_GPIO_REG2POINTER(base, AVALON_GPIO_INPUT_EN_REG) = mask;
}

void avalon_gpio_write_en(uint32_t base, uint32_t mask) {
    *AVALON_GPIO_REG2POINTER(base, AVALON_GPIO_OUTPUT_EN_REG) = mask;
}

uint32_t avalon_gpio_read(uint32_t base) {
    return *AVALON_GPIO_REG2POINTER(base, AVALON_GPIO_VALUE_REG);
}

void avalon_gpio_write(uint32_t base, uint32_t data) {
    *AVALON_GPIO_REG2POINTER(base, AVALON_GPIO_PORT_REG) = data;
}

void avalon_gpio_set_0(uint32_t base) {
    avalon_gpio_write_en(base, 0x1);
    avalon_gpio_write(base, 0x1);

}