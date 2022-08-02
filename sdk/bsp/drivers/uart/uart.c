/* ---------------------------------------------------------------
 * Copyright (c) 2022. Heqing Huang (feipenghhq@gmail.com)
 *
 * Author: Heqing Huang
 * Date Created: 07/08/2022
 * ---------------------------------------------------------------
 * Uart
 * ---------------------------------------------------------------
 * avalon uart driver
 * ---------------------------------------------------------------
 */

#include "uart.h"
#include "platform.h"
#include "interrupt.h"

// -------------------------------------
// Static variables
// -------------------------------------

static uart_txdata_s _txdata;
static uart_rxdata_s _rxdata;
static uart_txctrl_s _txctrl;
static uart_rxctrl_s _rxctrl;
static uart_ie_s     _ie;
static uart_ip_s     _ip;
static uart_div_s    _div;
static uint8_t       _tx_irq;
static uint8_t       _rx_irq;

#ifdef UART_USE_INTERRUPT

static uint32_t _uart_base;
static uint8_t  _uart_write_buffer[UART_BUFFER_SIZE];
static uint16_t _uart_write_buffer_rdptr = 0;
static uint16_t _uart_write_buffer_wrptr = 0;

void _uart_txwm_isr(void* isr_context);

#endif



// -------------------------------------
// Uart init
// -------------------------------------

/**
 * @brief Initialize the uart peripheral
 *
 * @param base
 * @param init_cfg
 */
void uart_init(uint32_t base, uart_init_cfg_s* init_cfg) {


    _txctrl.txen = init_cfg->txen;
    _txctrl.nstop = init_cfg->nstop;
    _txctrl.txcnt = init_cfg->txcnt;
    _rxctrl.rxen = init_cfg->rxen;
    _rxctrl.rxcnt = init_cfg->rxcnt;
    _ie.txwm = init_cfg->ie_txwm;
    _ie.rxwm = init_cfg->ie_rxwm;
    _div.div = init_cfg->div;


    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
    *REG32_PTR(base, UART_IE_REG)     = _ie.reg;
    *REG32_PTR(base, UART_DIV_REG)    = _div.reg;

    // if we use interrupt, register the isr
    #ifdef UART_USE_INTERRUPT
    _tx_irq = init_cfg->tx_irq;
    _rx_irq = init_cfg->rx_irq;
    // we need to use a static/global variable here. If we use &base as isr_context,
    // the base variable will be discarded after the function returns and isr will
    // get a garbage value as base
    _uart_base = base;
    external_isr_register(_tx_irq, &_uart_txwm_isr, &_uart_base);
    #endif
}

/**
 * @brief Open the uart peripheral
 *
 * @param base
 * @return int
 */
int uart_open(uint32_t base) {
    _txctrl.txen = 1;
    _rxctrl.rxen = 1;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

/**
 * @brief Close the uart peripheral
 *
 * @param base
 * @return int
 */
int uart_close(uint32_t base) {
    _txctrl.txen = 0;
    _rxctrl.rxen = 0;
    *REG32_PTR(base, UART_TXCTRL_REG) = _txctrl.reg;
    *REG32_PTR(base, UART_RXCTRL_REG) = _rxctrl.reg;
}

// -------------------------------------
// Uart write
// -------------------------------------


// Function specific using interrupt
#ifdef UART_USE_INTERRUPT

/**
 * @brief Check if the write buffer is full or not
 *
 * @return uint8_t
 */
static uint8_t _uart_write_buffer_full() {
    return (_uart_write_buffer_wrptr - _uart_write_buffer_rdptr) == UART_BUFFER_SIZE;
}

/**
 * @brief Check if the write buffer is empty or not
 *
 * @return uint8_t
 */
static uint8_t _uart_write_buffer_empty() {
    return _uart_write_buffer_wrptr == _uart_write_buffer_rdptr;
}

/**
 * @brief Interrupt service routine to handle uart tx watermark interrupt
 *
 * @param isr_context
 */
void _uart_txwm_isr(void* isr_context) {

    uint32_t* base = (uint32_t*) isr_context;

    while (1) {
        // if we have more data to be sent:
        if (!_uart_write_buffer_empty()) {
            _txdata.reg = *REG32_PTR(*base, UART_TXDATA_REG);
            // if the TX FIFO is full, then we need to wait for the next interrupt so we just return
            if (_txdata.full) {
                return;
            }
            // if the TX FIFO is not full, then push a data into the FIFO
            else {
                _txdata.data = _uart_write_buffer[_uart_write_buffer_rdptr++];
                UART_TXDATA_WRITE(*base, _txdata.reg);
                if (_uart_write_buffer_rdptr == UART_BUFFER_SIZE) _uart_write_buffer_rdptr = 0;
            }
        }
        // we have sent all the data
        else {
            // disable the interrupt since we don't have any more data to be sent
            external_isr_disable(_tx_irq);
        }
    }
}

#endif

/**
 * @brief Write a character through uart
 *
 * @param base
 * @param c
 */

void uart_putc(uint32_t base, const char c) {

    // Use interrupt mechanism
    #ifdef UART_USE_INTERRUPT

        // check if the buffer is full or not. If full then we need to stall
        while(_uart_write_buffer_full());
        // push the data into the buffer
        _uart_write_buffer[_uart_write_buffer_wrptr++] = c;
        // update write pointer
        if (_uart_write_buffer_wrptr == UART_BUFFER_SIZE) _uart_write_buffer_wrptr = 0;
        // enable interrupt to drain out the buffer
        external_isr_enable(_tx_irq);

    // Use blocking mechanism
    #else
        // wait till the txdata fifo has space
        do {
            _txdata.reg = *REG32_PTR(base, UART_TXDATA_REG);
        } while(_txdata.full);
        _txdata.data = c;
        UART_TXDATA_WRITE(base, _txdata.reg);
    #endif
}

/**
 * @brief Write N character through uart
 *
 * @param base
 * @param buf
 * @param nbytes
 */
void uart_putnc(uint32_t base, char *buf, size_t nbytes) {

    // Use interrupt mechanism
    #ifdef UART_USE_INTERRUPT

        while (nbytes > 0) {
            // check if the buffer is full or not. If full then we need to stall
            while(_uart_write_buffer_full());
            // push the data into the buffer
            _uart_write_buffer[_uart_write_buffer_wrptr++] = *buf;
            // update write pointer
            if (_uart_write_buffer_wrptr == UART_BUFFER_SIZE) _uart_write_buffer_wrptr = 0;

            buf++;
            nbytes--;
        }

        // enable interrupt to drain out the buffer
        external_isr_enable(_tx_irq);

    // Use blocking mechanism
    #else
        while (nbytes > 0) {
            // wait till the txdata fifo has space
            do {
                _txdata.reg = *REG32_PTR(base, UART_TXDATA_REG);
            } while(_txdata.full);
            // write the data to FIFO
            _txdata.data = *buf;
            UART_TXDATA_WRITE(base, _txdata.reg);

            buf++;
            nbytes--;
        }
    #endif
}
