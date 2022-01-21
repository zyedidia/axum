#include "libaxum.h"

void irq_handler() {
    gpio_write(GPIO_LED_R, gpio_read(GPIO_BTN));
}

int main() {
    set_timer_irq_handler(irq_handler);

    const int pin = GPIO_LED_B;
    gpio_set_output(pin);

    gpio_set_output(GPIO_LED_R);
    gpio_set_input(GPIO_BTN);

    int val = 0;
    while (1) {
        gpio_write(pin, val);
        val = !val;
        delay_ms(500);
    }
}
