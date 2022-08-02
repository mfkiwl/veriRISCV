/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/08/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * C Header file for avalon uart driver
 * ---------------------------------------------------------------
 */

#ifndef __UART_H__
#define __UART_H__

#include <stdlib.h>
#include "uart_reg.h"

// ---------------------------------------------------------------
// Defines
// ---------------------------------------------------------------

#define UART_TXDATA_WRITE(base, data)   (*REG32_PTR(base, UART_TXDATA_REG) = data)
#define UART_TXDATA_READ(base, data)    (*REG32_PTR(base, UART_TXDATA_REG))

#define UART_USE_INTERRUPT
#define UART_BUFFER_SIZE 64

#define UART_CAL_DIV(CLK_FREQ_MHZ, BAUD) (CLK_FREQ_MHZ * 1000000 / BAUD)

typedef struct _uart_init_cfg_s {
    #ifdef UART_USE_INTERRUPT
    uint8_t     tx_irq;
    uint8_t     rx_irq;
    #endif
    uint8_t     txen;
    uint8_t     nstop;
    uint8_t     txcnt;
    uint8_t     rxen;
    uint8_t     rxcnt;
    uint8_t     ie_txwm;
    uint8_t     ie_rxwm;
    uint16_t    div;
} uart_init_cfg_s;

// ---------------------------------------------------------------
// Function prototypes
// ---------------------------------------------------------------

void uart_init(uint32_t base, uart_init_cfg_s* init_cfg);

int uart_open(uint32_t base);

int uart_close(uint32_t base);

void uart_putc(uint32_t base, const char c);

void uart_putnc(uint32_t base, char *buf, size_t nbytes);

#endif /* __UART_H__ */
