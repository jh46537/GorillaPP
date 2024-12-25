####################################################################
# Top level makefile for the project
####################################################################

#set PRIMATE_ROOT env var to the primate dir path
PRIMATE_ROOT ?= /primate

PRIMATE_COMPILER_ROOT=${PRIMATE_ROOT}/primate-compiler
PRIMATE_UARCH_ROOT=${PRIMATE_ROOT}/primate-uarch
PRIMATE_SCRIPTS=${PRIMATE_UARCH_ROOT}/scripts
USER_DIR=$(shell pwd)

BUILD_DIR=./build
COMPILER_GEN_DIR=${BUILD_DIR}/primate-compiler-gen
HWGEN_DIR=${BUILD_DIR}/hw-gen

# finds the basename of the file containing "primate_main"
TARGET:=$(shell find -type f -iname '*.cpp' -exec grep -iH 'primate_main' {} \; | awk -F ':' '{print $$1}' | awk -F '/' '{print $$2}' | awk -F '\.' '{print $$1}')
LLVM_BUILD_TOOL=ninja
SBT:=sbt

SW_SOURCE_FILES := $(wildcard *.cpp)

help: 
	@echo "host-sim: Build an executable that simulates the primate program on the host machine"
	@echo "		"
	@echo "primate-sim: Build hardware and software and the finally run a verilator simulation"
	@echo "		"
# TODO: WRITE WHERE THE Top.sv FILE IS WRITTEN
	@echo "primate-hardware: Build the primate hardware and emit a Top.sv file."
	@echo "		"
	@echo "primate-software: Compile the program into a primate executable"
	@echo "		Location: ${BUILD_DIR}/primate_sim_pgm_out/**"

# should probably do this better
host-sim: ${SW_SOURCE_FILES}
	@echo "Building the host simulator"
	clang++ -fsanitize=address -std=c++17 -g3 -O3 -I${PRIMATE_UARCH_ROOT}/sw/common -DPRIMATE_HOST_SIM=1 ${SW_SOURCE_FILES} -o ${BUILD_DIR}/host-sim-user-code.o -c
	clang++ -fsanitize=address -std=c++17 -g3 -O3 -I${PRIMATE_UARCH_ROOT}/sw/common -DPRIMATE_HOST_SIM=1 ${PRIMATE_UARCH_ROOT}/sw/common/primate-host-sim-main.cpp -o ${BUILD_DIR}/host-sim-main.o -c
	clang++ -fsanitize=address -std=c++17 -g3 -O3 ${BUILD_DIR}/host-sim-user-code.o ${BUILD_DIR}/host-sim-main.o -o ${BUILD_DIR}/host-sim

primate-sim: | primate-hardware primate-software move-software
	@echo "running RTL simulator"
	@cd ${BUILD_DIR} && ${SBT} "runMain TopMain --backend-name verilator --full-stacktrace"

primate-hardware: | ${HWGEN_DIR} move-hardware
	@echo "generating RTL"
	@cp ${PRIMATE_SCRIPTS}/build.sbt ${BUILD_DIR}
	@cd ${BUILD_DIR}; ${SBT} "runMain Main"


