#include "libaxum.h"

int main() {
    gpio_set_output(GPIO_LED_R);
    gpio_write(GPIO_LED_R, 1);
    return 0;
}
