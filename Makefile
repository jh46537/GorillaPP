####################################################################
# Top level makefile for the project
####################################################################

#set PRIMATE_ROOT env var to the primate dir path
PRIMATE_ROOT=/primate

PRIMATE_COMPILER_ROOT=${PRIMATE_ROOT}/primate-compiler
PRIMATE_UARCH_ROOT=${PRIMATE_ROOT}/primate-uarch
PRIMATE_SCRIPTS=${PRIMATE_UARCH_ROOT}/scripts
USER_DIR=$(shell pwd)

BUILD_DIR=./build
COMPILER_GEN_DIR=${BUILD_DIR}/primate-compiler-gen
HWGEN_DIR=${BUILD_DIR}/hw-gen
SBT_SCALA_DIR=${HWGEN_DIR}/src/main/scala/ # I cannot get chisel to build unless files are in this directory!!??
SBT_RESOURCES_DIR=${HWGEN_DIR}/src/main/resources/

SBT:=sbt
TARGET=main
LLVM_BUILD_TOOL=ninja

primate-hardware: move-hardware
	@echo "generating RTL"
	@cp ${PRIMATE_SCRIPTS}/build.sbt ${HWGEN_DIR}
	@cd ${HWGEN_DIR}; ${SBT} "runMain primate.Main"

primate-software: ${BUILD_DIR}/primate_pgm.bin
#primate-hardware: ${HWGEN_DIR}/Primate.scala
primate-sim: | move-software move-hardware
	@echo "running RTL simulator"
	@make -C /primate/primate-uarch/chisel/ waves

# rule to move primate-pgm to the simulator dir.
move-software: ${BUILD_DIR}/primate_pgm.bin ${BUILD_DIR}/memInit.txt input.txt
	@echo "Moving primate program binary into ${HWGEN_DIR}"
	@cp ${BUILD_DIR}/primate_pgm.bin ${HWGEN_DIR}
	@cp ${BUILD_DIR}/memInit.txt ${HWGEN_DIR}
	@cp input.txt ${HWGEN_DIR}

# rule to create the primate compiler. depends on the tablegen files
move-hardware: ${HWGEN_DIR}/Primate.scala ${SBT_RESOURCES_DIR}
	@echo "Moving hardware files into ${HWGEN_DIR}"
	# i dont like this, but sbt sucks and we have no choice
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.scala' | xargs -i cp {} ${SBT_SCALA_DIR}
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.sv' | xargs -i cp {} ${SBT_RESOURCES_DIR}
	@find ${PRIMATE_UARCH_ROOT}/hw -name '*.v' | xargs -i cp {} ${SBT_RESOURCES_DIR}

# instance the primate scala file
${HWGEN_DIR}/Primate.scala: primate.cfg ${PRIMATE_UARCH_ROOT}/hw/templates/primate.template bfu_list.txt ${HWGEN_DIR} ${SBT_SCALA_DIR}
	@echo "Generating Primate core chisel file"
	@python3 ${PRIMATE_UARCH_ROOT}/scripts/scm.py -p primate.cfg -t ${PRIMATE_UARCH_ROOT}/hw/templates/primate.template -o ${SBT_SCALA_DIR}/Primate.scala -b bfu_list.txt

# rule to create the binary for the primate program.
# depends on the compiler generated binary and converts it into hex files that verilog can read
${BUILD_DIR}/primate_pgm.bin: ${BUILD_DIR}/primate_pgm.o
	@echo "Building the primate program binary"
	@${PRIMATE_COMPILER_ROOT}/build/bin/llvm-objdump --triple=primate32-unknown-linux -dr ${BUILD_DIR}/primate_pgm.o > ${BUILD_DIR}/primate_pgm_text
	@${PRIMATE_COMPILER_ROOT}/build/bin/llvm-objdump --triple=primate32-unknown-linux -t ${BUILD_DIR}/primate_pgm.o > ${BUILD_DIR}/primate_pgm_sym
	@${PRIMATE_COMPILER_ROOT}/build/bin/llvm-objdump --triple=primate32-unknown-linux -s -j .rodata ${BUILD_DIR}/primate_pgm.o > ${BUILD_DIR}/primate_rodata
	@${PRIMATE_COMPILER_ROOT}/bin2asm.py ${BUILD_DIR}/primate_pgm_text ${BUILD_DIR}/primate_pgm_sym primate.cfg ${BUILD_DIR}/primate_pgm.bin
	@${PRIMATE_COMPILER_ROOT}/elf2meminit.py ${BUILD_DIR}/primate_rodata ${BUILD_DIR}/memInit.txt

