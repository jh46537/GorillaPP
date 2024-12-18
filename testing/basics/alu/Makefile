SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = build/generated/ALU.sv
# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ALU
# the basename of the Python test file
COCOTB_TEST_MODULES = alu_tb
# generate FST format waveforms for GTKWave
EXTRA_ARGS += --trace --trace-fst --trace-structs
#VCD_FILE = sim.vcd

include $(shell cocotb-config --makefiles)/Makefile.sim

simtop:
	# run testbench
	sim

# this is hacky until we get the entire primate core to compile on chisel 6
build/generated/ALU.sv: ../../../hw/templates/alu.scala
	mkdir -p build/hw-gen
	cp ../../build.sbt build
	cp ../../../hw/templates/alu.scala build
	cp ../../../hw/templates/include.scala build
	cd build; sbt run

clean::
	rm -r build

.PHONY: clean
