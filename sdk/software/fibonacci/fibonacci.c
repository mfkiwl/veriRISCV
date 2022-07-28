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


int fibonacci(int n);

int main(int argc, char **argv)
{
    int i, b;
    for (i = 0; i < 20; i++) {
        b = fibonacci(i);
        printf("fibonacci number %4d is %8d\n", i, b);
    }
    return 0;
}

int fibonacci(int n) {
    if (n == 0) return 0;
    else if (n == 1) return 1;
    else return fibonacci(n - 1) + fibonacci(n - 2);
}