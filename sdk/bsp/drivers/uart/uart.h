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

#define UART_CAL_DIV(CLK_FREQ_MHZ, BAUD) (CLK_FREQ_MHZ * 1000000 / BAUD)

typedef struct _uart_init_cfg_s {
    uint8_t     txen;
    uint8_t     nstop;
    uint8_t     txcnt;
    uint8_t     rxen;
    uint8_t     rxcnt;
    uint8_t     ie_txwm;
    uint8_t     ie_rxwm;
    uint16_t    div;
} uart_init_cfg_s;

void uart_init(uint32_t base, uart_init_cfg_s* init_cfg);

int uart_open(uint32_t base);

int uart_close(uint32_t base);

void uart_write_byte_blocking(uint32_t base, const char c);

int  uart_read_byte_blocking(uint32_t base);

void uart_putnc_blocking(uint32_t base, char *buf, size_t nbytes);

#endif /* __UART_H__ */
