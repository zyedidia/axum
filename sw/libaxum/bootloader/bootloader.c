#include "uart.h"
#include "timer.h"
#include "crc32.h"

enum {
    BOOT_START      = 0xFFFF0000,

    GET_PROG_INFO   = 0x11112222,
    PUT_PROG_INFO   = 0x33334444,

    GET_CODE        = 0x55556666,
    PUT_CODE        = 0x77778888,

    BOOT_SUCCESS    = 0x9999AAAA,
    BOOT_ERROR      = 0xBBBBCCCC,

    BAD_CODE_ADDR   = 0xdeadbeef,
    BAD_CODE_CKSUM  = 0xfeedface,
};

int get_byte() {
    while (1) {
        int b = uart_rx();
        if (b != -1) {
            return b;
        }
    }
}


uint32_t get_uint() {
    union {
        char b[4];
        uint32_t i;
    } x;

    x.b[0] = get_byte();
    x.b[1] = get_byte();
    x.b[2] = get_byte();
    x.b[3] = get_byte();
    return x.i;
}

void put_uint(uint32_t u) {
    uart_tx((u >> 0) & 0xff);
    uart_tx((u >> 8) & 0xff);
    uart_tx((u >> 16) & 0xff);
    uart_tx((u >> 24) & 0xff);
}

void boot() {
    while (1) {
        put_uint(GET_PROG_INFO);
        delay_ms(500);
        if (!uart_rx_empty() && get_uint() == PUT_PROG_INFO) {
            break;
        }
    }

    char* base = (char*) get_uint();
    uint32_t nbytes = get_uint();
    uint32_t crc_recv = get_uint();

    put_uint(GET_CODE);
    put_uint(crc_recv);

    get_uint(); // PUT_CODE
    for (uint32_t i = 0; i < nbytes; i++) {
        base[i] = get_byte();
    }
    uint32_t crc_calc = crc32(base, nbytes);
    if (crc_calc != crc_recv) {
        put_uint(BAD_CODE_CKSUM);
        return;
    }
    put_uint(BOOT_SUCCESS);

    // jump to reset vector
    asm volatile ("j 0x100080");
}
