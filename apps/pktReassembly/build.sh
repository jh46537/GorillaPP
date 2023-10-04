#!/bin/bash

#High Level Description 
# This script prepares the scala and binary files for future simulation based on the 
# hw/sw files in the application and template folders

#TODO:
# Modify Script when compiler is complete, as currently the comiler is not responsible for 
# generating the application code

#Create variables for the diffrent parts of the repository
# TARGET         -> Basename of cpp file in sw folder
# CUR_DIR        -> Current Directory (Application directory)
# PRIMATE_DIR    -> Top level Folder containing both uarch and arch gen
# LLVM_DIR       -> primate-arch-gen folder containing the compiler
# UARCH_DIR      -> primate-uarch folder containing the primate template files and build tools
# CHISEL_SRC_DIR -> Input directory for the Gorilla++ Tool
TARGET=pkt_reassembly_tail
CUR_DIR=$(pwd)
cd ../../../
PRIMATE_DIR=$(pwd)
LLVM_DIR=$PRIMATE_DIR/primate-arch-gen
UARCH_DIR=$PRIMATE_DIR/primate-uarch
CHISEL_SRC_DIR=$UARCH_DIR/chisel/Gorilla++/src

# Handle building the multi-threaded compiler for the dependency chain of
# multiThread Compiler -> Gorilla++ -> Primate 
cd $UARCH_DIR/compiler/engineCompiler/multiThread/
make clean && make

# Handle building the top compiler for the dependency chain of
# topCompiler -> Gorilla++ -> Primate 
cd $UARCH_DIR/apps/common/build/
make clean && make

# Compile the application code to low level IR
# Use this IR to do some analysis to create configuration files for the assembler and hw interconect
cd $CUR_DIR/sw
$LLVM_DIR/build/bin/clang -emit-llvm -S -O3 "${TARGET}.cpp"
$LLVM_DIR/build/bin/opt -enable-new-pm=0 -load $LLVM_DIR/build/lib/LLVMPrimate.so -primate < "${TARGET}.ll" > /dev/null

# Move the newly generated files into the relevant directories for the Gorilla++ tool, 
# Also move the interconnect config to be with the HW filesm and the assembler header
# to be with the assembler code, so we can re-compile the assembler witht the correct settings
mv primate.cfg $CHISEL_SRC_DIR/main/scala/
mv header.scala $CHISEL_SRC_DIR/main/scala/
cp input.txt $UARCH_DIR/chisel/Gorilla++/
cp memInit.txt $UARCH_DIR/chisel/Gorilla++/
mv interconnect.cfg $CUR_DIR/hw
mv primate_assembler.h $UARCH_DIR/apps/scripts/

# Using the newly created primate_assembler.h header file, recompile the assembler
cd $UARCH_DIR/apps/scripts/
make clean && make

# Using the newly compiled assembler, convert the IR into a binary file for the Primate processor
# Then move this binary executeable to the Gorilla++ tool
cd $CUR_DIR/sw
$UARCH_DIR/apps/scripts/primate_assembler "${TARGET}.s" primate_pgm.bin
mv primate_pgm.bin $UARCH_DIR/chisel/Gorilla++/

# Pull in the templated files to the hw directory, then use scm.py in order to do 
# Scala Code Modification to insert the BFUs into the primate template. 
# Then copy the resulting Scala file into the Gorilla++ tool 
cd $CUR_DIR/hw
cp $UARCH_DIR/templates/primate.template ./
python3 $UARCH_DIR/apps/scripts/scm.py
cp *.scala $CHISEL_SRC_DIR/main/scala/

# If any Verilog/System verilog files exist in the hardware folder, 
# then we copy them into the resources folder 
[[ -e *.v ]] && cp *.v $CHISEL_SRC_DIR/main/resources/
[[ -e *.sv ]] && cp *.sv $CHISEL_SRC_DIR/main/resources/

#Remove the temporary files from the hardware folder, from running scm.py
rm primate.template
rm primate.scala

# From the folder that contains all template files
# Copy any core primate scala source files into Gorila++
# Copy any core primate verilog files into Gorila++
cd $UARCH_DIR/templates
cp *.scala $CHISEL_SRC_DIR/main/scala/
cp *.v $CHISEL_SRC_DIR/main/resources/

#Return to the original directory
cd $CUR_DIR
