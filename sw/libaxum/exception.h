#pragma once

void exception_init();
void set_timer_irq_handler(void (*handler)());
void set_exception_handler(void (*handler)());
