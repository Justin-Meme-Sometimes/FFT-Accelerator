import numpy as np

N = 1024
bits = 16
scale = (1 << (bits - 1)) - 1  # 32767 for Q1.15

with open("twiddle_lut.mem", "w") as f:
    for k in range(N // 2):
        angle = -2 * np.pi * k / N
        cos_val = int(np.round(np.cos(angle) * scale)) & 0xFFFF
        sin_val = int(np.round(np.sin(angle) * scale)) & 0xFFFF
        
        f.write(f"{(cos_val << 16) | sin_val:08x}\n")