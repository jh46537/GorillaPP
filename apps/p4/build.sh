#!/bin/bash

TARGET=parse/p4_parse
CUR_DIR=$(pwd)
cd ../../../
PRIMATE_DIR=$(pwd)
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=$UARCH_DIR/chisel/Gorilla++/src
cd $UARCH_DIR/compiler/engineCompiler/multiThread/
make clean && make
cd $UARCH_DIR/apps/common/build/
make clean && make
cd $CUR_DIR/sw
$LLVM_DIR/build/bin/clang -emit-llvm -S -O3 "${TARGET}.cpp" -o "${TARGET}.ll"
$LLVM_DIR/build/bin/opt -enable-new-pm=0 -load $LLVM_DIR/build/lib/LLVMPrimate.so -primate < "${TARGET}.ll" > /dev/null
cp primate.cfg $CUR_DIR/hw
mv primate.cfg $CHISEL_SRC_DIR/main/scala/
cp input.txt $UARCH_DIR/chisel/Gorilla++/
mv primate_assembler.h $UARCH_DIR/apps/scripts/
cd $UARCH_DIR/apps/scripts/
make clean && make
cd $CUR_DIR/sw
$UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin
mv primate_pgm.bin $UARCH_DIR/chisel/Gorilla++/
cd $CUR_DIR/hw
cp $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
cp header.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu0.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu1.scala $CHISEL_SRC_DIR/main/scala/
cp cache.scala $CHISEL_SRC_DIR/main/scala/
cp hashUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inOutUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inputUnit_spec.scala $CHISEL_SRC_DIR/main/scala/
cp match_table.scala $CHISEL_SRC_DIR/main/scala/
cp outputUnit_spec.scala $CHISEL_SRC_DIR/main/scala/
cp primate.scala $CHISEL_SRC_DIR/main/scala/
[[ -e *.v ]] && cp *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && cp *.sv $CHISEL_SRC_DIR/main/resources/
rm primate.template
rm primate.scala
rm primate.cfg
cd $UARCH_DIR/templates
cp *.scala $CHISEL_SRC_DIR/main/scala/
cp *.v $CHISEL_SRC_DIR/main/resources/
cd $CUR_DIR
