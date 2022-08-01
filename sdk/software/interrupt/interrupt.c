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
#include "interrupt.h"

int main(int argc, char **argv)
{
    int count = 6;

    printf("Interrupt test:\n");

    // register the interrupt
    msoftware_isr_register(&msoftware_isr, NULL);
    mtimer_isr_register(&mtimer_isr, &count);

    // set interrupt
    clic_msip_set(CLIC_BASE);
    clic_mtimecmp_low_set(CLIC_BASE, 0x10000);

    while (1);
    return 0;
}
