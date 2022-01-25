#include "libaxum.h"

void timer_interrupt() {
    gpio_write(GPIO_LED_R, 1);
}

int main() {
    gpio_set_output(GPIO_LED_R);
    gpio_set_output(GPIO_LED_B);
    set_timer_irq_handler(timer_interrupt);
    gpio_write(GPIO_LED_B, 1);
    return 0;
}
