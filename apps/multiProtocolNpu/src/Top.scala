import chisel3._
import chisel3.util._

import scala.collection.mutable.HashMap
import scala.collection.mutable.ArrayBuffer


/* This source implements an IPv4 network processor */

class Top extends Module with GorillaUtil {
  val io = IO(new gInOutOffBundle(new NP_EthMpl3Header_t, new NP_EthMpl3Header_t))
  val mpEngine = Engine("multiProtocolEngine.c")
  val mem1 = spMem(1000, 16)
  val mem2 = spMem(1000, 16)
  val mem3 = spMem(1000, 16)
  val mem4 = spMem(1000, 16)
  val mem5 = spMem(1000, 16)
  val mem6 = spMem(1000, 16)
  val mem7 = rwSpMem(1000, 16)
  val mem8 = rwSpMem(1000, 16)
  val mem9 = rwSpMem(1000, 16)
  val lookupMems1 = ArrayBuffer((mem1, "mem1"), (mem2, "mem2"), (mem3, "mem3"))
  val lookupMems2 = ArrayBuffer((mem4, "mem1"), (mem5, "mem2"), (mem6, "mem3"))
  val ipv4Lookup1 = Offload(Engine("ipv4Lookup.c"), lookupMems1)
  val ipv4Lookup2 = Offload(Engine("ipv4Lookup.c"), lookupMems2)
  val qosCountMems = ArrayBuffer((mem7, "mem1"), (mem8, "mem2"), (mem9, "mem3"))
  val qosCount = Offload(Engine("qosCount.c"), qosCountMems, "rw")
  val lookups = ArrayBuffer((ipv4Lookup1, "ipv4Lookup1"), (ipv4Lookup2, "ipv4Lookup2"))
  val result = Offload(Offload(mpEngine, lookups), qosCount, "qosCount")
}

