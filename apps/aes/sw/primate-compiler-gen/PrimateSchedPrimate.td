//===- PrimateSchedPrimate.td - Primate Scheduling Defs ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===---------------------------------r------------------------------------===//

def ExtractUnit0a      : FuncUnit;
def ExtractUnit0b      : FuncUnit;
def GreenLSUUnit      : FuncUnit;
def InsertUnit0      : FuncUnit;

def ExtractUnit1a      : FuncUnit;
def ExtractUnit1b      : FuncUnit;
def GreenIOUnit      : FuncUnit;
def InsertUnit1      : FuncUnit;

def ExtractUnit2a      : FuncUnit;
def ExtractUnit2b      : FuncUnit;
def GreenUnit2      : FuncUnit;
def InsertUnit2      : FuncUnit;

def ExtractUnit3a      : FuncUnit;
def ExtractUnit3b      : FuncUnit;
def GreenUnit3      : FuncUnit;
def InsertUnit3      : FuncUnit;

def ExtractUnit4a      : FuncUnit;
def ExtractUnit4b      : FuncUnit;
def GreenUnit4      : FuncUnit;
def InsertUnit4      : FuncUnit;

def ExtractUnit5a      : FuncUnit;
def ExtractUnit5b      : FuncUnit;
def GreenUnit5      : FuncUnit;
def InsertUnit5      : FuncUnit;

def ExtractUnit6a      : FuncUnit;
def ExtractUnit6b      : FuncUnit;
def GreenUnit6      : FuncUnit;
def InsertUnit6      : FuncUnit;


def BranchUnit : FuncUnit;

def PrimateItinList {
  list<InstrItinData> ItinList = [
    InstrItinData<ItinExtract,       [InstrStage<1, [ExtractUnit0a,ExtractUnit0b,ExtractUnit1a,ExtractUnit1b,ExtractUnit2a,ExtractUnit2b,ExtractUnit3a,ExtractUnit3b,ExtractUnit4a,ExtractUnit4b,ExtractUnit5a,ExtractUnit5b,ExtractUnit6a,ExtractUnit6b]>]>,
    InstrItinData<ItinInsert,        [InstrStage<1, [InsertUnit0,InsertUnit1,InsertUnit2,InsertUnit3,InsertUnit4,InsertUnit5,InsertUnit6]>]>,
    InstrItinData<ItinGreen,         [InstrStage<1, [GreenLSUUnit,GreenIOUnit,GreenUnit2,GreenUnit3,GreenUnit4,GreenUnit5,GreenUnit6]>]>,
    
    InstrItinData<ItinIO,            [InstrStage<1, [GreenIOUnit]>]>,
    InstrItinData<ItinBranch,        [InstrStage<1, [BranchUnit]>]>,
    InstrItinData<ItinMem,           [InstrStage<1, [GreenLSUUnit]>]>
  ];
}

def PrimateItineraries :
    ProcessorItineraries<[  
        ExtractUnit0a,ExtractUnit0b,GreenLSUUnit,InsertUnit0,ExtractUnit1a,ExtractUnit1b,GreenIOUnit,InsertUnit1,ExtractUnit2a,ExtractUnit2b,GreenUnit2,InsertUnit2,ExtractUnit3a,ExtractUnit3b,GreenUnit3,InsertUnit3,ExtractUnit4a,ExtractUnit4b,GreenUnit4,InsertUnit4,ExtractUnit5a,ExtractUnit5b,GreenUnit5,InsertUnit5,ExtractUnit6a,ExtractUnit6b,GreenUnit6,InsertUnit6,
        BranchUnit
    ],
    [],
    PrimateItinList.ItinList>;

// Primate machine model for scheduling
def PrimateModel : SchedMachineModel {
  let MicroOpBufferSize = 0;
  let IssueWidth = 7;        // 2 micro-ops are dispatched per cycle.
  let Itineraries = PrimateItineraries;
  let LoadLatency = 3;
  let MispredictPenalty = 0;
  let CompleteModel = 1;
  let UnsupportedFeatures = [
    HasFullI,
    HasStdExtM,
    HasStdExtA,
    HasStdExtF,
    HasStdExtD,
    HasStdExtZfh,
    HasStdExtC,
    HasStdExtZba,
    HasStdExtZbb,
    HasStdExtZbc,
    HasStdExtZbs,
    HasPRCHints
  ];
}

