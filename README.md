# Gorilla++ is a tool for generating streaming hardware accelerators.
# Assemble Primate program
Machine code will be generated into a file specified, e.g., flow\_reassembly\_tail.txt
```bash
cd <project home>/assembler
make
./primate_assembler flow_reassembly_tail.s flow_reassembly_tail.txt
```
# Generate source files
## Generate sources
```bash
cd <project home>/compiler/engineCompiler/multiThread
make
cd <project home>/apps/pktReassembly/build
make
```
Ignore the errors.
## Recover Primate Overlay
```bash
cd <project home>/chisel/Gorilla++/src/main/scala/
git checkout .
```
## Copy the machine code to Primate Overlay source file
Currently we manually initialize the Primate instruction buffer with the generated machine code. 
Copy the data generated in flow\_reassembly\_tail.txt and paste it into the "VecInit" statement in "Fetch" module, pktReassembly.scala.
# Simulate with Verilator
A waveform file, `<Top.vcd>`, will be generated at `<<project home>/chisel/Gorilla++/test_run_dir/TopMainxxxx>/`. Use any waveform viewer to open the file, e.g., gtkwave Top.vcd
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
