#include "exception.h"
#include "timer.h"
#include "riscv_csr.h"

void exception_init() {
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

void ctimer_irq_handler() {
    timer_clear_irq();
    _timer_irq_handler();
}
