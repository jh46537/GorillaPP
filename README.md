# Gorilla++ is a tool for generating streaming hardware accelerators.
# Assemble Primate program
Machine code will be generated into a file specified, e.g., npu.txt
```bash
cd <project home>/assembler
make
./primate_assembler npu.s npu.txt
```
# Generate source files
## Backup Primate Overlay
```bash
cd <project home>/chisel/src/main/scala/
cp multiProtocolEngine.scala multiPtotocolEngine.scala.bak
```
## Generate sources
```bash
cd <project home>/apps/multiProtocolNpu/build
make
```
## Recover Primate Overlay
```bash
cd <project home>/chisel/src/main/scala/
mv multiProtocolEngine.scala.bak multiPtotocolEngine.scala
```
# Simulate with FIRRTL Interpreter
A waveform file, `<Top.vcd>`, will be generated at `<<project home>/chisel/Gorilla++/test_run_dir/TopSpecxxxx>/`
```bash
cd <project home>/chisel/Gorilla++/emulator
make -B
```
# Simulate with Verilator
A waveform file, `<Top.vcd>`, will be generated at `<<project home>/chisel/Gorilla++/test_run_dir/TopMainxxxx>/`
```bash
cd <project home>/chisel/Gorilla++/emulator
make verilator
```
# Generate Verilog file
`<Top.v>` will be generated at `<<project home>/chisel/Gorilla++/>` 
```bash
cd <project home>/chisel/Gorilla++/emulator
make verilog
```