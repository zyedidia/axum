#include "libaxum.h"

void timer_interrupt() {
    gpio_write(GPIO_LED_R, 1);
}

int main() {
    set_timer_irq_handler(timer_interrupt);
    gpio_write(GPIO_LED_B, 1);
    return 0;
}
