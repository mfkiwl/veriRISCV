// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/18/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Calculate fibonacci number
// ------------------------------------------------------------------------------------------------

#include <stdint.h>
#include <stdio.h>
#include <string.h>
//#include "platform.h"
//#include "peripheral.h"

int fib(int n);

int main(int argc, char **argv)
{
    int i, b;
    for (i = 0; i < 10; i++) {
        b = fib(i);
        printf("fibonacci number %d is %d\n", i, b);
    }
    return 0;
}

int fib(int n) {
    if (n == 0) return 0;
    else if (n == 1) return 1;
    else return fib(n - 1) + fib(n - 2);
}