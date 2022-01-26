#include "rf.h"

static volatile regs_t* const rf = (volatile regs_t*) 0x10000;

volatile regs_t* rf_ctx(rf_ctx_t ctx) {
    return &rf[ctx];
}

uint32_t get_reg(volatile regs_t* regs, unsigned reg) {
    if (reg > 31) {
        return 0;
    }
    volatile uint32_t* regs_arr = (volatile uint32_t*) regs;
    return regs_arr[reg];
}
