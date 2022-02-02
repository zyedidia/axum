include config.mk

TOP=axum_top
REPORT=report.json
GENDIR=generated

CXXRTL=sim/$(TOP).cxx
TB=sim/cxxrtl.cc
VERILATOR_SIM=sim/verilator.cc
SIM_BIN=sim.out
CXX_FLAGS=-O2 -std=c++14

SOURCES := ibex/rtl/ibex_alu.sv \
		   ibex/rtl/ibex_branch_predict.sv \
		   ibex/rtl/ibex_compressed_decoder.sv \
		   ibex/rtl/ibex_controller.sv \
		   ibex/rtl/ibex_core.sv \
		   ibex/rtl/ibex_counter.sv \
		   ibex/rtl/ibex_cs_registers.sv \
		   ibex/rtl/ibex_csr.sv \
		   ibex/rtl/ibex_decoder.sv \
		   ibex/rtl/ibex_ex_block.sv \
		   ibex/rtl/ibex_fetch_fifo.sv \
		   ibex/rtl/ibex_icache.sv \
		   ibex/rtl/ibex_id_stage.sv \
		   ibex/rtl/ibex_if_stage.sv \
		   ibex/rtl/ibex_load_store_unit.sv \
		   ibex/rtl/ibex_lockstep.sv \
		   ibex/rtl/ibex_multdiv_fast.sv \
		   ibex/rtl/ibex_multdiv_slow.sv \
		   ibex/rtl/ibex_pmp.sv \
		   ibex/rtl/ibex_prefetch_buffer.sv \
		   ibex/rtl/ibex_register_file_fpga.sv \
		   ibex/rtl/ibex_top.sv \
		   ibex/rtl/ibex_top_tracing.sv \
		   ibex/rtl/ibex_wb_stage.sv \
		   ibex/shared/rtl/ram_2p.sv \
		   ibex/shared/rtl/bus.sv \
		   rtl/lib/prim_generic_ram_2p.sv \
		   rtl/lib/prim_ram_2p.sv \
		   rtl/lib/fifo.sv \
		   rtl/lib/fifo_ctrl.sv \
		   rtl/lib/fifo_reg_file.sv \
		   rtl/uart/uart_rx.sv \
		   rtl/uart/uart_tx.sv \
		   rtl/uart/uart.sv \
		   rtl/uart/baud_gen.sv \
		   rtl/axum_gpio.sv \
		   rtl/axum_timer.sv \
		   rtl/axum_uart.sv \
		   rtl/$(TOP).sv

GENV=$(addprefix $(GENDIR)/,$(notdir $(SOURCES:.sv=.v)))
SYNTH=$(GENV) rtl/lib/clkgen.v rtl/lib/prim_clock_gating.v

DEFINE := -DSYNTHESIS
INC := -I./rtl/lib \
	   -I./ibex/vendor/lowrisc_ip/ip/prim/rtl \
	   -I./ibex/vendor/lowrisc_ip/dv/sv/dv_utils
PKG := ./ibex/rtl/*_pkg.sv \
	   ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
	   ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_2p_pkg.sv \
	   ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv

include boards/$(BOARD)/all.mk

include deps.mk

# Synthesis rules

include boards/$(BOARD)/$(BOARD).mk

# SystemVerilog to Verilog conversion rules

generate: $(GENV)

$(GENDIR)/%.v: rtl/lib/%.sv
	sv2v $(DEFINE) $(PKG) $(INC) -w $@ $<

$(GENDIR)/%.v: rtl/uart/%.sv
	sv2v $(DEFINE) $(PKG) $(INC) -w $@ $<

$(GENDIR)/%.v: rtl/%.sv
	sv2v $(DEFINE) $(PKG) $(INC) -w $@ $<

$(GENDIR)/%.v: ibex/shared/rtl/%.sv
	sv2v $(DEFINE) $(PKG) $(INC) -w $@ $<

$(GENDIR)/%.v: ibex/rtl/%.sv
	sv2v $(DEFINE) $(PKG) $(INC) -w $@ $<

# Simulation rules

## CXXRTL

$(CXXRTL): $(SYNTH) $(BUILDSTAMP)
	yosys -p 'read_verilog -defer -noautowire -sv $(SYNTH); chparam -set SRAMInitFile "$(MEM)" $(TOP); hierarchy -top $(TOP); write_cxxrtl -nohierarchy -O6 -g0 $(CXXRTL)'

$(SIM_BIN): $(CXXRTL) $(TB)
	$(CXX) $(CXX_FLAGS) -I $(shell yosys-config --datdir)/include $(TB) -o $@

cxxrtl: $(SIM_BIN)

## Verilator

obj_dir/$(SIM_BIN).vtor: $(VERILATOR_SIM) $(SOURCES) $(BUILDSTAMP)
	verilator -sv -cc $(DEFINE) $(PKG) $(INC) $(SOURCES) -Wno-WIDTH -Wno-LITENDIAN --top $(TOP) -GSRAMInitFile='"$(MEM)"' --trace --exe --build $< -o $(notdir $@)

verilator: obj_dir/$(SIM_BIN).vtor

# Linting

lint:
	verilator -sv -Wall --lint-only $(DEFINE) $(PKG) $(INC) $(SOURCES) -Wno-WIDTH -Wno-LITENDIAN --top $(TOP) -GSRAMInitFile='"$(MEM)"'

clean:
	rm -rf obj_dir
	rm -f generated/*
	rm -f $(TOP).bit $(TOP).dfu $(TOP)_out.config $(TOP).json $(TOP) $(REPORT) *.vcd $(CXXRTL) $(SIM_BIN)

# Debug rule

print-%  : ; @echo $* = $($*)

.PHONY: clean prog generate all lint verilator cxxrtl
