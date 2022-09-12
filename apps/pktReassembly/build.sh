#!/bin/bash

TARGET=pkt_reassembly_tail
PRIMATE_DIR=/home/marui/crossroad/rv2
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
CHISEL_SRC_DIR=$PRIMATE_DIR/primate/chisel/Gorilla++/src
CUR_DIR=$(pwd)
cd $PRIMATE_DIR/primate/compiler/engineCompiler/multiThread/
make clean && make
cd $PRIMATE_DIR/primate/apps/common/build/
make clean && make
cd $CUR_DIR/sw
$LLVM_DIR/build/bin/clang -emit-llvm -S -O3 "${TARGET}.cpp"
$LLVM_DIR/build/bin/opt -enable-new-pm=0 -load $LLVM_DIR/build/lib/LLVMPrimate.so -primate < "${TARGET}.ll" > /dev/null
mv primate.cfg $CHISEL_SRC_DIR/main/scala/
mv header.scala $CHISEL_SRC_DIR/main/scala/
cp input.txt $PRIMATE_DIR/primate/chisel/Gorilla++/
mv primate_assembler.h $PRIMATE_DIR/primate/apps/scripts/
cd $PRIMATE_DIR/primate/apps/scripts/
make clean && make
cd $CUR_DIR/sw
$PRIMATE_DIR/primate/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin
mv primate_pgm.bin $PRIMATE_DIR/primate/chisel/Gorilla++/
cd $CUR_DIR/hw
cp $PRIMATE_DIR/primate/templates/primate.template ./
python3 $PRIMATE_DIR/primate/apps/scripts/scm.py
cp *.scala $CHISEL_SRC_DIR/main/scala/
[[ -e *.v ]] && cp *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && cp *.sv $CHISEL_SRC_DIR/main/resources/
rm primate.template
rm primate.scala
cd $PRIMATE_DIR/primate/templates
cp *.scala $CHISEL_SRC_DIR/main/scala/
cp *.v $CHISEL_SRC_DIR/main/resources/
cd $CUR_DIR
