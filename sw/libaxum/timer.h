#pragma once

#include "sys.h"
#include "mem.h"

#define TIMER_ADDR 0x30010

static inline unsigned timer_get_cycles() {
    return get32((const volatile void*) TIMER_ADDR);
}

static inline void delay_cyc(unsigned cyc) {
    unsigned rb = timer_get_cycles();
    while (1) {
        unsigned ra = timer_get_cycles();
        if ((ra - rb) >= cyc) {
            break;
        }
    }
}

static inline void delay_us(unsigned us) {
    delay_cyc(us * CLK_FREQ_MHZ);
}

static inline void delay_ms(unsigned ms) {
    delay_us(1000 * ms);
}

