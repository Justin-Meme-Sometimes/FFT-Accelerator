#!/usr/bin/env python3
"""Compares tb/dut_out.hex (from the SV simulation) against tb/golden.hex
(the Python model), reporting a PASS/FAIL summary and any mismatches.
"""
import sys

from gen_vectors import to_float, to_signed16


def load_hex_lines(path):
    with open(path) as f:
        return [line.split() for line in f if line.strip()]


def main():
    vectors = load_hex_lines("tb/vectors.hex")
    golden = load_hex_lines("tb/golden.hex")
    try:
        dut = load_hex_lines("tb/dut_out.hex")
    except FileNotFoundError:
        print("tb/dut_out.hex not found - run the simulation first (tb/run_sim.sh)")
        sys.exit(1)

    n = len(golden)
    if len(dut) != n:
        print(f"WARNING: golden has {n} vectors but dut_out has {len(dut)} - "
              f"comparing the first {min(n, len(dut))}")
        n = min(n, len(dut))

    fails = 0
    for i in range(n):
        g = [int(x, 16) for x in golden[i]]
        d = [int(x, 16) for x in dut[i]]
        if g != d:
            fails += 1
            v = [int(x, 16) for x in vectors[i]]
            a_r, a_i, b_r, b_i, w_r, w_i = (to_float(x) for x in v)
            print(f"MISMATCH vector {i}:")
            print(f"  in : a=({a_r:+.5f}, {a_i:+.5f}j)  b=({b_r:+.5f}, {b_i:+.5f}j)  "
                  f"w=({w_r:+.5f}, {w_i:+.5f}j)")
            names = ["out0_r", "out0_i", "out1_r", "out1_i"]
            for name, gv, dv in zip(names, g, d):
                mark = "  <-- MISMATCH" if gv != dv else ""
                print(f"  {name}: golden=0x{gv:04x} ({to_signed16(gv)/256:+.5f})  "
                      f"dut=0x{dv:04x} ({to_signed16(dv)/256:+.5f}){mark}")

    print()
    if fails == 0:
        print(f"PASS: all {n} vectors matched")
        sys.exit(0)
    else:
        print(f"FAIL: {fails}/{n} vectors mismatched")
        sys.exit(1)


if __name__ == "__main__":
    main()
