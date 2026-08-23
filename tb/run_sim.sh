#!/usr/bin/env bash
# Runs the compute_unit testbench end-to-end:
#   1. generate stimulus + golden (Python) results
#   2. build + run the SV testbench against src/ (Verilator)
#   3. compare DUT output to the golden model
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

python3 tb/gen_vectors.py

rm -rf tb/obj_dir
verilator --binary -sv --timing -Wno-fatal \
    --Mdir tb/obj_dir \
    --top-module compute_tb \
    tb/compute_tb.sv \
    src/compute_unit.sv src/fixed_point_add.sv src/fixed_point_mul.sv

tb/obj_dir/Vcompute_tb

python3 tb/compare.py
