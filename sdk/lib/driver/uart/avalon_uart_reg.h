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

#ifndef __AVALON_UART_REGS_H__
#define __AVALON_UART_REGS_H__

#include "stdint.h"

// Register

#define AVALON_UART_TXDATA_REG  0x0
#define AVALON_UART_RXDATA_REG  0x4
#define AVALON_UART_TXCTRL_REG  0x8
#define AVALON_UART_RXCTRL_REG  0xC
#define AVALON_UART_IE_REG      0x10
#define AVALON_UART_IP_REG      0x14
#define AVALON_UART_DIV_REG     0x18

// Register field

typedef union _avalon_uart_txdata_s {
    uint32_t reg;
    struct  {
        uint32_t data:  8;
        uint32_t:       23;
        uint32_t full:  1;
    };
} avalon_uart_txdata_s;

typedef union _avalon_uart_rxdata_s {
    uint32_t reg;
    struct {
        uint32_t data:  8;
        uint32_t:       23;
        uint32_t empty: 1;
    };
} avalon_uart_rxdata_s;

typedef union _avalon_uart_txctrl_s {
    uint32_t reg;
    struct {
        uint32_t txen:  1;
        uint32_t nstop: 1;
        uint32_t:       14;
        uint32_t txcnt: 3;
        uint32_t:       13;
    };
} avalon_uart_txctrl_s;

typedef union _avalon_uart_rxctrl_s {
    uint32_t reg;
    struct {
        uint32_t rxen:  1;
        uint32_t:       15;
        uint32_t rxcnt: 3;
        uint32_t:       13;
    };
} avalon_uart_rxctrl_s;

typedef union _avalon_uart_ie_s {
    uint32_t reg;
    struct {
        uint32_t txwm:  1;
        uint32_t rxwm:  1;
        uint32_t:       30;
    };
} avalon_uart_ie_s;

typedef union _avalon_uart_ip_s {
    uint32_t reg;
    struct {
        uint32_t txwm:  1;
        uint32_t rxwm:  1;
        uint32_t:       30;
    };
} avalon_uart_ip_s;

typedef union _avalon_uart_div_s {
    uint32_t reg;
    struct {
        uint32_t div:   16;
        uint32_t:       16;
    };
} avalon_uart_div_s;

#endif /* __AVALON_UART_REGS_H__ */

/*
// AVALON_UART_TXDATA_REG
#define AVALON_UART_TXDATA_DATA_MSK     (0xFF)
#define AVALON_UART_TXDATA_DATA_OFST    (0)
#define AVALON_UART_TXDATA_FULL_MSK     (0x1)
#define AVALON_UART_TXDATA_FULL_OFST    (31)

// AVALON_UART_RXDATA_REG
#define AVALON_UART_RXDATA_DATA_MSK     (0xFF)
#define AVALON_UART_RXDATA_DATA_OFST    (0)
#define AVALON_UART_RXDATA_EMPTY_MSK    (0x1)
#define AVALON_UART_RXDATA_EMPTY_OFST   (31)

// AVALON_UART_TXCTRL_REG
#define AVALON_UART_TXCTRL_TXEN_MSK     (0x1)
#define AVALON_UART_TXCTRL_TXEN_OFST    (0)
#define AVALON_UART_TXCTRL_NSTOP_MSK    (0x3)
#define AVALON_UART_TXCTRL_NSTOP_OFST   (1)
#define AVALON_UART_TXCTRL_TXCNT_MSK    (0x7)
#define AVALON_UART_TXCTRL_TXCNT_OFST   (15)

// AVALON_UART_RXCTRL_REG
#define AVALON_UART_RXCTRL_RXEN_MSK     (0x1)
#define AVALON_UART_RXCTRL_RXEN_OFST    (0)
#define AVALON_UART_RXCTRL_RXCNT_MSK    (0x7)
#define AVALON_UART_RXCTRL_RXCNT_OFST   (15)

// AVALON_UART_IE_REG
#define AVALON_UART_IE_TXWM_MSK         (0x1)
#define AVALON_UART_IE_TXWM_OFST        (0)
#define AVALON_UART_IE_RXWM_MSK         (0x1)
#define AVALON_UART_IE_RXWM_OFST        (1)

// AVALON_UART_IP_REG
#define AVALON_UART_IP_TXWM_MSK         (0x1)
#define AVALON_UART_IP_TXWM_OFST        (0)
#define AVALON_UART_IP_RXWM_MSK         (0x1)
#define AVALON_UART_IP_RXWM_OFST        (1)

// AVALON_UART_DIV_REG
#define AVALON_UART_DIV_DIV_MSK         (0xFFFF)
#define AVALON_UART_DIV_DIV_OFST        (0)
*/