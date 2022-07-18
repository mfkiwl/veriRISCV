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

#ifndef __AVALON_GPIO_H__
#define __AVALON_GPIO_H__

#include <stdlib.h>
#include "avalon_gpio_reg.h"

void avalon_gpio_read_en(uint32_t base, uint32_t mask);
void avalon_gpio_write_en(uint32_t base, uint32_t mask);
uint32_t avalon_gpio_read(uint32_t base);
void avalon_gpio_write(uint32_t base, uint32_t data);
void avalon_gpio_set_0(uint32_t base);


#endif /* __AVALON_GPIO_H__ */
