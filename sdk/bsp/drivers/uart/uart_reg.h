/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/08/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * C Header file for avalon uart register
 * ---------------------------------------------------------------
 */

#ifndef __UART_REGS_H__
#define __UART_REGS_H__

#include "stdint.h"

// Register

#define UART_TXDATA_REG  0x0
#define UART_RXDATA_REG  0x4
#define UART_TXCTRL_REG  0x8
#define UART_RXCTRL_REG  0xC
#define UART_IE_REG      0x10
#define UART_IP_REG      0x14
#define UART_DIV_REG     0x18

// Register field

typedef union _uart_txdata_s {
    uint32_t reg;
    struct  {
        uint32_t data:  8;
        uint32_t:       23;
        uint32_t full:  1;
    };
} uart_txdata_s;

typedef union _uart_rxdata_s {
    uint32_t reg;
    struct {
        uint32_t data:  8;
        uint32_t:       23;
        uint32_t empty: 1;
    };
} uart_rxdata_s;

typedef union _uart_txctrl_s {
    uint32_t reg;
    struct {
        uint32_t txen:  1;
        uint32_t nstop: 1;
        uint32_t:       14;
        uint32_t txcnt: 3;
        uint32_t:       13;
    };
} uart_txctrl_s;

typedef union _uart_rxctrl_s {
    uint32_t reg;
    struct {
        uint32_t rxen:  1;
        uint32_t:       15;
        uint32_t rxcnt: 3;
        uint32_t:       13;
    };
} uart_rxctrl_s;

typedef union _uart_ie_s {
    uint32_t reg;
    struct {
        uint32_t txwm:  1;
        uint32_t rxwm:  1;
        uint32_t:       30;
    };
} uart_ie_s;

typedef union _uart_ip_s {
    uint32_t reg;
    struct {
        uint32_t txwm:  1;
        uint32_t rxwm:  1;
        uint32_t:       30;
    };
} uart_ip_s;

typedef union _uart_div_s {
    uint32_t reg;
    struct {
        uint32_t div:   16;
        uint32_t:       16;
    };
} uart_div_s;

#endif /* __UART_REGS_H__ */
