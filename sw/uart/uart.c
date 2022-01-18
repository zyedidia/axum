#include "libaxum.h"

void timer_interrupt() {}

int main() {
    int i = 0;
    while (1) {
        printf("hello %d\n", i++);
        delay_ms(1000);
    }
}
