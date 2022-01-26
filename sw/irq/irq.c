#include "libaxum.h"

void irq_handler() {
    volatile regs_t* ctx = rf_ctx(RF_CTX_NORMAL);
    /* int s = 0; */
    /* for (int i = 0; i < 32; i++) { */
    /*     s += get_reg(ctx, i); */
    /* } */
    for (int i = 0; i < 32; i++) {
        printf("x%d: %lu\n", i, get_reg(ctx, i));
    }
}

int main() {
    set_timer_irq_handler(irq_handler);

    volatile int val = 0;

    while (1) {
        val++;
        gpio_write(GPIO_LED_R, val % 2 == 0);
        delay_ms(500);
    }

    return 0;
}
