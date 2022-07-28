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
    uint32_t value = 0xFFFFFFFF;

    // enable output
    avalon_gpio_write_en(GPIO0_BASE, 0xFFFFFFFF);

    while(1) {
        avalon_gpio_write(GPIO0_BASE, value);
        value = ~value;
        for (int i = 0; i < 500000; i++);
    }
    return 0;
}