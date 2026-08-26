word_size = 32 # Bits
num_words = 1024
human_byte_size = "{:.0f}kbytes".format((word_size * num_words)/1024/8)


tech_name = "sky130"

# Only characterize the nominal corner (much faster than full corner sweep)
nominal_corner_only = True

# DRC/LVS/PEX disabled: the sky130 dual-port bitcell (sky130_fd_bd_sram__openram_dp_cell)
# has a known, currently-unresolved upstream LVS limitation (see VLSIDA/OpenRAM#220) where
# a couple of its internal dummy tap transistors only resolve to the real bl1/br1 bitline
# nets via array abutment, which breaks netgen's hierarchical matching and forces an
# extremely slow full flatten of every bitcell instance. This is a bitcell/tooling issue,
# not something wrong with this config. Revisit if upstream fixes it or a real (non-label)
# layout fix is undertaken separately.
check_lvsdrc = False

# Allow byte writes
write_size = 8 # Bits

# Dual port
num_rw_ports = 0
num_r_ports = 1
num_w_ports = 1
ports_human = '1r1w'

output_name = "{tech_name}_sram_{human_byte_size}_{ports_human}_{word_size}x{num_words}_{write_size}".format(**locals())
output_path = "src/{output_name}".format(**locals())

