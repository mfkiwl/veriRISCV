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

#include "gpio_reg.h"
#include "platform.h"

#define gpio_write_en(base, mask)   (*REG32_PTR((base), GPIO_OUTPUT_EN_REG) = (mask))
#define gpio_read_en(base, mask)    (*REG32_PTR((base), GPIO_INPUT_EN_REG) = (mask))
#define gpio_write(base, data)      (*REG32_PTR((base), GPIO_PORT_REG) = (data))
#define gpio_read(base)             (*REG32_PTR((base), GPIO_VALUE_REG))

#endif /* __GPIO_H__ */
