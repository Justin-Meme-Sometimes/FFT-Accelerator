word_size = 32 # Bits
num_words = 1024
human_byte_size = "{:.0f}kbytes".format((word_size * num_words)/1024/8)


tech_name = "sky130"

# Tools are provided by the iic-osic-tools container, not Nix
use_nix = False

# Only characterize the nominal corner (much faster than full corner sweep)
nominal_corner_only = True

# Run DRC/LVS/PEX verification (needs magic/netgen on PATH)
check_lvsdrc = True

# Allow byte writes
write_size = 8 # Bits

# Dual port
num_rw_ports = 0
num_r_ports = 1
num_w_ports = 1
ports_human = '1r1w'

output_name = "{tech_name}_sram_{human_byte_size}_{ports_human}_{word_size}x{num_words}_{write_size}".format(**locals())
output_path = "src/{output_name}".format(**locals())

