// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/11/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// uart read and write program
// ------------------------------------------------------------------------------------------------

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "platform.h"

int main(int argc, char **argv)
{
    printf("Interrupt test:\n");
    // software interrupt
    clic_msip_set(CLIC_BASE);
    clic_mtimecmp_low_set(CLIC_BASE, 0x10000);
    return 0;
}