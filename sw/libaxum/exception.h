#pragma once

void trap_init();
void set_timer_irq_handler(void (*handler)());
void set_exception_handler(void (*handler)());
