#*******************************************************************************
# Creator:        Hai Cao Xuan (cxhai.sdh221@hcmut.edu.vn)
# Description:    makefile
#*******************************************************************************
# Copyright (c) 2022 Hai Cao Xuan
#*******************************************************************************

FILES := $(shell cat filelist)

VERILATOR = verilator
VERILATOR_COV = verilator_coverage

### LINT FLAGS
LINT_FLAGS = -Wall --lint-only -sv

### VERILATE FLAGS
# Generate C++ in executable form
VERILATOR_FLAGS += -sv -cc
# Optimize
VERILATOR_FLAGS += -x-initial unique
VERILATOR_FLAGS += -x-assign unique
VERILATOR_FLAGS += -O3 -CFLAGS -DCOVERAGE
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Enable assertion
VERILATOR_FLAGS += --assert
# Make waveforms
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --build -j

# Input files for Verilator
VERILATOR_INPUT = $(FILES) top.sv --top-module top

.PHONY: help
help:
	@echo -e "make [option]"
	@echo -e "\tlint    run lint checks for syntax and violations"
	@echo -e "\tbuild   verilate and build modules"
	@echo -e "\tsim     run simulation"
	@echo -e "\twave    open waveforms"
	@echo -e "\tclean   clean the working folder"
	@echo -e "\thelp    print this help"

.PHONY: lint
lint:
	@echo "------------------> LINT CHECK <------------------"
	@$(VERILATOR) $(LINT_FLAGS) $(FILES)

.PHONY: build
build: ./obj_dir/Vtop
./obj_dir/Vtop: $(FILES) test/driver.cpp top.sv
	@echo "-------------------> BUILD <----------------------"
	@$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT) --exe test/tb_top.cpp

.PHONY: sim
sim: ./obj_dir/Vtop
	@echo "-----------------> SIMULATING <-------------------"
	@./obj_dir/Vtop

.PHONY: wave
wave: wave.fst
	@echo "-----------------> WAVEFORMS <--------------------"
	@gtkwave wave.fst wave.gtkw

.PHONY: clean
clean:
	@rm -rf obj_dir
	@rm -f *.fst
	@echo "-----------------> ALL CLEAN <--------------------"
