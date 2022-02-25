#include "exception.h"
#include "timer.h"
#include "riscv_csr.h"

typedef struct {
    uint32_t zero;
    uint32_t ra;
    uint32_t sp;
    uint32_t gp;
    uint32_t tp;
    uint32_t t0;
    uint32_t t1;
    uint32_t t2;
    uint32_t s0;
    uint32_t s1;
    uint32_t a0;
    uint32_t a1;
    uint32_t a2;
    uint32_t a3;
    uint32_t a4;
    uint32_t a5;
    uint32_t a6;
    uint32_t a7;
    uint32_t s2;
    uint32_t s3;
    uint32_t s4;
    uint32_t s5;
    uint32_t s6;
    uint32_t s7;
    uint32_t s8;
    uint32_t s9;
    uint32_t s10;
    uint32_t s11;
    uint32_t t3;
    uint32_t t4;
    uint32_t t5;
    uint32_t t6;
} regs_t;

regs_t exc_regs;

void exception_init() {
    exc_regs.sp = 0x104000;

    write_csr(CSR_MTRF, &exc_regs);

    // timer interrupt every 1ms
    timer_init_irq(1000);

    // enable timer interrupts and external interrupts
    write_csr(mie, (1 << 7) | (1 << 11));
    // enable interrupts
    write_csr(mstatus, (1 << 3));
}

void _empty_exception(unsigned mcause) { (void) mcause; while (1) {} }
void _empty_timer_irq() {}

void (*_timer_irq_handler)() = _empty_timer_irq;
void (*_exception_handler)(unsigned) = _empty_exception;

void set_timer_irq_handler(void (*handler)()) {
    _timer_irq_handler = handler;
}

void set_exception_handler(void (*handler)(unsigned)) {
    _exception_handler = handler;
}

void exception_entry() {
    _exception_handler(read_csr(mcause));
}

void timer_irq_entry() {
    timer_clear_irq();
    _timer_irq_handler();
}
