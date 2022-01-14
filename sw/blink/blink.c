#include "libaxum.h"

int main() {
    const int pin = GPIO_0;
    gpio_set_output(pin);

    int val = 0;
    while (1) {
        gpio_write(pin, val);
        val = !val;
        delay_ms(500);
    }
}
