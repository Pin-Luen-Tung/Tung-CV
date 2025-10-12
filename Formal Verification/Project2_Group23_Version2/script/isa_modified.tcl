# you can modify it
clear -all
check_cov -init -type all

# include source code
analyze -v2k [glob ../source/modified/biriscv/biriscv/icache/*.v]
analyze -v2k [glob ../source/modified/biriscv/biriscv/dcache/*.v]
analyze -v2k [glob ../source/modified/biriscv/biriscv/core/*.v]
analyze -v2k [glob ../source/modified/biriscv/biriscv/top/riscv_top.v]

# include assertion property
analyze -sv  [glob ../property/isa.sva]

# top module
elaborate -top riscv_top

# icache always hit
 stopat u_core.u_frontend.icache_valid_i
 assume {u_core.u_frontend.icache_valid_i == 1'b1}
 stopat u_core.u_frontend.icache_accept_i
 assume {u_core.u_frontend.icache_accept_i == 1'b1}
 stopat u_core.mem_d_error_i
 assume {u_core.mem_d_error_i == 1'b0}
 stopat u_core.mem_i_error_i
 assume {u_core.mem_i_error_i == 1'b0}
# always fetch legal instruction
# assume {formaltest_biriscv.rvfi_input_insn1 != 32'd0}
# assume {formaltest_biriscv.rvfi_input_insn0 != 32'd0} 
stopat u_core.mem_i_inst_i
assume {u_core.mem_i_inst_i == formaltest_biriscv.rvfi_input_insn}
# set clock and reset signal
clock clk_i
reset rst_i

# set max runtime
set_prove_time_limit 259200s

# make jg execute the properties
prove -all