# call the compiler to create the primate program object file
${BUILD_DIR}/primate_pgm.o: ${PRIMATE_COMPILER_ROOT}/build/bin/clang++ ${SW_SOURCE_FILES}
	@echo "Building the primate program"
	@${PRIMATE_COMPILER_ROOT}/build/bin/clang++ -O3 -mllvm -debug -mllvm -print-after-all --target=primate32-linux-gnu -march=pr32i "${TARGET}.cpp" -c -o ${BUILD_DIR}/primate_pgm.o 2> ${BUILD_DIR}/compile.log

# rule to create the primate.cfg file. Requires that arch-gen is built
# archgen depends on the bfu_lists.txt. so I think that breaks any chains we may have
# opt will crash on exit. || true is just to keep moving.
primate.cfg: ${PRIMATE_COMPILER_ROOT}/build/lib/libLLVMPrimateArchGen.a ${SW_SOURCE_FILES}
	@echo "Building the primate.cfg file"
	@${PRIMATE_COMPILER_ROOT}/build/bin/clang++ -emit-llvm -S -mllvm -print-after-all --target=primate32-linux-gnu -march=pr32i -O3 -mllvm -debug "${TARGET}.cpp" -o "${BUILD_DIR}/${TARGET}.ll" 2> ${BUILD_DIR}/frontend.log
	@-${PRIMATE_COMPILER_ROOT}/build/bin/opt -debug -passes=primate-arch-gen -debug < "${BUILD_DIR}/${TARGET}.ll" > /dev/null 2> ${BUILD_DIR}/arch-gen.log 
	
# rule to create the software compiler. depends on having a valid primate.cfg
${PRIMATE_COMPILER_ROOT}/build/bin/clang++: primate.cfg ${COMPILER_GEN_DIR}/IntrinsicsPrimateBFU.td ${COMPILER_GEN_DIR}/PrimateInstrInfoBFU.td ${COMPILER_GEN_DIR}/PrimateSchedPrimate.td ${COMPILER_GEN_DIR}/PrimateScheduleBFU.td ${COMPILER_GEN_DIR}/PrimateRegisterDefs.td ${COMPILER_GEN_DIR}/PrimateRegisterOrdering.td ${COMPILER_GEN_DIR}/PrimateInstrReconfigFormats.td ${COMPILER_GEN_DIR}/PrimateInstrReconfigF.td ${COMPILER_GEN_DIR}/PrimateDisasseblerGen.inc ${COMPILER_GEN_DIR}/PrimateInstructionSize.inc
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
${BUILD_DIR}/primate-compiler-gen/IntrinsicsPrimateBFU.td: ${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py bfu_list.txt ${BUILD_DIR}
	@echo "Generating the tablegen files"
	@cd ${BUILD_DIR} && \
	${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py -b ${USER_DIR}/bfu_list.txt --FrontendOnly

# rule to create the other tablegen files for the primate compiler
${BUILD_DIR}/%.td: primate.cfg ${BUILD_DIR}
	@cd ${BUILD_DIR} && \
	${PRIMATE_COMPILER_ROOT}/archgen2tablegen.py -b ${USER_DIR}/bfu_list.txt -p ${USER_DIR}/primate.cfg

${HWGEN_DIR}:
	@mkdir -p ${HWGEN_DIR}

${SBT_SCALA_DIR}:
	@mkdir -p ${SBT_SCALA_DIR}

${SBT_RESOURCES_DIR}:
	@mkdir -p ${SBT_RESOURCES_DIR}

${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}

# Put this under a scripts target if we add more compilable scripts
primate_assembler: ${PRIMATE_SCRIPTS}/primate_assembler.cpp
	g++ -std=c++11 -o ${PRIMATE_SCRIPTS}/$@ $<

print-env: 
	@echo ${USER_DIR}

clean:
	@rm -rf ${BUILD_DIR} primate_pgm.bin
	@rm ${PRIMATE_SCRIPTS}/primate_assembler

.PHONY: clean print-env primate-software primate-hardware