// if this actually routes.......

// many-port regfile for primate
// need 2 sets of ports for each VLIW pipeline
// each port set can contain an arbitrary number of registers
// each set must be contiguous
// register encoding specifies the lowest register number in the set
// set size is based on BFU specification (static on a VLIW slot basis)

class RegFile(conf: PrimateConfig) extends Module {
    // TODO: read chisel docs for parameterized 

    // Dont need Register 0
}
