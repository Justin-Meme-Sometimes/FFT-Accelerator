#!/usr/bin/env python3
"""Golden model + test-vector generator for the `compute` butterfly unit.

Fixed-point format: Q8.8 (16-bit signed, 8 integer bits incl. sign, 8 fractional bits).

Implements:
    p_r = b_r*w_r - b_i*w_i          (real part of B*W)
    p_i = b_r*w_i + b_i*w_r          (imag part of B*W)
    out0 = A + B*W   ->  out0_r = a_r + p_r,  out0_i = a_i + p_i
    out1 = A - B*W   ->  out1_r = a_r - p_r,  out1_i = a_i - p_i

Modeled RTL architecture (as of the widened fp_mul / multi-stage compute_unit):
  1. fp_mul now outputs the *exact* 32-bit product of two Q8.8 operands (Q16.16,
     no internal shift).
  2. p_r_wide/p_i_wide = exact 32-bit sum/difference of two such products (Q16.16).
  3. The `round` module converts Q16.16 -> Q8.8 with round-to-nearest: it adds a
     2^-8 (post-rescale) bias of 128 before taking bits [23:8] of the 32-bit value.
  4. out0/out1 = a (Q8.8) +/- p_round (Q8.8), a plain 16-bit wrapped add/sub -
     no further rescale is needed here since both operands are already Q8.8.

This is the *intended* math for that pipeline. It intentionally does NOT model
fp_add's `a`/`b` ports still being 16 bits wide (which silently truncates the
32-bit p_r_wide/p_i_wide products before line 4) or the extra `round` + `>>>1`
still applied to the stage-4 sums in compute_unit.sv - if those bugs are present
in the RTL, comparing against this golden model is exactly what will surface them.

Writes:
    tb/vectors.hex  - DUT stimulus: "a_r a_i b_r b_i w_r w_i" per line, 16-bit hex
    tb/golden.hex   - expected results: "out0_r out0_i out1_r out1_i" per line, 16-bit hex
"""
import random
import struct

FRAC_BITS = 8
ONE = 1 << FRAC_BITS  # 256


def to_fixed(x: float) -> int:
    """Convert a real number to a Q8.8 16-bit two's-complement int (wraps on overflow)."""
    return round(x * ONE) & 0xFFFF


def to_signed16(v: int) -> int:
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


def to_float(v: int) -> float:
    return to_signed16(v) / ONE


def fp_mul_wide(a: int, b: int) -> int:
    """Exact 16x16 -> 32-bit product (Q16.16), no shift - matches the widened fp_mul."""
    return to_signed16(a) * to_signed16(b)


def round_q16_16_to_q8_8(x32: int) -> int:
    """Matches the `round` module: (x32 + 128), then take bits [23:8] of the 32-bit result."""
    biased = (x32 + 128) & 0xFFFFFFFF
    return (biased >> 8) & 0xFFFF


def fp_add(a: int, b: int, sub: bool) -> int:
    """16-bit add/sub, truncated (wrapped) to 16 bits."""
    raw = to_signed16(a) - to_signed16(b) if sub else to_signed16(a) + to_signed16(b)
    return raw & 0xFFFF


def compute_model(a_r, a_i, b_r, b_i, w_r, w_i):
    real_prod_1 = fp_mul_wide(b_r, w_r)
    real_prod_2 = fp_mul_wide(b_i, w_i)
    img_prod_1 = fp_mul_wide(b_r, w_i)
    img_prod_2 = fp_mul_wide(b_i, w_r)

    p_r_wide = real_prod_1 - real_prod_2
    p_i_wide = img_prod_1 + img_prod_2

    p_r = round_q16_16_to_q8_8(p_r_wide)
    p_i = round_q16_16_to_q8_8(p_i_wide)

    out0_r = fp_add(a_r, p_r, sub=False)
    out0_i = fp_add(a_i, p_i, sub=False)
    out1_r = fp_add(a_r, p_r, sub=True)
    out1_i = fp_add(a_i, p_i, sub=True)

    # per-stage unconditional FFT scaling: halve every butterfly output to bound
    # growth across cascaded stages (out = A +/- B*W can be up to 2x either operand)
    def shift1(x16):
        return (to_signed16(x16) >> 1) & 0xFFFF

    return shift1(out0_r), shift1(out0_i), shift1(out1_r), shift1(out1_i)


def build_vectors():
    vectors = []

    # --- directed edge cases ---
    directed_floats = [
        (0.0, 0.0, 0.0, 0.0, 1.0, 0.0),          # all zero, W=1
        (1.0, 0.0, 1.0, 0.0, 1.0, 0.0),          # identity twiddle
        (1.0, 0.0, 0.0, 1.0, 1.0, 0.0),          # pure imaginary B
        (1.0, 1.0, 1.0, 1.0, 0.0, -1.0),         # W = -j  (quarter-turn twiddle)
        (0.5, -0.5, 2.0, -2.0, 0.7071, -0.7071), # ~W(N/8) twiddle, fractional
        (127.99609375, 127.99609375, 1.0, 0.0, 1.0, 0.0),   # max positive A, no overflow
        (-128.0, -128.0, 1.0, 0.0, 1.0, 0.0),               # max negative A
        (100.0, 100.0, 100.0, 100.0, 1.0, 1.0),  # forces multiply/add overflow (wrap check)
        (0.00390625, 0.00390625, 0.00390625, 0.00390625, 1.0, 1.0),  # smallest LSB step
    ]
    for a_r, a_i, b_r, b_i, w_r, w_i in directed_floats:
        vectors.append(tuple(to_fixed(v) for v in (a_r, a_i, b_r, b_i, w_r, w_i)))

    # raw extreme bit patterns (not float-representable cleanly)
    directed_raw = [
        (0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF),  # all max positive
        (0x8000, 0x8000, 0x8000, 0x8000, 0x8000, 0x8000),  # all max negative (most negative)
        (0x7FFF, 0x8000, 0x8000, 0x7FFF, 0x7FFF, 0x8000),  # mixed extremes
    ]
    vectors.extend(directed_raw)

    # --- pseudo-random coverage (reproducible) ---
    rng = random.Random(0xFFAC7)
    for _ in range(50):
        vectors.append(tuple(rng.randint(0x0000, 0xFFFF) for _ in range(6)))

    return vectors


def main():
    vectors = build_vectors()

    with open("tb/vectors.hex", "w") as vf, open("tb/golden.hex", "w") as gf:
        for a_r, a_i, b_r, b_i, w_r, w_i in vectors:
            vf.write(f"{a_r:04x} {a_i:04x} {b_r:04x} {b_i:04x} {w_r:04x} {w_i:04x}\n")
            out0_r, out0_i, out1_r, out1_i = compute_model(a_r, a_i, b_r, b_i, w_r, w_i)
            gf.write(f"{out0_r:04x} {out0_i:04x} {out1_r:04x} {out1_i:04x}\n")

    print(f"wrote {len(vectors)} vectors to tb/vectors.hex and tb/golden.hex")


if __name__ == "__main__":
    main()
