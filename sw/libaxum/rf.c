#include "rf.h"

static regs_p const rf = (regs_p) 0x10000;

regs_p rf_ctx(rf_ctx_t ctx) {
    return &rf[ctx];
}

uint32_t get_reg(regs_p regs, unsigned reg) {
    if (reg > 31) {
        return 0;
    }
    volatile uint32_t* regs_arr = (volatile uint32_t*) regs;
    return regs_arr[reg];
}
