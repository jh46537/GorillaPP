#!/bin/bash

# ================================================
# =          Set Up Some Useful Variables        =
# ================================================
set -o xtrace
set -e

TARGET=parse/p4_parse_sw
CUR_DIR=$(pwd)
cd ../../../
PRIMATE_DIR=$(pwd)
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
COMPILER_DIR=$PRIMATE_DIR/primate-compiler
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=$UARCH_DIR/chisel/Gorilla++/src

##### Hack alert. This just copies some files into their home
##### I could just find those files but time.
cd $UARCH_DIR/compiler/engineCompiler/multiThread/
make clean && make || true
cd $UARCH_DIR/apps/common/build/
make clean && make || true

# ================================================
# =   Run Arch-gen to get primate parameters     =
# ================================================
# 

cd $CUR_DIR/sw
ninja -C $LLVM_DIR/build
$LLVM_DIR/build/bin/clang -emit-llvm -S --target=riscv32-linux-gnu -march=rv32i -O3 "${TARGET}.cpp" -o "${TARGET}.ll"
$LLVM_DIR/build/bin/opt -enable-new-pm=0 -load $LLVM_DIR/build/lib/LLVMPrimate.so -debug -primate < "${TARGET}.ll" >arch-gen.log 2>&1
cp primate.cfg $CUR_DIR/hw
mv primate.cfg $CHISEL_SRC_DIR/main/scala/
cp input.txt $UARCH_DIR/chisel/Gorilla++/
mv primate_assembler.h $UARCH_DIR/apps/scripts/
cd $UARCH_DIR/apps/scripts/
make clean && make
cd $CUR_DIR/sw


echo "done with archgen..."

# ================================================
# =       Generate Primate Compiler              =
# ================================================

mkdir -p ./primate-compiler-gen
touch ./primate-compiler-gen/IntrinsicsPrimate.td
touch ./primate-compiler-gen/PrimateInstrInfo.td
touch ./primate-compiler-gen/PrimateSchedPrimate.td
touch ./primate-compiler-gen/PrimateSchedule.td

cp ${CUR_DIR}/hw/primate.cfg .
cp ${CUR_DIR}/hw/bfu_list.txt .

oldIntrinsicsHash=$(sha1sum ./primate-compiler-gen/IntrinsicsPrimate.td)
oldInstrInfoHash=$(sha1sum ./primate-compiler-gen/PrimateInstrInfo.td)
oldSchedPrimateHash=$(sha1sum ./primate-compiler-gen/PrimateSchedPrimate.td)
oldScheduleHash=$(sha1sum ./primate-compiler-gen/PrimateSchedule.td)

${COMPILER_DIR}/archgen2tablegen.py ${CUR_DIR}/hw/bfu_list.txt ${CUR_DIR}/hw/primate.cfg

newIntrinsicsHash=$(sha1sum ./primate-compiler-gen/IntrinsicsPrimate.td)
newInstrInfoHash=$(sha1sum ./primate-compiler-gen/PrimateInstrInfo.td)
newSchedPrimateHash=$(sha1sum ./primate-compiler-gen/PrimateSchedPrimate.td)
newScheduleHash=$(sha1sum ./primate-compiler-gen/PrimateSchedule.td)

if [ "${oldInstrInfoHash}" != "${newInstrInfoHash}" -o "${oldScheduleHash}" != "${newScheduleHash}" -o "${oldIntrinsicsHash}" != "${newIntrinsicsHash}" -o "${oldSchedPrimateHash}" != "${newSchedPrimateHash}" ]; then
    echo "Tablegen files have changed. Please update the compiler."
    cp ./primate-compiler-gen/IntrinsicsPrimate.td ${COMPILER_DIR}/llvm/include/llvm/IR/IntrinsicsPrimate.td
    cp ./primate-compiler-gen/PrimateInstrInfo.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateInstrInfo.td
    cp ./primate-compiler-gen/PrimateSchedPrimate.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
    cp ./primate-compiler-gen/PrimateSchedule.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedule.td
else 
    echo "Tablegen files have not changed." 
fi

# make compiler
ninja -C ${COMPILER_DIR}/build
# generate side files required
${COMPILER_DIR}/build/bin/clang++ -O3  -mllvm -print-after-all -mllvm -debug --target=primate32-linux-gnu -march=pr32i -c ./${TARGET}.cpp -o primate_pgm.o 2> compiler.log
${COMPILER_DIR}/build/bin/llvm-objdump -dr primate_pgm.o > primate_pgm_text
${COMPILER_DIR}/build/bin/llvm-objdump -t primate_pgm.o > primate_pgm_sym
${COMPILER_DIR}/bin2asm.py ./primate_pgm_text ./primate_pgm_sym ${CUR_DIR}/hw/primate.cfg ./primate_pgm.bin
cp ./primate_pgm.bin ${CHISEL_SRC_DIR}/..

# $UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin

echo "Done primate program built"

# ================================================
# =       Create Primate.scala From Template     =
# ================================================
cd $CUR_DIR/hw
cp $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
cp ${UARCH_DIR}/apps/lib/*.scala $CHISEL_SRC_DIR/main/scala/
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
cp outputUnit.scala $CHISEL_SRC_DIR/main/scala/
cp outputUnit_core.scala $CHISEL_SRC_DIR/main/scala/
cp primate.scala $CHISEL_SRC_DIR/main/scala/
[[ -e *.v ]] && cp *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && cp *.sv $CHISEL_SRC_DIR/main/resources/
rm primate.template
rm primate.scala
cd $UARCH_DIR/templates
cp *.scala $CHISEL_SRC_DIR/main/scala/
cp *.v $CHISEL_SRC_DIR/main/resources/
cd $CUR_DIR
