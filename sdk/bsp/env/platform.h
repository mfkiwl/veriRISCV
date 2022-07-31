// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/10/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// Platform
// ------------------------------------------------------------------------------------------------

#ifndef __PLATFORM_H__
#define __PLATFORM_H__

#include "board.h"
#include "encoding.h"

#include "avalon_gpio.h"
#include "avalon_uart.h"

// SOC component address mapping
#define CLIC_BASE       (0x80000000)
#define PLIC_BASE       (0x80001000)
#define GPIO0_BASE      (0x80002000)
#define GPIO1_BASE      (0x80003000)
#define UART0_BASE      (0x80004000)

#endif