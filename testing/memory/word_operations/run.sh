#!/bin/bash

# ================================================
# =          Set Up Some Useful Variables        =
# ================================================
set -o xtrace
set -e

TARGET=aes
CUR_DIR=$(pwd)
PRIMATE_DIR=/primate
COMPILER_DIR=$PRIMATE_DIR/primate-compiler
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=${CUR_DIR}/PrimateHW/src

make clean-hw -C ${CHISEL_SRC_DIR}/..
# ================================================
# =       Generate Primate Compiler              =
# ================================================
cd ${CUR_DIR}/sw

mkdir -p ./primate-compiler-gen
touch ./primate-compiler-gen/IntrinsicsPrimateBFU.td
touch ./primate-compiler-gen/PrimateInstrInfoBFU.td
touch ./primate-compiler-gen/PrimateSchedPrimate.td
touch ./primate-compiler-gen/PrimateScheduleBFU.td
touch ./primate-compiler-gen/PrimateRegisterDefs.td
touch ./primate-compiler-gen/PrimateRegisterOrdering.td
touch ./primate-compiler-gen/PrimateInstrReconfigFormats.td
touch ./primate-compiler-gen/PrimateInstrReconfigF.td

ln -s ${CUR_DIR}/hw/primate.cfg . || true
ln -s ${CUR_DIR}/hw/bfu_list.txt . || true

oldPrimateCompilerGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)

${COMPILER_DIR}/archgen2tablegen.py -b ${CUR_DIR}/hw/bfu_list.txt -p ${CUR_DIR}/hw/primate.cfg

newPrimateCompilerGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)

if [ "${oldPrimateCompilerGenHash}" != "${newPrimateCompilerGenHash}" ]; then
    echo "Tablegen files have changed. Please update the compiler."
    cp ./primate-compiler-gen/IntrinsicsPrimateBFU.td ${COMPILER_DIR}/llvm/include/llvm/IR/IntrinsicsPrimateBFU.td
    cp ./primate-compiler-gen/PrimateInstrInfoBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateInstrInfoBFU.td
    cp ./primate-compiler-gen/PrimateSchedPrimate.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
    cp ./primate-compiler-gen/PrimateScheduleBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateScheduleBFU.td

    cp ./primate-compiler-gen/BuiltinsPrimate.def ${COMPILER_DIR}/clang/include/clang/Basic/BuiltinsPrimate.def
    cp ./primate-compiler-gen/primate_bfu.td ${COMPILER_DIR}/clang/include/clang/Basic/primate_bfu.td

    cp ./primate-compiler-gen/PrimateRegisterDefs.td ${COMPILER_DIR}/llvm/lib/Target/Primate/
    cp ./primate-compiler-gen/PrimateRegisterOrdering.td ${COMPILER_DIR}/llvm/lib/Target/Primate/
    cp ./primate-compiler-gen/PrimateInstrReconfigFormats.td ${COMPILER_DIR}/llvm/lib/Target/Primate/
    cp ./primate-compiler-gen/PrimateInstrReconfigF.td ${COMPILER_DIR}/llvm/lib/Target/Primate/

    cp ./primate-compiler-gen/PrimateDisasseblerGen.inc ${COMPILER_DIR}/llvm/lib/Target/Primate/Disassembler/PrimateDisasseblerGen.inc
    cp ./primate-compiler-gen/PrimateInstructionSize.inc ${COMPILER_DIR}/llvm/lib/Target/Primate/MCTargetDesc/PrimateInstructionSize.inc
else 
    echo "Tablegen files have not changed." 
fi

# make compiler
ninja -C ${COMPILER_DIR}/build
# generate side files required
${COMPILER_DIR}/build/bin/clang++ -O3 -mllvm -align-all-blocks=0 -mllvm -print-after-all -mllvm -debug --target=primate32-linux-gnu -march=pr32i -fno-pic -I${UARCH_DIR}/apps/common -c ./${TARGET}.cpp -o primate_pgm.o 2> compiler.log
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -dr primate_pgm.o > primate_pgm_text
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -t primate_pgm.o > primate_pgm_sym
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -s -j .rodata primate_pgm.o > primate_rodata
${COMPILER_DIR}/bin2asm.py ./primate_pgm_text ./primate_pgm_sym ${CUR_DIR}/hw/primate.cfg ./primate_pgm.bin
${COMPILER_DIR}/elf2meminit.py ./primate_rodata ./memInit.txt
# $UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin

cp primate_pgm.bin $CHISEL_SRC_DIR/..

# ================================================
# =       Create Primate.scala From Template     =
# ================================================
cd $CUR_DIR/hw
ln -s ../sw/memInit.txt $CHISEL_SRC_DIR/..
cp -s $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
ln -sf header.scala $CHISEL_SRC_DIR/main/scala/
ln -sf alu_bfu0.scala $CHISEL_SRC_DIR/main/scala/
ln -sf alu_bfu1.scala $CHISEL_SRC_DIR/main/scala/
ln -sf cache.scala $CHISEL_SRC_DIR/main/scala/
ln -sf inOutUnit.scala $CHISEL_SRC_DIR/main/scala/
ln -sf inputUnit.scala $CHISEL_SRC_DIR/main/scala/
ln -sf inputUnit_core.scala $CHISEL_SRC_DIR/main/scala/
ln -sf outputUnit_simple.scala $CHISEL_SRC_DIR/main/scala/
ln -sf primate.scala $CHISEL_SRC_DIR/main/scala/
[[ -e *.v ]] && ln -sf *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && ln -sf *.sv $CHISEL_SRC_DIR/main/resources/
rm primate.template
cd $UARCH_DIR/templates
ln -sf *.scala $CHISEL_SRC_DIR/main/scala/
ln -sf *.v $CHISEL_SRC_DIR/main/resources/
cd $CUR_DIR
