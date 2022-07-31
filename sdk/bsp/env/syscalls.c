// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/10/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// new lib functions
// ------------------------------------------------------------------------------------------------

#include <sys/stat.h>
#include <sys/times.h>
#include <unistd.h>
#include <stddef.h>
#include <stdint.h>

#include "platform.h"

/**
 * @brief Exit a program
 *
 * @param code
 */
void _exit(int code)
{
    // Just simply using a forever loop for now
    for (;;);
}

//
// Closing a file, close
//
// In the minimal implementation, this function always fails, since there is only standard output,
// which is not a valid file to close.
//

/**
 * @brief Closing a file
 * In the minimal implementation, this function always fails, since there is only standard output,
 * which is not a valid file to close.
 * @param fd
 * @return int
 */
int _close (int fd)
{
    return -1;
}


/**
 * @brief fstat returns the status of an open file.
 * The minimal version of this should identify all files as character special devices.
 * This forces one-byte-read at a time.
 * @param file
 * @param st
 * @return int
 */
int _fstat(int file, struct stat *st) {
    if ((STDOUT_FILENO == file) || (STDERR_FILENO == file)) {
        st->st_mode = S_IFCHR;
        return  0;
    }
    else {
        return  -1;
    }
}

/**
 * @brief Determine the Nature of a Stream
 * The minimal implementation only has the single output stream, which is to the console, so always returns 1.
 * @param file
 * @return int
 */
int _isatty(int file) {
    return 1;
}

/**
 * @brief Set Position in a File
 * A minimal implementation has no file system, so this function can return 0,
 * indicating that the only stream (standard output) is positioned at the start of file.
 * @param file
 * @param offset
 * @param whence
 * @return int
 */
int _lseek (int file, int offset, int whence) {
    return  0;
}

/**
 * @brief Read from a File
 * A minimal implementation has no file system.
 * Rather than failing, this function returns 0, indicating end-of-file.
 * In our design, we have a UART as read stream.
 * @param file
 * @param ptr
 * @param len
 * @return int
 */
int _read (int file, char *ptr, int len) {
    int i;

    // if the file is tty, we read from uart
    if (isatty(file)) {
        for (i = 0; i < len; i++) {
            ptr[i] = uart_read_byte_blocking(UART0_BASE);
            // return partial value if we get EOL
            if ('\n' == ptr[i]) {
                return i;
            }
        }
        return i;
    }
    return  0;    // EOF
}

/**
 * @brief Allocate more Heap
 *
 * @param nbytes
 * @return void*
 */
void * _sbrk (int nbytes) {

    extern int _end[];              // Symbol defined by linker map - start of free memory
    extern int _heap_end[];         // Value set by linker map - end of free memory
    static int *heap_ptr = _end;    // Statically held previous end of the heap, with its initialization.

    if ((heap_ptr + nbytes) < _end || (heap_ptr + nbytes > _heap_end)) {
        return NULL - 1;
    }

    heap_ptr += nbytes;
    return heap_ptr - nbytes;
}


/**
 * @brief
 *
 * @param buf
 * @return clock_t
 */
clock_t _times (struct tms *buf) {

    //// clock_t is 32 bits and 32 bit counter is not good enough.
    //// So here we will ignore the lower 10 bits
    //// and pad the mcycleh[9:0] and mcycle[31:10] together.
    //// the clock is in term of 1024 clock cycle
    //clock_t clock;
    //uint32_t clock_lo = (uint32_t) _read_csr(mcycle);
    //uint32_t clock_hi = (uint32_t) _read_csr(mcycleh);
    //clock = clock_hi << (32 - 10) | (clock_lo >> 10);
    //
    //buf->tms_utime = 0;
    //buf->tms_stime = clock;
    //return  clock;

    clock_t clock = 0;
    return clock;
}

/**
 * @brief
 *
 * @param file
 * @param buf
 * @param nbytes
 * @return int
 */
int _write (int file, char *buf, size_t nbytes) {

  if (isatty(file)) {
    uart_putnc_blocking(UART0_BASE, buf, nbytes);
    return nbytes;
  }

  return -1;
}