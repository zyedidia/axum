#include "libaxum.h"

int main() {
    const int led = GPIO_LED_B;
    const int btn = GPIO_BTN;

    gpio_set_output(led);
    gpio_set_input(btn);

    while (1) {
        gpio_write(led, gpio_read(btn));
        delay_ms(1);
    }
}
