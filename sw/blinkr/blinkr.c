#include "libaxum.h"

int main() {
    gpio_set_output(14);

    int val = 0;
    while (1) {
        gpio_write(14, val);
        val = !val;
        delay_ms(500);
    }
}
