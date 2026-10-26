import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def model(s, lo, hi):
    if lo > hi:
        return 0b1000
    if s < lo:
        return 0b0001
    if s > hi:
        return 0b0100
    return 0b0010


async def start(dut):
    try:
        clock = Clock(dut.clk, 10, unit="us")
    except TypeError:
        clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())


async def load(dut, mn, mx):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    dut.rst_n.value = 1
    dut.uio_in.value = mn          # canh len 1: chot min
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = mx          # canh len 2: chot max
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0xAA        # doi nguong tren chan: phai KHONG anh huong nua
    await ClockCycles(dut.clk, 2)


async def check(dut, s, lo, hi):
    dut.ui_in.value = s
    await ClockCycles(dut.clk, 1)
    got = int(dut.uo_out.value) & 0x0F
    assert got == model(s, lo, hi), f"s={s} min={lo} max={hi} got={got:04b}"


@cocotb.test()
async def test_c01(dut):
    await start(dut)
    # 6 ca bat buoc cua charter
    await load(dut, 50, 100)
    for s in (49, 50, 75, 100, 101):
        await check(dut, s, 50, 100)
    await load(dut, 100, 50)
    await check(dut, 75, 100, 50)
    # ca tu xay dung
    await load(dut, 100, 99)
    for s in (0, 99, 200):
        await check(dut, s, 100, 99)
    await load(dut, 100, 100)
    for s in (99, 100, 101):
        await check(dut, s, 100, 100)
