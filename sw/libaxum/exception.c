#include "exception.h"

void _empty_exception() {}
void _empty_timer_irq() {}

void (*_timer_irq_handler)() = _empty_timer_irq;
void (*_exception_handler)() = _empty_exception;

void set_timer_irq_handler(void (*handler)()) {
    _timer_irq_handler = handler;
}

void set_exception_handler(void (*handler)()) {
    _exception_handler = handler;
}
