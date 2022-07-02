import chisel3._
import chisel3.util._
import chisel3.util.PriorityEncoder

class IsDigit(segmentLength:Int) extends Module {
    val io = IO(new Bundle {
        val segment = Input(Vec(segmentLength, UInt(8.W)))
        val valid = Input(Bool())
        val ready = Output(Bool())
        val valid_out = Output(Bool())
        val isDigit = Output(Bool())
        val digitPos = Output(UInt(log2Up(segmentLength).W))
    })

    val latency = log2Up(segmentLength)+4
    val validVec = RegInit(VecInit(Seq.fill(latency)(false.B)))
    val isDigitVec = RegInit(VecInit(Seq.fill(latency)(false.B)))
    val digitPosVec = Reg(Vec(latency, UInt(log2Up(segmentLength).W)))

    io.ready := true.B
    validVec(0) := io.valid
    for(i <- segmentLength-1 to 0 by -1) {
        when(io.segment(i) >= 48.U && io.segment(i) <= 57.U) {
            isDigitVec(0) := true.B
            digitPosVec(0) := i.U
        }
    }

    for (i <- 1 to latency-1) {
        validVec(i) := validVec(i-1)
        isDigitVec(i) := isDigitVec(i-1)
        digitPosVec(i) := digitPosVec(i-1)
    }
    io.valid_out := validVec(latency-1)
    io.isDigit := isDigitVec(latency-1)
    io.digitPos := digitPosVec(latency-1)
}

// Assumed Invariant: segment starts with a digit
class ExtractDigit(segmentLength:Int) extends Module {
    val io = IO(new Bundle {
        val segment = Input(Vec(segmentLength, UInt(8.W)))
        val valid = Input(Bool())
        val ready = Output(Bool())
        val valid_out = Output(Bool())
        val resultNum = Output(UInt(64.W))
    })

    //Strategy: put a decoder on every segment (convert from ASCII to bin)
    val decodedDigits = RegInit(VecInit(Seq.fill(segmentLength)(0.U(4.W))))
    val offsetChain = RegInit(VecInit(Seq.fill(segmentLength)(false.B)))
    val offsetChain_r = RegInit(VecInit(Seq.fill(segmentLength)(false.B)))
    val powerVec = RegInit(VecInit.tabulate(segmentLength)(i => BigDecimal(math.pow(10, i)).toBigInt.U))

    /************* Stage 0 ***************/
    when(io.valid) {
        // Single-digit decoders
        for(i <- 0 to segmentLength-1) {
            when(io.segment(i) >= 48.U && io.segment(i) <= 57.U) {
                decodedDigits(i) := io.segment(i) - 48.U
                offsetChain(i) := true.B
                offsetChain_r(i) := false.B
                // if(i == 0) {
                //     offsetChain(i) := segmentLength.U
                // } else {
                //     offsetChain(i) := offsetChain(i-1)
                // }
            }.otherwise { // I think there would be weird collisions without this otherwise case
                printf("%d gives %c\n", i.U, io.segment(i))
                decodedDigits(i) := 0.U
                offsetChain(i) := false.B
                offsetChain_r(i) := true.B
                // if(i == 0) {
                //     offsetChain(i) := segmentLength.U
                // } else {
                //     when(offsetChain(i-1) === segmentLength.U) {
                //         offsetChain(i) := i.U-1.U
                //     }.otherwise {
                //         offsetChain(i) := offsetChain(i-1)
                //     }
                // }
            }
        }
    }
        
    /************* Stage 1 ***************/
    // Given offset chain, store offset into intermediate register (end of cycle 1)
    val offset = Wire(UInt(5.W))
    val offset2 = Wire(UInt(5.W))
    val offset2Chain = Wire(Vec(segmentLength, Bool()))
    val decodedDigits_d0 = RegInit(VecInit(Seq.fill(segmentLength)(0.U(4.W))))
    decodedDigits_d0 := decodedDigits
    offset := PriorityEncoder(offsetChain.asUInt)
    for (i <- 0 to segmentLength-1) {
        when (i.U < offset) {
            offset2Chain(i) := false.B
        } .otherwise {
            offset2Chain(i) := offsetChain_r(i)
        }
    }
    offset2 := PriorityEncoder(offset2Chain.asUInt)

    /************* Stage 2 ***************/
    val powerVecShift = Reg(Vec(segmentLength, UInt(64.W)))
    val decodedDigits_d1 = RegInit(VecInit(Seq.fill(segmentLength)(0.U(4.W))))
    val offset_reg = RegInit(0.U(5.W))
    val offset2_reg = RegInit(0.U(5.W))
    decodedDigits_d1 := decodedDigits_d0
    offset_reg := offset
    offset2_reg := offset2

    for (i <- 0 to segmentLength-1) {
        when ((i.U < offset_reg) || (i.U >= offset2_reg)) {
            powerVecShift(i) := 0.U
        } .otherwise {
            powerVecShift(i) := powerVec(i.U - offset_reg)
        }
    }

    /************* Stage 3- ***************/
    // Compute the output value
    val sumTreeWidth = (segmentLength+1)/2
    val sumTreeDepth = log2Up(segmentLength)
    val sumChain_in = Reg(Vec(segmentLength, UInt(64.W)))
    val sumChain = Reg(Vec(sumTreeDepth, Vec(sumTreeWidth, UInt(64.W))))
    val validVec = RegInit(VecInit(Seq.fill(sumTreeDepth+4)(false.B)))
    validVec(0) := io.valid
    for (i <- 1 to sumTreeDepth+2) {
        validVec(i) := validVec(i-1)
    }

    for (i <- 0 to segmentLength-1) {
        sumChain_in(i) := decodedDigits_d1(i) * powerVecShift(i)
    }
    for (i <- 0 to sumTreeWidth-1) {
        if (2*i+1 < segmentLength) {
            sumChain(0)(i) := sumChain_in(2*i) + sumChain_in(2*i+1)
        } else {
            sumChain(0)(i) := sumChain_in(2*i)
        }
    }
    var width = sumTreeWidth
    var newWidth = (width+1)/2
    for (i <- 1 to sumTreeDepth-1) {
        for (j <- 0 to newWidth-1) {
            if (2*j < width) {
                sumChain(i)(j) := sumChain(i-1)(2*j) + sumChain(i-1)(2*j+1)
            } else {
                sumChain(i)(j) := sumChain(i-1)(2*j)
            }
        }
        width = newWidth
        newWidth = (newWidth+1)/2
    }

    io.resultNum := sumChain(sumTreeDepth-1)(0)
    io.ready := true.B
    io.valid_out := validVec(sumTreeDepth+3)

}