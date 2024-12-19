import random
from enum import Enum

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.types import LogicArray

# TODO: extract enums automatically from include.scala
class Opcode(Enum):
    ADD = 0
    SUB = 1
    XOR = 2
    OR  = 3
    AND = 4
    SLL = 5
    SRL = 6
    SRA = 7
    SLT = 8
    SLTU = 9
    LUI = 10
    CAT = 11


@cocotb.test()
async def test(dut):
    # Create a 1ns period clock on port clock
    clock = Clock(dut.clock, 1, units="ns")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))
    # reset design
    await reset_dut(dut)

    # test the ops
    # TODO test immediate values
    for op in Opcode:
        print(f"testing opcode: {op}")

        print(f"testing predefine stimulus...", end="")
        for imm in range(2):
            for a,b in stimulus_map[op]:
                expected_val = function_map[op](a, b, imm) & 0xFFFFFFFF
                await evaluate_dut(dut, expected_val, op, a, b, b, imm)
        print("pass")
            
        print(f"testing random stimulus...", end="")
        for imm in range(2):
            for _ in range(100):
                a = random.getrandbits(32)
                b = random.getrandbits(32)
                expected_val = function_map[op](a, b, imm) & 0xFFFFFFFF
                await evaluate_dut(dut, expected_val, op, a, b, b, imm)
        print("pass")



async def reset_dut(dut):
    # Set initial input value to prevent them from floating
    dut.io_rs1.value = 0
    dut.io_rs2.value = 0
    dut.io_imm.value = 0
    dut.io_immSel.value = 0
    dut.io_opcode.value = 0
    dut.io_dout.value = 0
    # reset
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    dut.reset.value = 0


async def evaluate_dut(dut, expected_val, opcode, rs1, rs2, imm, immSel):
    """Drive DUT"""
    dut.io_opcode.value = opcode.value
    dut.io_rs1.value = rs1
    dut.io_rs2.value = rs2
    dut.io_imm.value = (imm & 0xFFF)
    dut.io_immSel.value = immSel
    await RisingEdge(dut.clock)
    await Timer(0.01, 'ns') # values don't update immediately after clock
    # compare result
    print(f"dut.sr2: 0x{dut.sr2.value.to_unsigned():08x}")
    assert dut.io_dout.value == expected_val, f"OP failed: {opcode} sr1: 0x{dut.io_rs1.value.to_unsigned():08x} sr2: 0x{dut.io_rs2.value.to_unsigned():08x} imm: 0x{dut.io_imm.value.to_unsigned():02x} immSel: {immSel} -> 0x{int(dut.io_dout.value):08x} =/= 0x{expected_val:08x} (expected)"


def bits_to_signed_int(bits, bitlen):
    s = bits & (1 << bitlen - 1)
    if s:
        return -((~bits + 1) & ((1 << bitlen) - 1))
    else:
        return bits


def sign_ext(bits, bitlen):
    """Takes an integer of <bitlen> length and sign extends it to 32 bit"""
    bits &= (1 << bitlen) - 1
    m = 1 << (bitlen - 1)
    bits = (bits ^ m) - m
    return bits & 0xFFFFFFFF


def add(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    result = a + b
    result &= 0xFFFFFFFF
    return result

def sub(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    result = a - b
    result &= 0xFFFFFFFF
    return result

def xor(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    return a ^ b

def or_f(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    return a | b

def and_f(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    return a & b

def sll(a, b, _):
    return (a << (b & 0x1F)) & 0xFFFFFFFF

def srl(a, b, _):
    return (a >> (b & 0x1F)) & 0xFFFFFFFF

def sra(a, b, _):
    if a & 0x80000000:
        a |= (0xFFFFFFFF << 32)
    return (a >> (b & 0x1F)) & 0xFFFFFFFF

def slt(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    a = bits_to_signed_int(a, 32)
    b = bits_to_signed_int(b, 32)
    return a < b

def sltu(a, b, imm):
    if imm:
        b = sign_ext(b, 12)
    # convert to unsigned by masking to 32 bits
    a &= 0xFFFFFFFF
    b &= 0xFFFFFFFF
    return a < b

def lui(a, _, __):
    return a & 0xFFFFF000

def cat(a, b, _):
    return (b & 0x1FF) << 9 | (a & 0x1FF)


function_map = {
    Opcode.ADD : add,
    Opcode.SUB : sub,
    Opcode.XOR : xor,
    Opcode.OR : or_f,
    Opcode.AND : and_f,
    Opcode.SLL : sll,
    Opcode.SRL : srl,
    Opcode.SRA : sra,
    Opcode.SLT : slt,
    Opcode.SLTU : sltu,
    Opcode.LUI : lui,
    Opcode.CAT : cat,
}

stimulus_map = {
    Opcode.ADD : [(0,0),(1,0),(-1,0),(-1,1),((1<<31)-1,1),((1<<32)-1,1)],
    Opcode.SUB : [(0,0),(1,0),(-1,0),(-1,1),((1<<31)-1,1),((1<<32)-1,1)],
    Opcode.XOR : [(0,0),(1,0),(-1,0),(-1,1),(0xDEADBEEF,0xFFFFFFFF)],
    Opcode.OR : [(0,0),(1,0),(-1,0),(-1,1),(0xDEADBEEF,0xFFFFFFFF)],
    Opcode.AND : [(0,0),(1,0),(-1,0),(-1,1),(0xDEADBEEF,0xFFFFFFFF)],
    Opcode.SLL : [(0xDEADBEEF,0),(0xDEADBEEF,1),(0xDEADBEEF,2),(0xDEADBEEF,10),(0xDEADBEEF,31)],
    Opcode.SRL : [(0xDEADBEEF,0),(0xDEADBEEF,1),(0xDEADBEEF,2),(0xDEADBEEF,10),(0xDEADBEEF,31)],
    Opcode.SRA : [(0xDEADBEEF,0),(0xDEADBEEF,1),(0xDEADBEEF,2),(0xDEADBEEF,10),(0xDEADBEEF,31)],
    Opcode.SLT : [(0,0),(1,0),(0,1),(1,1),(-1,0),(-1,-1),(-1,1),(0,-1),(1,-1)],
    Opcode.SLTU : [(0,0),(1,0),(0,1),(1,1),(-1,0),(-1,-1),(-1,1),(0,-1),(1,-1)],
    Opcode.LUI : [(0xDEADBEEF,0)],
    Opcode.CAT : [(0xDEAD,0xBEEF)],
}
