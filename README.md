# FFT-Accelerator

A hardware FFT accelerator, designed as an ASIC RTL project for learning digital
design, fixed-point DSP arithmetic, and the ASIC design flow end-to-end.

## Goals

**Functional**
- Compute the Fast Fourier Transform (FFT) in hardware for configurable
  transform sizes, targeting N = 64 up to 1024 points (power-of-2 sizes).
- Use fixed-point arithmetic throughout (format TBD, e.g. Q-format), sized to
  balance numerical accuracy against area/power.
- Expose a simple, well-defined input/output interface (e.g. streaming or
  memory-mapped) so the core can be dropped into a larger SoC or DSP pipeline.

**ASIC-oriented**
- Written as synthesizable RTL with no vendor-specific (FPGA) primitives, so
  it maps cleanly to a standard-cell ASIC flow.
- Keep area and power in mind as first-class design constraints, not
  afterthoughts bolted on post-implementation.
- Carry the design through the full flow: RTL -> simulation/verification ->
  synthesis -> (stretch) place & route.

**Learning**
- Build real fluency with the ASIC design flow, not just RTL synthesis,
  timing closure, and area/power tradeoffs.
- Understand and implement the classic FFT hardware architectures (e.g.
  radix-2/radix-4 butterfly, pipelined vs. iterative datapaths) and be able to
  explain the tradeoffs between them.
- Practice disciplined verification: a self-checking testbench that compares
  hardware output against a golden model (e.g. NumPy FFT).

## Non-goals (for now)

- Floating-point arithmetic.
- Multi-channel or batched transforms.
- A full SoC integration this project is scoped to the accelerator core
  and its verification environment.

## Status

Early stage — RTL and testbench scaffolding in [src/](src/) and [tb/](tb/)
are placeholders; architecture and interface details are still being decided.
