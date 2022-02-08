#include "exception.h"
#include "timer.h"

void _empty_exception(unsigned mcause) { (void) mcause; while (1) {} }
void _empty_timer_irq() { }

void (*_timer_irq_handler)() = _empty_timer_irq;
void (*_exception_handler)(unsigned) = _empty_exception;

void set_timer_irq_handler(void (*handler)()) {
    _timer_irq_handler = handler;
}

void set_exception_handler(void (*handler)(unsigned)) {
    _exception_handler = handler;
}

void _timer_irq_handler_entry() {
    clear_timer_irq();

    _timer_irq_handler();
}

void _exception_handler_entry() {
    unsigned mcause;

    asm volatile (
        "csrr %[dest], mcause"
        :[dest]    "=r" (mcause)
        : /* no inputs */
        : "memory"
        );

    _exception_handler(mcause);
}
