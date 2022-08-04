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

    char c;
    char s[100];
    char* msg = "Computer Science is the study of computers and computational systems. Unlike electrical and computer engineers, computer scientists deal mostly with software and software systems; this includes their theory, design, development, and application.\n";

    printf("%s", msg);

    printf("Enter a character: \n");
    c = getchar();
    printf("getchar returned %c\n", c);

    printf("Please enter something and I will echo back: \n");
    scanf("%s", s);
    printf("I am getting: %s\n", s);
    return 0;
}
