import chisel3._
import chisel3.util._


class MSPMEntry(patternWidth:Int) extends Bundle {
    val entry = Vec(patternWidth, UInt(8.W))
    val valid = Vec(patternWidth, Bool())
    val length = UInt((log2Up(patternWidth)).W)
    override def cloneType = (new MSPMEntry(patternWidth).asInstanceOf[this.type])
}

class MSPMcore(patternWidth:Int, numPatterns:Int) extends Module {
    val io = IO(new Bundle {
        val command = Input(UInt(5.W)) // width?
        val string  = Input(Vec(patternWidth, UInt(8.W)))
        val length  = Input(UInt(log2Up(patternWidth).W))
        val idx     = Input(UInt(log2Up(numPatterns).W))
        val ready   = Output(Bool())
        val valid   = Input(Bool())
        val matched = Output(Vec(numPatterns, Bool()))
        val pos     = Output(Vec(numPatterns, UInt(log2Up(patternWidth).W)))
    })

    val resetOp::loadOp::matchOp::Nil = Enum(3)
    //val mask = RegInit(0.U(patternWidth*numPatterns))
    val patternBuffer = Reg(Vec(numPatterns, new MSPMEntry(patternWidth)))
    //val matchBuffer = Reg(Vec(numPatterns, Bool())) // stores bits of matched entries (the M of MSPM)
    
    // Shift-or state
    //val stateSTmask = VecInit.fill(numPatterns, 2*patternWidth)(0.U)
    //val stateSHmask = VecInit.fill(numPatterns, patternWidth, patternWidth)(0.U)
    //val stateSTmask = RegInit(VecInit.fill(numPatterns, 2*patternWidth)(0.U))
    //val stateSHmask = RegInit(VecInit.fill(numPatterns, patternWidth, patternWidth)(1.U))
    val stateSTmask = RegInit(VecInit(Seq.fill(numPatterns)(VecInit(Seq.fill(patternWidth)(0.U)))))
    val stateSHmask = RegInit(VecInit(Seq.fill(numPatterns)(VecInit(Seq.fill(patternWidth)(VecInit(Seq.fill(patternWidth)(1.U)))))))

    val matchOut = Wire(Vec(numPatterns, Bool()))
    val posOut = Wire(Vec(numPatterns, UInt(log2Up(patternWidth).W)))
    // Default outputs
    io.ready := true.B
    io.matched := matchOut
    io.pos := posOut

    when (io.valid) {
        // for(i <- 0 to numPatterns-1) {
        //     printf("Entry %d = ", i.U)
        //     for(j <- 0 to patternWidth-1) {
        //         printf("%c", patternBuffer(i).entry(j))
        //     }
        //     printf("\t")
        //     for(j <- 0 to patternWidth-1) {
        //         printf("%b", patternBuffer(i).valid(j))
        //     }
        //     printf("\n")
        // }
        // for(i <- 0 to numPatterns-1) {
        //     printf("Pattern %d:\n", i.U)
        //     for(j <- 0 to patternWidth-1) {
        //         for(k <- 0 to patternWidth-1) {
        //             printf("%b ", stateSHmask(i)(j)(k))
        //         }
        //         printf("\n")
        //     }
        //     printf("\n\n")
        // }
        // for(i <- 0 to numPatterns-1) {
        //     printf("Entry %d = ", i.U)
        //     for(j <- 0 to patternWidth-1) {
        //         printf("%b ", stateSTmask(i)(j))
        //     }
        //     printf("\n")
        // }
        switch(io.command) {
            is (resetOp) {
                //mask := 0.U
                for (i <- 0 to numPatterns - 1) {
                    for (j <- 0 to patternWidth - 1) {
                        patternBuffer(i).valid(j) := false.B
                    }
                    //matchBuffer(i) := false.B
                }
                for (i <- 0 to numPatterns - 1) {
                    for (j <- 0 to patternWidth - 1) {
                        stateSTmask(i)(j) := 0.U
                    }
                }
                for (i <- 0 to numPatterns - 1) {
                    for (j <- 0 to patternWidth - 1) {
                          for (k <- 0 to patternWidth - 1) {
                              stateSHmask(i)(j)(k) := 1.U
                          }
                    }
                }
            }
            is (loadOp) { // Compute mask table values
                // Load into the patternBuffer
                //patternBuffer(io.idx).valid := ~(Fill(patternWidth, 1.U) << (io.length))
                //patternBuffer(io.idx).entry.fill(patternWidth)((i: Int) => io.string(i))
                //patternBuffer(io.idx).valid.fill(patternWidth)((i: Int) => i.U < io.length)
                patternBuffer(io.idx).entry := io.string
                patternBuffer(io.idx).valid := Seq.tabulate(patternWidth)(i => i.U < io.length)
                patternBuffer(io.idx).length := io.length
                // stateSTmask(io.idx) := Fill(2*patternWidth, 1.U)
                // // fill lower bits of STmask
                // for (j <- 0 to (numPatterns - 1)) {
                //     stateSTmask(j) := Fill(2*patternWidth, 1.U)
                // }
            }
            is (matchOp) { // check input string against pattern 
                //for (j <- 0 to numPatterns-1) {
                //    matchBuffer(j) := patternBuffer(j).entry === io.string
                //}
                // printf("here\n")
                for (i <- 0 to numPatterns - 1) {
                    for (j <- 0 to patternWidth - 1) { //pattern loop
                        val byte_valid = patternBuffer(i).valid(j)
                        val byte_entry = patternBuffer(i).entry(j)
                        val byte_len = patternBuffer(i).length
                        for (k <- 0 to patternWidth - 1) { //word loop
                            when (byte_valid) {
                                when (byte_entry === io.string(k)) { //removed io.length condition (k.U < io.length)
                                    stateSHmask(i)(j)(k) := 0.U
                                }.otherwise{
                                    stateSHmask(i)(j)(k) := 1.U
                                }
                            }.otherwise {
                                stateSHmask(i)(j)(k) := 0.U
                            }
                        }
                    }
                }
                for (i <- 0 to numPatterns - 1) {
                    val orChain = Wire(Vec(patternWidth, Vec(patternWidth, UInt(1.W))))
                    for (j <- 0 to patternWidth - 1) { //pattern idx loop
                        for (k <- 0 to patternWidth - 1) { //string idx loop
                            if (k == 0 || j == 0)
                                orChain(j)(k) := stateSHmask(i)(j)(k)
                            else{
                                orChain(j)(k) := stateSHmask(i)(j)(k) | orChain(j-1)(k-1)
                            }
                        }
                    }
                    for (j <- 0 to patternWidth - 1) {
                        stateSTmask(i)(j) := orChain(j)(patternWidth - 1)
                    }
                }
            }
        }
    }

    for(i <- 0 to numPatterns - 1) {
        matchOut(i) := false.B
    }

    for(i <- 0 to numPatterns - 1) {
        posOut(i) := 0.U
    }

    // Combinational logic for matching
    for (i <- 0 to numPatterns - 1) {
        for (j <- patternWidth - 1 to 0 by -1) { //find the earliest match - equivalent sematnics to early return
            when (stateSTmask(i)(j) === 0.U) {
                matchOut(i) := true.B
                posOut(i) := patternWidth.U - j.U - 1.U
                // picked := 1.U
            }
        }
    }
}
