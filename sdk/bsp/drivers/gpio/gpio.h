/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/17/2022
 * ---------------------------------------------------------------
 * GPIO
 * ---------------------------------------------------------------
 * C Header file for avalon gpio driver
 * ---------------------------------------------------------------
 */

#ifndef __GPIO_H__
#define __GPIO_H__

#include <stdint.h>
#include "gpio_reg.h"

void gpio_read_en(uint32_t base, uint32_t mask);

void gpio_write_en(uint32_t base, uint32_t mask);

uint32_t gpio_read(uint32_t base);

void gpio_write(uint32_t base, uint32_t data);

void gpio_set_0(uint32_t base);


#endif /* __GPIO_H__ */
