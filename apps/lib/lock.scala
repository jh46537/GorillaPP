import chisel3._
import chisel3.util._

import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.HashMap


class lock(extCompName: String)(idWidthLog: Int=8)(waitListLength: Int=32)
  extends gComponentLeaf(() => new Lock_int_t(UInt(idWidthLog.W)))(() => new Lock_out_t)(ArrayBuffer())(extCompName=extCompName)
  with include
{
  val stat = Mem(Bool(), 1 << idWidthLog)
  val waitList = Mem(UInt(waitListLength.W), 1 << idWidthLog)
  val waitListOfThisLock = waitList(io.in.bits.id)
  val winnerWaiter = PEncode(waitListOfThisLock)
  val statOfThisLock = state(io.in.bits.id)
  val Waiting::CheckStat:RemoveWaiter::SendReadyOnInput::SendResponse::Nil = Enum(5)
  val State = RegInit(0.U(log2Up(5).W))

  //If command is lock check the lock status
  when (State === Waiting && io.in.valid && io.in.bits.command === LockCommand) {
    State := CheckStat
  }
  //If lock is free grant the lock
  when (State === CheckStat && requestedLockStat === Free) {
    stat(io.in.bits.id) := true.B
    State := Waiting
  }
  //If lock is grabbed add the thread to wait list
  when (State === CheckStat && requestedLockStat === Grabbed) {
    waitList(io.in.bits.id) := waitLisOfThisLock | (1 << io.in.bits.tag)
    State := Waiting
  }
  //If command is unlock change (i) the change the stat and (ii) in a loop send acks to waiters
  when  (State === Waiting && io.in.valid && io.in.bits.command === UnlockCommand) {
    stat(io.in.bits.id) := false.B
    State := RemoveWaiter
  }
  when (State === RemoveWaiter && winnerWaiter != NoWaiter) {
    waitList(io.in.bits.id) := waitListOfThisLock & ~(1 << io.in.bits.tag)
  }
  when (State === RemoveWaiter && winnerWaiter === NoWaiter) {
    State := SendReadyOnInput
  }
  when (State === SendReadyOnInput) {
    io.out.ready = true.B
    State := SendResponse
  } .elsewhen {
    io.out.ready = false.B
  }
  when (State === SendResponse) {
    io.out.valid = true.B
    State := WaitForOutputReady
  }
  when (State === WaitForOuptutReady && io.out.ready) {
    State := Waiting
  }
}
