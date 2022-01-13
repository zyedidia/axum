TOP=soc_top
CONS=lpf/orangecrab.lpf
REPORT=report.json
GENDIR=generated
MEM ?= mem/empty.vmem

CXXRTL=sim/$(TOP).cxx
TB=sim/sim.cc
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
		   rtl/prim_generic_ram_2p.sv \
		   rtl/prim_ram_2p.sv \
		   rtl/$(TOP).sv

GENV=$(addprefix $(GENDIR)/,$(notdir $(SOURCES:.sv=.v)))
SYNTH=$(GENV) rtl/clkgen.v rtl/prim_clock_gating.v

all: $(TOP).dfu

generate: $(GENV)

print-%  : ; @echo $* = $($*)

$(GENDIR)/%.v: rtl/%.sv
	sv2v \
	--define=SYNTHESIS \
	./ibex/rtl/*_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_2p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv \
	-I./rtl \
	-I./ibex/vendor/lowrisc_ip/ip/prim/rtl \
	-I./ibex/vendor/lowrisc_ip/dv/sv/dv_utils \
	$< > $@

$(GENDIR)/%.v: ibex/shared/rtl/%.sv
	sv2v \
	--define=SYNTHESIS \
	./ibex/rtl/*_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_2p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv \
	-I./ibex/vendor/lowrisc_ip/ip/prim/rtl \
	-I./ibex/vendor/lowrisc_ip/dv/sv/dv_utils \
	$< > $@

$(GENDIR)/%.v: ibex/rtl/%.sv
	sv2v \
	--define=SYNTHESIS \
	./ibex/rtl/*_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_2p_pkg.sv \
	./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv \
	-I./ibex/vendor/lowrisc_ip/ip/prim/rtl \
	-I./ibex/vendor/lowrisc_ip/dv/sv/dv_utils \
	$< > $@

# Synthesis rules

$(TOP).json: $(SYNTH)
	yosys -p 'read_verilog -defer -noautowire -sv $(SYNTH); chparam -set SRAMInitFile "$(MEM)" $(TOP); hierarchy -top $(TOP); synth_ecp5 -top $(TOP) -json $@'

$(TOP)_out.config: $(CONS) $(TOP).json
	nextpnr-ecp5 -q --lpf-allow-unconstrained --report $(REPORT) --25k --freq 48 --lpf $< --package CSFBGA285 --textcfg $@ --json $(TOP).json

$(TOP).bit: $(TOP)_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

$(TOP).dfu: $(TOP).bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

prog: $(TOP).dfu
	sudo dfu-util -D $<

# Simulation rules

$(CXXRTL): $(SYNTH)
	yosys -p 'read_verilog -defer -noautowire -sv $(SYNTH); chparam -set SRAMInitFile "$(MEM)" $(TOP); hierarchy -top $(TOP); write_cxxrtl -nohierarchy -O4 $(CXXRTL)'

$(SIM_BIN): $(CXXRTL) $(TB)
	$(CXX) $(CXX_FLAGS) -I $(shell yosys-config --datdir)/include $(TB) -o $@

test: $(SIM_BIN)
	@./$<

$(SIM_BIN).vtor: $(VERILATOR_SIM)
	verilator -sv -cc -DSYNTHESIS ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_2p_pkg.sv ./ibex/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv -I./rtl -I./ibex/vendor/lowrisc_ip/ip/prim/rtl -I./ibex/vendor/lowrisc_ip/dv/sv/dv_utils ibex/rtl/*_pkg.sv $(SOURCES) -Wno-WIDTH -Wno-LITENDIAN --top $(TOP) -GSRAMInitFile='"$(MEM)"' --trace --exe --build $< -o $@


clean:
	rm -rf obj_dir
	rm -rf generated
	rm -f $(TOP).bit $(TOP).dfu $(TOP)_out.config $(TOP).json $(TOP) $(REPORT) *_sim.cc *.vcd

.PHONY: clean lint prog test report waveform all synth tb
