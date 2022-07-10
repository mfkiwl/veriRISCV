// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/10/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// blinker program
// ------------------------------------------------------------------------------------------------

#include <stdint.h>
#include "platform.h"

int main(int argc, char **argv)
{
    volatile uint32_t value = 0xFFFFFFFF;

    // enable output
    *((uint32_t *) (GPIO0_BASE + 0x8)) = 0xFFFFFFFF;

    while(1) {
        *((uint32_t *) (GPIO0_BASE + 0xC)) = value;
        value = ~value;
        for (int i = 0; i < 10000000; i++);
    }
    return 0;
}