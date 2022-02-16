#include "libaxum.h"

uint32_t getsp() {
    return get32((void*) (2 * sizeof(uint32_t)));
}

int main() {
    int i = 0;
    while (1) {
        printf("hello %d\n", i++);
        delay_ms(1000);
    }
}
