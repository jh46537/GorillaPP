#!/bin/bash

## NOTES:
# could this be converted to a makefile????
# would allow building just hardware or just compiler
# compiling the app should be a separate step from geneating the hardware and generating the compiler¿

# ================================================
# =          Set Up Some Useful Variables        =
# ================================================
set -o xtrace
set -e

PRIMATE_DIR=/primate
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
COMPILER_DIR=$PRIMATE_DIR/primate-compiler
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=$UARCH_DIR/chisel/src
BUILD_DIR=$UARCH_DIR/build

# directory in /primate-uarch/sw that contains the code to build against
# final compiled app will take the name of $TARGET
TARGET=aes
APP_DIR=$UARCH_DIR/sw/$TARGET

##### Hack alert. This just copies some files into their home
##### I could just find those files but time.
## TODO: move common to HW probably
#cd $UARCH_DIR/sw/common/build/
#make clean && make || true


# generate build directory to contain all artifacts
mkdir -p $BUILD_DIR

# ================================================
# =   Run Arch-gen to get primate parameters     =
# ================================================

cd $BUILD_DIR
mkdir -p ./primate-compiler-gen

oldPrimateArchGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)
${COMPILER_DIR}/archgen2tablegen.py -b ${APP_DIR}/bfu_list.txt --FrontendOnly -p ${APP_DIR}/primate.cfg # generate frontend td files
newPrimateArchGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)

# this is kinda hacky
if [ "${newPrimateArchGenHash}" != "${oldPrimateArchGenHash}" ]; then
    echo "Tablegen files have changed. Updating the compiler."
    cp ./primate-compiler-gen/IntrinsicsPrimateBFU.td ${COMPILER_DIR}/llvm/include/llvm/IR/IntrinsicsPrimateBFU.td
    cp ./primate-compiler-gen/PrimateInstrInfoBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateInstrInfoBFU.td
    cp ./primate-compiler-gen/PrimateScheduleBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateScheduleBFU.td
    
    cp ./primate-compiler-gen/BuiltinsPrimate.def ${COMPILER_DIR}/clang/include/clang/Basic/BuiltinsPrimate.def
    cp ./primate-compiler-gen/primate_bfu.td ${COMPILER_DIR}/clang/include/clang/Basic/primate_bfu.td

    cp ./primate-compiler-gen/PrimateSchedPrimate.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
else 
    echo "Tablegen files have not changed." 
fi

# What is this section doing? pls document
# if not necessary to generate hardware, move it to a new section

ninja -C ${COMPILER_DIR}/build
${COMPILER_DIR}/build/bin/clang++ -emit-llvm -S -mllvm -print-after-all --target=primate32-linux-gnu -march=pr32i -O3 -mllvm -debug "${TARGET}.cpp" -o "${TARGET}.ll" 2> frontend.log
# crash on destruct. || true is just to keep moving.
${COMPILER_DIR}/build/bin/opt -debug -passes=primate-arch-gen -debug < "${TARGET}.ll" > /dev/null 2> arch-gen.log || true

#mv *.scala $CUR_DIR/hw
#cp primate.cfg $CUR_DIR/hw
#mv primate.cfg $CHISEL_SRC_DIR/main/scala/
#cp input.txt $UARCH_DIR/chisel/Gorilla++/
#mv primate_assembler.h $UARCH_DIR/apps/scripts/
#cd $UARCH_DIR/apps/scripts/
#make clean && make
#cd $CUR_DIR/sw

echo "done with archgen..."

exit

# ================================================
# =       Generate Primate Compiler              =
# ================================================

mkdir -p ./primate-compiler-gen
touch ./primate-compiler-gen/IntrinsicsPrimateBFU.td
touch ./primate-compiler-gen/PrimateInstrInfoBFU.td
touch ./primate-compiler-gen/PrimateSchedPrimate.td
touch ./primate-compiler-gen/PrimateScheduleBFU.td
touch ./primate-compiler-gen/PrimateRegisterDefs.td
touch ./primate-compiler-gen/PrimateRegisterOrdering.td
touch ./primate-compiler-gen/PrimateInstrReconfigFormats.td
touch ./primate-compiler-gen/PrimateInstrReconfigF.td

cp ${CUR_DIR}/hw/primate.cfg .
cp ${CUR_DIR}/hw/bfu_list.txt .

oldPrimateCompilerGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)

${COMPILER_DIR}/archgen2tablegen.py -b ${CUR_DIR}/hw/bfu_list.txt -p ${CUR_DIR}/hw/primate.cfg

newPrimateCompilerGenHash=$(sha1sum ./primate-compiler-gen/* | sha1sum)

if [ "${oldPrimateCompilerGenHash}" != "${newPrimateCompilerGenHash}" ]; then
    echo "Tablegen files have changed. Please update the compiler."
    cp ./primate-compiler-gen/IntrinsicsPrimateBFU.td ${COMPILER_DIR}/llvm/include/llvm/IR/IntrinsicsPrimateBFU.td
    cp ./primate-compiler-gen/PrimateInstrInfoBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateInstrInfoBFU.td
    cp ./primate-compiler-gen/PrimateSchedPrimate.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateSchedPrimate.td
    cp ./primate-compiler-gen/PrimateScheduleBFU.td ${COMPILER_DIR}/llvm/lib/Target/Primate/PrimateScheduleBFU.td    

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
${COMPILER_DIR}/build/bin/clang++ -O3 -mllvm -align-all-blocks=0 -mllvm -print-after-all -mllvm -debug --target=primate32-linux-gnu -march=pr32i -fno-pic -c ./${TARGET}.cpp -o primate_pgm.o 2> compiler.log
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -dr primate_pgm.o > primate_pgm_text
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -t primate_pgm.o > primate_pgm_sym
${COMPILER_DIR}/build/bin/llvm-objdump --triple=primate32-unknown-linux -s -j .rodata primate_pgm.o > primate_rodata
${COMPILER_DIR}/bin2asm.py ./primate_pgm_text ./primate_pgm_sym ${CUR_DIR}/hw/primate.cfg ./primate_pgm.bin
${COMPILER_DIR}/elf2meminit.py ./primate_rodata ./memInit.txt
# $UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin

mv primate_pgm.bin $UARCH_DIR/chisel/Gorilla++/



# TODO: move HW generation to separate flow????
# ================================================
# =       Create Primate.scala From Template     =
# ================================================

cd $CUR_DIR/hw
cp ../sw/memInit.txt $CHISEL_SRC_DIR/..
cp $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
cp header.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu0.scala $CHISEL_SRC_DIR/main/scala/
cp alu_bfu1.scala $CHISEL_SRC_DIR/main/scala/
cp cache.scala $CHISEL_SRC_DIR/main/scala/
cp inOutUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inputUnit.scala $CHISEL_SRC_DIR/main/scala/
cp inputUnit_core.scala $CHISEL_SRC_DIR/main/scala/
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
