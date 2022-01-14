#include "gpio.h"
#include "bits.h"

typedef struct {
    unsigned input_val;
    unsigned input_en;
    unsigned output_en;
    unsigned output_val;
    unsigned iof_en;
    unsigned iof_sel;
    unsigned out_xor;
} gpio_reg_t;

static volatile gpio_reg_t* const gpio = (gpio_reg_t*) 0x20000;

void gpio_set_output(unsigned pin) {
    gpio->output_en = bit_set(gpio->output_en, pin);
    gpio->input_en = bit_clr(gpio->input_en, pin);
}

void gpio_set_input(unsigned pin) {
    gpio->output_en = bit_clr(gpio->output_en, pin);
    gpio->input_en = bit_set(gpio->input_en, pin);
}

void gpio_write(unsigned pin, unsigned val) {
    gpio->output_val = bit_assign(gpio->output_val, pin, val);
}

void gpio_set_xor(unsigned pin, unsigned val) {
    gpio->out_xor = bit_assign(gpio->out_xor, pin, val);
}

unsigned gpio_read(unsigned pin) {
    return bit_get(gpio->input_val, pin);
}

void gpio_configure(unsigned pin, gpio_iof_t mode) {
}

