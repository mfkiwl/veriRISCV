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


#include "sysutils.h"

/**
 * @brief  Light the LED to indicate the program is downloaded correctly
 *
 * @param base
 */
void light_led(uint32_t base) {
    *((uint32_t *) (base + 0x8)) = 0x1;
    *((uint32_t *) (base + 0xC)) = 1;
}




