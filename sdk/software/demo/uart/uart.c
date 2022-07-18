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
#include "peripheral.h"

int main(int argc, char **argv)
{
    char * msg1 = "Hello, world!\n";
    char * msg2 = "Hello, veriRISCV!\n";
    avalon_gpio_set_0(GPIO0_BASE);
    // send uart message
    printf("%s", msg1);
    avalon_uart_putnc_blocking(UART0_BASE, msg2, strlen(msg2));
    return 0;
}