let SchedModel = PrimateModel in {
let BufferSize = 0 in {
def ExtractUnit0aPipe         : ProcResource<1>;
def ExtractUnit0bPipe         : ProcResource<1>;
def GreenLSUUnitPipe         : ProcResource<1>;
def InsertUnit0Pipe         : ProcResource<1>;
def ExtractUnit1aPipe         : ProcResource<1>;
def ExtractUnit1bPipe         : ProcResource<1>;
def GreenIOUnitPipe         : ProcResource<1>;
def InsertUnit1Pipe         : ProcResource<1>;
def ExtractUnit2aPipe         : ProcResource<1>;
def ExtractUnit2bPipe         : ProcResource<1>;
def GreenUnit2Pipe         : ProcResource<1>;
def InsertUnit2Pipe         : ProcResource<1>;
def ExtractUnit3aPipe         : ProcResource<1>;
def ExtractUnit3bPipe         : ProcResource<1>;
def GreenUnit3Pipe         : ProcResource<1>;
def InsertUnit3Pipe         : ProcResource<1>;
def ExtractUnit4aPipe         : ProcResource<1>;
def ExtractUnit4bPipe         : ProcResource<1>;
def GreenUnit4Pipe         : ProcResource<1>;
def InsertUnit4Pipe         : ProcResource<1>;
def ExtractUnit5aPipe         : ProcResource<1>;
def ExtractUnit5bPipe         : ProcResource<1>;
def GreenUnit5Pipe         : ProcResource<1>;
def InsertUnit5Pipe         : ProcResource<1>;
def ExtractUnit6aPipe         : ProcResource<1>;
def ExtractUnit6bPipe         : ProcResource<1>;
def GreenUnit6Pipe         : ProcResource<1>;
def InsertUnit6Pipe         : ProcResource<1>;

def BranchPipe         : ProcResource<1>;
}

def PrimatePipes : ProcResGroup<[
  ExtractUnit0aPipe,ExtractUnit0bPipe,GreenLSUUnitPipe,InsertUnit0Pipe,ExtractUnit1aPipe,ExtractUnit1bPipe,GreenIOUnitPipe,InsertUnit1Pipe,ExtractUnit2aPipe,ExtractUnit2bPipe,GreenUnit2Pipe,InsertUnit2Pipe,ExtractUnit3aPipe,ExtractUnit3bPipe,GreenUnit3Pipe,InsertUnit3Pipe,ExtractUnit4aPipe,ExtractUnit4bPipe,GreenUnit4Pipe,InsertUnit4Pipe,ExtractUnit5aPipe,ExtractUnit5bPipe,GreenUnit5Pipe,InsertUnit5Pipe,ExtractUnit6aPipe,ExtractUnit6bPipe,GreenUnit6Pipe,InsertUnit6Pipe,
  BranchPipe
]>;
def GreenPipes : ProcResGroup<[GreenLSUUnitPipe,GreenIOUnitPipe,GreenUnit2Pipe,GreenUnit3Pipe,GreenUnit4Pipe,GreenUnit5Pipe,GreenUnit6Pipe]>;
def BluePipes : ProcResGroup<[]>;


// Branching
def : WriteRes<WriteJmp, [BranchPipe]>;
def : WriteRes<WriteJal, [BranchPipe]>;
def : WriteRes<WriteJalr, [BranchPipe]>;
def : WriteRes<WriteJmpReg, [BranchPipe]>;

// Integer arithmetic and logic
let Latency = 3 in {
def : WriteRes<WriteIALU, [GreenPipes]>;
def : WriteRes<WriteIALU32, [GreenPipes]>;
def : WriteRes<WriteShiftImm, [GreenPipes]>;
def : WriteRes<WriteShiftImm32, [GreenPipes]>;
def : WriteRes<WriteShiftReg, [GreenPipes]>;
def : WriteRes<WriteShiftReg32, [GreenPipes]>;
}

// Integer multiplication
let Latency = 3 in {
def : WriteRes<WriteIMul, [GreenPipes]>;
def : WriteRes<WriteIMul32, [GreenPipes]>;
}

// Integer division
def : WriteRes<WriteIDiv, [GreenPipes]> {
  let Latency = 16;
  let ReleaseAtCycles = [15];
}
def : WriteRes<WriteIDiv32,  [GreenPipes]> {
  let Latency = 16;
  let ReleaseAtCycles = [15];
}

let Latency = 1000 in {
// Memory
def : WriteRes<WriteSTB, [BluePipes]>;
def : WriteRes<WriteSTH, [BluePipes]>;
def : WriteRes<WriteSTW, [BluePipes]>;
def : WriteRes<WriteSTD, [BluePipes]>;
def : WriteRes<WriteFST32, [BluePipes]>;
def : WriteRes<WriteFST64, [BluePipes]>;

def : WriteRes<WriteLDB, [BluePipes]>;
def : WriteRes<WriteLDH, [BluePipes]>;
def : WriteRes<WriteLDW, [BluePipes]>;
def : WriteRes<WriteLDWU, [BluePipes]>;
def : WriteRes<WriteLDD, [BluePipes]>;

def : WriteRes<WriteFLD32, [BluePipes]>;
def : WriteRes<WriteFLD64, [BluePipes]>;

// Atomic memory
def : WriteRes<WriteAtomicSTW, [BluePipes]>;
def : WriteRes<WriteAtomicSTD, [BluePipes]>;

def : WriteRes<WriteAtomicW, [BluePipes]>;
def : WriteRes<WriteAtomicD, [BluePipes]>;
def : WriteRes<WriteAtomicLDW, [BluePipes]>;
def : WriteRes<WriteAtomicLDD, [BluePipes]>;
}

// Single precision.
let Latency = 5 in {
def : WriteRes<WriteFALU32, [GreenPipes]>;
def : WriteRes<WriteFMul32, [GreenPipes]>;
def : WriteRes<WriteFMA32, [GreenPipes]>;
}
let Latency = 3 in {
def : WriteRes<WriteFSGNJ32, [GreenPipes]>;
def : WriteRes<WriteFMinMax32, [GreenPipes]>;
}

def : WriteRes<WriteFDiv32, [GreenPipes]> {
  let Latency = 27;
  let ReleaseAtCycles = [26];
}
def : WriteRes<WriteFSqrt32, [GreenPipes]> {
  let Latency = 27;
  let ReleaseAtCycles = [26];
}

// Double precision
let Latency = 7 in {
def : WriteRes<WriteFALU64, [GreenPipes]>;
def : WriteRes<WriteFMul64, [GreenPipes]>;
def : WriteRes<WriteFMA64, [GreenPipes]>;
}
let Latency = 3 in {
def : WriteRes<WriteFSGNJ64, [GreenPipes]>;
def : WriteRes<WriteFMinMax64, [GreenPipes]>;
}

def : WriteRes<WriteFDiv64, [GreenPipes]> {
  let Latency = 56;
  let ReleaseAtCycles = [55];
}
def : WriteRes<WriteFSqrt64, [GreenPipes]> {
  let Latency = 56;
  let ReleaseAtCycles = [55];
}

// Conversions
let Latency = 3 in {
def : WriteRes<WriteFCvtI32ToF32, [GreenPipes]>;
def : WriteRes<WriteFCvtI32ToF64, [GreenPipes]>;
def : WriteRes<WriteFCvtI64ToF32, [GreenPipes]>;
def : WriteRes<WriteFCvtI64ToF64, [GreenPipes]>;
def : WriteRes<WriteFCvtF32ToI32, [GreenPipes]>;
def : WriteRes<WriteFCvtF32ToI64, [GreenPipes]>;
def : WriteRes<WriteFCvtF32ToF64, [GreenPipes]>;
def : WriteRes<WriteFCvtF64ToI32, [GreenPipes]>;
def : WriteRes<WriteFCvtF64ToI64, [GreenPipes]>;
def : WriteRes<WriteFCvtF64ToF32, [GreenPipes]>;

def : WriteRes<WriteFClass32, [GreenPipes]>;
def : WriteRes<WriteFClass64, [GreenPipes]>;
def : WriteRes<WriteFCmp32, [GreenPipes]>;
def : WriteRes<WriteFCmp64, [GreenPipes]>;
def : WriteRes<WriteFMovI32ToF32, [GreenPipes]>;
def : WriteRes<WriteFMovF32ToI32, [GreenPipes]>;
def : WriteRes<WriteFMovI64ToF64, [GreenPipes]>;
def : WriteRes<WriteFMovF64ToI64, [GreenPipes]>;
}

// Others
def : WriteRes<WriteCSR, [GreenPipes]>;
def : WriteRes<WriteNop, []>;

def : InstRW<[WriteIALU], (instrs COPY)>;

// Bypass and advance
def : ReadAdvance<ReadJmp, 0>;
def : ReadAdvance<ReadJalr, 0>;
def : ReadAdvance<ReadCSR, 0>;
def : ReadAdvance<ReadStoreData, 0>;
def : ReadAdvance<ReadMemBase, 0>;
def : ReadAdvance<ReadIALU, 0>;
def : ReadAdvance<ReadIALU32, 0>;
def : ReadAdvance<ReadShiftImm, 0>;
def : ReadAdvance<ReadShiftImm32, 0>;
def : ReadAdvance<ReadShiftReg, 0>;
def : ReadAdvance<ReadShiftReg32, 0>;
def : ReadAdvance<ReadIDiv, 0>;
def : ReadAdvance<ReadIDiv32, 0>;
def : ReadAdvance<ReadIMul, 0>;
def : ReadAdvance<ReadIMul32, 0>;
def : ReadAdvance<ReadAtomicWA, 0>;
def : ReadAdvance<ReadAtomicWD, 0>;
def : ReadAdvance<ReadAtomicDA, 0>;
def : ReadAdvance<ReadAtomicDD, 0>;
def : ReadAdvance<ReadAtomicLDW, 0>;
def : ReadAdvance<ReadAtomicLDD, 0>;
def : ReadAdvance<ReadAtomicSTW, 0>;
def : ReadAdvance<ReadAtomicSTD, 0>;
def : ReadAdvance<ReadFMemBase, 0>;
def : ReadAdvance<ReadFALU32, 0>;
def : ReadAdvance<ReadFALU64, 0>;
def : ReadAdvance<ReadFAdd64, 0>;
def : ReadAdvance<ReadFAdd32, 0>;
def : ReadAdvance<ReadFAdd16, 0>;
def : ReadAdvance<ReadFMul32, 0>;
def : ReadAdvance<ReadFMA32, 0>;
def : ReadAdvance<ReadFMA32Addend, 0>;
def : ReadAdvance<ReadFStoreData, 0>;
def : ReadAdvance<ReadFMul64, 0>;
def : ReadAdvance<ReadFMA64, 0>;
def : ReadAdvance<ReadFMA64Addend, 0>;
def : ReadAdvance<ReadFDiv32, 0>;
def : ReadAdvance<ReadFDiv64, 0>;
def : ReadAdvance<ReadFSqrt32, 0>;
def : ReadAdvance<ReadFSqrt64, 0>;
def : ReadAdvance<ReadFCmp32, 0>;
def : ReadAdvance<ReadFCmp64, 0>;
def : ReadAdvance<ReadFSGNJ32, 0>;
def : ReadAdvance<ReadFSGNJ64, 0>;
def : ReadAdvance<ReadFMinMax32, 0>;
def : ReadAdvance<ReadFMinMax64, 0>;
def : ReadAdvance<ReadFCvtF32ToI32, 0>;
def : ReadAdvance<ReadFCvtF32ToI64, 0>;
def : ReadAdvance<ReadFCvtF64ToI32, 0>;
def : ReadAdvance<ReadFCvtF64ToI64, 0>;
def : ReadAdvance<ReadFCvtI32ToF32, 0>;
def : ReadAdvance<ReadFCvtI32ToF64, 0>;
def : ReadAdvance<ReadFCvtI64ToF32, 0>;
def : ReadAdvance<ReadFCvtI64ToF64, 0>;
def : ReadAdvance<ReadFCvtF32ToF64, 0>;
def : ReadAdvance<ReadFCvtF64ToF32, 0>;
def : ReadAdvance<ReadFMovF32ToI32, 0>;
def : ReadAdvance<ReadFMovI32ToF32, 0>;
def : ReadAdvance<ReadFMovF64ToI64, 0>;
def : ReadAdvance<ReadFMovI64ToF64, 0>;
def : ReadAdvance<ReadFClass32, 0>;
def : ReadAdvance<ReadFClass64, 0>;

// Unsupported extensions
defm : UnsupportedSchedV;
defm : UnsupportedSchedZba;
defm : UnsupportedSchedZbb;
defm : UnsupportedSchedZfh;
}

