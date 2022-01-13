#include <stdlib.h>
#include "Vsoc_top.h"
#include "Vsoc_top___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::traceEverOn(true);

	// Initialize Verilators variables
    Verilated::commandArgs(argc, argv);

	// Create an instance of our module under test
    Vsoc_top* dut = new Vsoc_top;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("trace.vcd");

    dut->rst_n = 0;
    dut->eval();
    dut->rst_n = 1;
    dut->eval();

    // Tick the clock until we are done
    for (int i = 0; i < 1000; i++) {
        dut->clk = 0;
        dut->eval();
        tfp->dump(i*2);

        printf("%d\n", dut->rgb_led0_r);

        dut->clk = 1;
        dut->eval();
        tfp->dump(i*2+1);
        tfp->flush();

        printf("%d\n", dut->rgb_led0_r);
    }

    tfp->close();
    return 0;
}
