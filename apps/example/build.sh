#!/bin/bash

set -o xtrace

TARGET=tcp_parse
CUR_DIR=$(pwd)
cd ../../../
PRIMATE_DIR=/primate
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
COMPILER_DIR=$PRIMATE_DIR/primate-compiler
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=$UARCH_DIR/chisel/Gorilla++/src
cd $UARCH_DIR/compiler/engineCompiler/multiThread/
make clean && make
cd $UARCH_DIR/apps/common/build/
make clean && make
cd $CUR_DIR/sw
ninja -C $LLVM_DIR/build
$LLVM_DIR/build/bin/clang -emit-llvm -S -O3 --target=riscv32-linux-gnu -march=rv32i "${TARGET}.cpp" -o "${TARGET}.ll"
$LLVM_DIR/build/bin/opt -enable-new-pm=0 -load $LLVM_DIR/build/lib/LLVMPrimate.so -debug -primate < "${TARGET}.ll" > /dev/null 2> arch-gen.log
cp primate.cfg $CUR_DIR/hw
mv primate.cfg $CHISEL_SRC_DIR/main/scala/
cp input.txt $UARCH_DIR/chisel/Gorilla++/
mv primate_assembler.h $UARCH_DIR/apps/scripts/
cd $UARCH_DIR/apps/scripts/
make clean && make
cd $CUR_DIR/sw

echo "done with archgen..."
cp ${CUR_DIR}/hw/primate.cfg .
${COMPILER_DIR}/archgen2tablegen.py ${CUR_DIR}/hw/bfu_list.txt ${CUR_DIR}/hw/primate.cfg
cp ./primate-compiler-gen/IntrinsicsPrimate.td ${COMPILER_DIR}/llvm/include/llvm/IR/IntrinsicsPrimate.td
cp ./primate-compiler-gen/PrimateInstrInfo.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateInstrInfo.td
cp ./primate-compiler-gen/PrimateSchedPrimate.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
cp ./primate-compiler-gen/PrimateSchedule.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedule.td

# make compiler
ninja -C ${COMPILER_DIR}/build
# generate sidefiles required
${COMPILER_DIR}/build/bin/clang++ -I/lib/gcc/x86_64-linux-gnu/9/include/ -O3 -mllvm -debug --target=primate32-linux-gnu -march=pr32i -c ./${TARGET}.cpp -o primate_pgm.o 2> compiler.log
${COMPILER_DIR}/build/bin/llvm-objdump -dr primate_pgm.o > primate_pgm_text
${COMPILER_DIR}/build/bin/llvm-objdump -t primate_pgm.o > primate_pgm_sym
${COMPILER_DIR}/bin2asm.py ./primate_pgm_text ./primate_pgm_sym ./primate_pgm.bin
# $UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin

mv primate_pgm.bin $UARCH_DIR/chisel/Gorilla++/
cd $CUR_DIR/hw
cp $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
cp header.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu0.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu1.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu2.scala $CHISEL_SRC_DIR/main/scala/
cp cache.scala $CHISEL_SRC_DIR/main/scala/
cp hashUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inOutUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inputUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inputUnit_core.scala $CHISEL_SRC_DIR/main/scala/
cp match_table.scala $CHISEL_SRC_DIR/main/scala/
cp outputUnit_simple.scala $CHISEL_SRC_DIR/main/scala/
cp primate.scala $CHISEL_SRC_DIR/main/scala/
[[ -e *.v ]] && cp *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && cp *.sv $CHISEL_SRC_DIR/main/resources/
rm primate.template
rm primate.scala
cd $UARCH_DIR/templates
cp *.scala $CHISEL_SRC_DIR/main/scala/
cp *.v $CHISEL_SRC_DIR/main/resources/
cd $CUR_DIR