primate-software: ${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_text

# rule to move primate-pgm to the simulator dir.
move-software: ${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_text ${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_mem input.txt | ${HWGEN_DIR}
	@echo "Moving primate program binary into ${HWGEN_DIR}"
	@cp input.txt                    ${BUILD_DIR}/
	@cp ${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_text ${BUILD_DIR}/primate_pgm.bin
	@cp ${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_mem  ${BUILD_DIR}/memInit.txt


# rule to create the primate compiler. depends on the tablegen files
move-hardware: ${HWGEN_DIR} ${HWGEN_DIR}/Primate.scala | ${HWGEN_DIR} ${BUILD_DIR}
	@echo "Moving hardware files into ${HWGEN_DIR}"
	#TODO: can we coax SBT/mill into compiling scala in place (search the hw dir) so we dont have to do this copy?
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.scala' | xargs -i cp {} ${HWGEN_DIR}
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.sv' | xargs -i cp {} ${HWGEN_DIR}
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.v' | xargs -i cp {} ${HWGEN_DIR}


# instance the primate scala file
${HWGEN_DIR}/Primate.scala: ${BUILD_DIR}/primate.cfg ${PRIMATE_UARCH_ROOT}/hw/templates/primate.template bfu_list.txt | ${HWGEN_DIR}
	@echo "Generating Primate core chisel file"
	@python3 ${PRIMATE_UARCH_ROOT}/scripts/scm.py -p ${BUILD_DIR}/primate.cfg -t ${PRIMATE_UARCH_ROOT}/hw/templates/primate.template -o ${HWGEN_DIR}/Primate.scala -b bfu_list.txt

# rule for creating the primate program instructions
# in a simulator readable format
${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_mem: ${BUILD_DIR}/primate_exe ${PRIMATE_COMPILER_ROOT}/primate-loader.py
	@echo "Primate binary to simulator memory format"
	@${PRIMATE_COMPILER_ROOT}/primate-loader.py -i ${BUILD_DIR}/primate_exe -o ${BUILD_DIR}/primate_sim_pgm_out -p ${BUILD_DIR}/primate.cfg

# rule for creating the primate program instructions
# in a simulator readable format
${BUILD_DIR}/primate_sim_pgm_out/primate_pgm_text: ${BUILD_DIR}/primate_exe ${PRIMATE_COMPILER_ROOT}/primate-loader.py
	@echo "Primate binary to simulator instruction format"
	@${PRIMATE_COMPILER_ROOT}/primate-loader.py -i ${BUILD_DIR}/primate_exe -o ${BUILD_DIR}/primate_sim_pgm_out -p ${BUILD_DIR}/primate.cfg

# rule to create the binary for the primate program.
# depends on the compiler generated binary and converts it into hex files that verilog can read
${BUILD_DIR}/primate_exe: ${BUILD_DIR}/primate_pgm.o ${BUILD_DIR}/primate.cfg
	@echo "Building the primate program binary"
	@${PRIMATE_COMPILER_ROOT}/build/bin/ld.lld -T /primate/primate-uarch/scripts/linker-script ${BUILD_DIR}/primate_pgm.o -o ${BUILD_DIR}/primate_exe



# call the compiler to create the primate program object file
${BUILD_DIR}/primate_pgm.o: ${PRIMATE_COMPILER_ROOT}/build/bin/clang++ ${SW_SOURCE_FILES}
	@echo "Building the primate program"
	@cd ${BUILD_DIR} && ${PRIMATE_COMPILER_ROOT}/build/bin/clang++ -fpack-struct=1 -I${PRIMATE_UARCH_ROOT}/sw/common -O3 -mllvm -debug -mllvm -print-after-all --target=primate32-linux-gnu -fno-pic -march=pr32i "${USER_DIR}/${TARGET}.cpp" -c -o primate_pgm.o 2> compile.log


# rule to create the primate.cfg file. Requires that arch-gen is built
# archgen depends on the bfu_lists.txt. so I think that breaks any chains we may have
# opt will crash on exit. || true is just to keep moving.
${BUILD_DIR}/primate.cfg: ${PRIMATE_COMPILER_ROOT}/build/lib/libLLVMPrimateArchGen.a ${SW_SOURCE_FILES} | ${BUILD_DIR}
	@echo "Building the primate.cfg file"
	@cd ${BUILD_DIR} && ${PRIMATE_COMPILER_ROOT}/build/bin/clang++ -fpack-struct=1 -I${PRIMATE_UARCH_ROOT}/sw/common -emit-llvm -S -mllvm -print-after-all --target=primate32-linux-gnu -march=pr32i -O3 -mllvm -debug "../${TARGET}.cpp" -o "${TARGET}.ll" 2> frontend.log
	@-cd ${BUILD_DIR} && ${PRIMATE_COMPILER_ROOT}/build/bin/opt -debug -passes=primate-arch-gen -debug < "${TARGET}.ll" > /dev/null 2> arch-gen.log 


# rule to create the software compiler. depends on having a valid primate.cfg
${PRIMATE_COMPILER_ROOT}/build/bin/clang++: ${BUILD_DIR}/primate.cfg ${COMPILER_GEN_DIR}/IntrinsicsPrimateBFU.td ${COMPILER_GEN_DIR}/PrimateInstrInfoBFU.td ${COMPILER_GEN_DIR}/PrimateSchedPrimate.td ${COMPILER_GEN_DIR}/PrimateScheduleBFU.td ${COMPILER_GEN_DIR}/PrimateRegisterDefs.td ${COMPILER_GEN_DIR}/PrimateRegisterOrdering.td ${COMPILER_GEN_DIR}/PrimateInstrReconfigFormats.td ${COMPILER_GEN_DIR}/PrimateInstrReconfigF.td ${COMPILER_GEN_DIR}/PrimateDisasseblerGen.inc ${COMPILER_GEN_DIR}/PrimateInstructionSize.inc
	@echo "Building the software compiler"
	@cp ${COMPILER_GEN_DIR}/IntrinsicsPrimateBFU.td ${PRIMATE_COMPILER_ROOT}/llvm/include/llvm/IR/IntrinsicsPrimateBFU.td
	@cp ${COMPILER_GEN_DIR}/PrimateInstrInfoBFU.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/PrimateInstrInfoBFU.td
	@cp ${COMPILER_GEN_DIR}/PrimateSchedPrimate.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
	@cp ${COMPILER_GEN_DIR}/PrimateScheduleBFU.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/PrimateScheduleBFU.td    
	@cp ${COMPILER_GEN_DIR}/PrimateRegisterDefs.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/
	@cp ${COMPILER_GEN_DIR}/PrimateRegisterOrdering.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/
	@cp ${COMPILER_GEN_DIR}/PrimateInstrReconfigFormats.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/
	@cp ${COMPILER_GEN_DIR}/PrimateInstrReconfigF.td ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/
	@cp ${COMPILER_GEN_DIR}/PrimateDisasseblerGen.inc ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/Disassembler/PrimateDisasseblerGen.inc
	@cp ${COMPILER_GEN_DIR}/PrimateInstructionSize.inc ${PRIMATE_COMPILER_ROOT}/llvm/lib/Target/Primate/MCTargetDesc/PrimateInstructionSize.inc
	@${LLVM_BUILD_TOOL} -C ${PRIMATE_COMPILER_ROOT}/build


# rule to create arch-gen depends on the tablegen for the primate intrinsics used during optimization pipeline
${PRIMATE_COMPILER_ROOT}/build/lib/libLLVMPrimateArchGen.a: ${COMPILER_GEN_DIR}/IntrinsicsPrimateBFU.td
	@echo "Building the architecture generator"
	@${LLVM_BUILD_TOOL} -C ${PRIMATE_COMPILER_ROOT}/build


# intrinsics for the primate compiler. used for the primate instruction lowering
${BUILD_DIR}/primate-compiler-gen/IntrinsicsPrimateBFU.td: ${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py bfu_list.txt | ${BUILD_DIR}
	@echo "Generating the tablegen files"
	@cd ${BUILD_DIR} && \
	${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py -b ${USER_DIR}/bfu_list.txt --FrontendOnly


# rule to create the other tablegen files for the primate compiler
${BUILD_DIR}/%.td: ${BUILD_DIR}/primate.cfg | ${BUILD_DIR}
	@cd ${BUILD_DIR} && \
	${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py -b ${USER_DIR}/bfu_list.txt -p ./primate.cfg


${HWGEN_DIR}:
	@echo "creating ${HWGEN_DIR}"
	@mkdir -p ${HWGEN_DIR}

${BUILD_DIR}:
	@echo "creating ${BUILD_DIR}"
	@mkdir -p ${BUILD_DIR}

# Put this under a scripts target if we add more compilable scripts
primate_assembler: ${PRIMATE_SCRIPTS}/primate_assembler.cpp
	g++ -std=c++11 -o ${PRIMATE_SCRIPTS}/$@ $<

print-env: 
	@echo ${USER_DIR}
	@echo ${TARGET}

clean-sim:
	@-rm -rf ${HWGEN_DIR}/test_run_dir

clean:
	@-rm -rf ${BUILD_DIR}
	@-rm -f ${PRIMATE_SCRIPTS}/primate_assembler

.PHONY: clean print-env primate-software primate-hardware move-software move-hardware primate-sim clean-sim
