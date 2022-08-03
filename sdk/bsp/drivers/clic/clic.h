/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/17/2022
 * ---------------------------------------------------------------
 * CLIC
 * ---------------------------------------------------------------
 * C Header file for avalon clic driver
 * ---------------------------------------------------------------
 */

#ifndef __CLIC_H__
#define __CLIC_H__

#include <stdint.h>
#include "clic_reg.h"

#define clic_msip_set(base)                     (*REG32_PTR((base), CLIC_MSIP_REG) = 1)
#define clic_msip_clear(base)                   (*REG32_PTR((base), CLIC_MSIP_REG) = 0)
#define clic_msip_read(base)                    (*REG32_PTR((base), CLIC_MSIP_REG))

#define clic_mtimecmp_low_set(base, value)      (*REG32_PTR((base), CLIC_MTIMECMP_LOW_REG) = value)
#define clic_mtimecmp_low_clear(base, value)    (*REG32_PTR((base), CLIC_MTIMECMP_LOW_REG) = 0)
#define clic_mtimecmp_low_read(base)            (*REG32_PTR((base), CLIC_MTIMECMP_LOW_REG))

#define clic_mtimecmp_high_set(base, value)     (*REG32_PTR((base), CLIC_MTIMECMP_HIGH_REG) = value)
#define clic_mtimecmp_high_clear(base, value)   (*REG32_PTR((base), CLIC_MTIMECMP_HIGH_REG) = 0)
#define clic_mtimecmp_high_read(base)           (*REG32_PTR((base), CLIC_MTIMECMP_HIGH_REG))

#define clic_mtime_low_set(base, value)         (*REG32_PTR((base), CLIC_MTIME_LOW_REG) = value)
#define clic_mtime_low_clear(base, value)       (*REG32_PTR((base), CLIC_MTIME_LOW_REG) = 0)
#define clic_mtime_low_read(base)               (*REG32_PTR((base), CLIC_MTIME_LOW_REG))

#define clic_mtime_high_set(base, value)        (*REG32_PTR((base), CLIC_MTIME_HIGH_REG) = value)
#define clic_mtime_high_clear(base, value)      (*REG32_PTR((base), CLIC_MTIME_HIGH_REG) = 0)
#define clic_mtime_high_read(base)              (*REG32_PTR((base), CLIC_MTIME_HIGH_REG))


#endif /* __CLIC_H__ */
