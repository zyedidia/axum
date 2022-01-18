#include "libaxum.h"

void timer_interrupt() {}

int main() {
    const int led = GPIO_0;
    const int btn = GPIO_BTN;

    gpio_set_output(led);
    gpio_set_input(btn);

    while (1) {
        gpio_write(led, gpio_read(btn));
        delay_ms(1);
    }
}
