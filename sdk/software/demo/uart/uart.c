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
#include "platform.h"
#include "peripheral.h"

int main(int argc, char **argv)
{

    char * msg = "Hello, world!";
    printf("%s\n", msg);
    return 0;
}