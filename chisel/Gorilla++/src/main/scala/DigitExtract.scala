import chisel3._
import chisel3.util._


class IsDigit(segmentLength:Int) extends Module {
    val io = IO(new Bundle {
        val segment = Input(Vec(segmentLength, UInt(8.W)))
        val valid = Input(Bool())
        val ready = Output(Bool())
        val isDigit = Output(Bool())
        val digitPos = Output(UInt(log2Up(segmentLength).W))
    })

    io.ready := true.B
    io.isDigit := false.B
    io.digitPos := 0.U
    for(i <- segmentLength-1 to 0 by -1) {
        when(io.segment(i) >= 48.U && io.segment(i) <= 57.U) {
            io.isDigit := true.B
            io.digitPos := i.U
        }
    }   
}

// Assumed Invariant: segment starts with a digit
class ExtractDigit(segmentLength:Int, maxLength:Int) extends Module {
    val io = IO(new Bundle {
        val segment = Input(Vec(segmentLength, UInt(8.W)))
        val valid = Input(Bool())
        val reset = Input(Bool())
        val ready = Output(Bool())
        val resultNum = Output(UInt(64.W))
    })

    //Strategy: put a decoder on every segment (convert from ASCII to bin)
    val decodedDigits = Reg(Vec(segmentLength, UInt(4.W)))
    val offsetChain = Wire(Vec(segmentLength, UInt(64.W)))
    val sumChain = Wire(Vec(segmentLength, UInt(64.W)))
    val powerVec = VecInit.tabulate(segmentLength)(i => math.pow(10, i).toInt.U)
    val offset =  Reg(UInt(64.W))

    when(io.reset) {
        //TODO parameterize this
        for(i <- 0 to segmentLength-1) {
            decodedDigits(i) := 0.U
            offset := 0.U
            offsetChain := DontCare
            sumChain := DontCare
        }
    }.elsewhen(io.valid) {
        // Single-digit decoders
        for(i <- 0 to maxLength-1) {
            when(io.segment(i) >= 48.U && io.segment(i) <= 57.U) {
                decodedDigits(i) := io.segment(i) - 48.U
                if(i == 0) {
                    offsetChain(i) := segmentLength.U
                } else {
                    offsetChain(i) := offsetChain(i-1)
                }
            }.otherwise { // I think there would be weird collisions without this otherwise case
                printf("%d gives %c\n", i.U, io.segment(i))
                decodedDigits(i) := 0.U
                if(i == 0) {
                    offsetChain(i) := segmentLength.U
                } else {
                    when(offsetChain(i-1) === segmentLength.U) {
                        offsetChain(i) := i.U-1.U
                    }.otherwise {
                        offsetChain(i) := offsetChain(i-1)
                    }
                }
            }
        }
        
        // Given offset chain, store offset into intermediate register (end of cycle 1)
        when(offsetChain(segmentLength-1) === segmentLength.U) {
            offset := 0.U
        }.otherwise {
            offset := offsetChain(segmentLength-1)
        }
        
        // Compute the output value
        for(i <- 0 to maxLength-1) {
            if(i == 0) {
                sumChain(0) := decodedDigits(0)*powerVec(offset)
                printf("0, %d power = %d\n", offset, powerVec(offset))
            } else {
                when(offset >= i.U) {
                    sumChain(i) := sumChain(i-1) + decodedDigits(i)*powerVec(offset-i.U)
                }.otherwise {
                    sumChain(i) := sumChain(i-1)
                }
            }
        }
    }.otherwise {
        offsetChain := DontCare
        sumChain := DontCare
    }

    io.resultNum := sumChain(segmentLength-1)
    io.ready := true.B



}