#include "exception.h"

void _empty_exception() {}
void _empty_timer_irq(int mcause) { (void) mcause; }

void (*_timer_irq_handler)() = _empty_timer_irq;
void (*_exception_handler)(int) = _empty_exception;

void set_timer_irq_handler(void (*handler)()) {
    _timer_irq_handler = handler;
}

void set_exception_handler(void (*handler)(int)) {
    _exception_handler = handler;
}
