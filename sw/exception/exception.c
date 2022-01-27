#include "libaxum.h"

void exception_handler(int mcause) {
    printf("Exception!\n");
    printf("mcause: %d\n", mcause);
    regs_p ctx = rf_ctx(RF_CTX_NORMAL);
    for (int i = 1; i < 32; i++) {
        printf("x%d: %lx\n", i, get_reg(ctx, i));
    }
}

int main() {
    set_exception_handler(exception_handler);

    asm volatile ("ebreak");

    return 0;
}
