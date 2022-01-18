#include "libaxum.h"

void timer_interrupt() {}

void send_hello(int i) {
    uart_tx('h');
    uart_tx('e');
    uart_tx('l');
    uart_tx('l');
    uart_tx('o');
    uart_tx(' ');
    uart_tx('0' + i);
    uart_tx('\n');
}

int main() {
    uart_set_baud(115200);

    int val = 0;
    int i = 0;
    while (1) {
        send_hello(i);
        gpio_write(GPIO_LED_B, val);
        val = !val;
        delay_ms(1000);
        i++;
    }
}
